import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app/constants.dart';
import '../app/persona_theme_ext.dart';
import '../data/persona_copy.dart';
import '../models/school_year.dart';
import '../services/achievement_service.dart';
import '../services/calculator_service.dart';
import '../services/mood_service.dart';
import '../services/notification_service.dart';
import '../services/persona_service.dart';
import '../services/recap_ai_service.dart';
import '../services/school_data_service.dart';
import '../services/storage_service.dart';
import '../widgets/achievement_unlock_overlay.dart';
import '../widgets/break_reveal_overlay.dart';
import '../widgets/current_class_card.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/shimmer_loading.dart';
import 'counter_progress_ring.dart';
import 'counter_tab_cards.dart';
import 'counter_tab_widgets.dart';


class CounterTab extends StatefulWidget {
  const CounterTab({super.key});

  @override
  State<CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends State<CounterTab>
    with AutomaticKeepAliveClientMixin {
  SchoolYear? _schoolYear;
  bool _loading = true;
  Timer? _timer;
  Timer? _msTicker;
  int _days = 0, _hours = 0, _minutes = 0, _seconds = 0;

  CounterRingMode _ringMode = CounterRingMode.percent;
  String _ringValue = '';
  String _ringLabel = '';

  // Weekly recap state — null until loaded; becomes a string once we have
  // an AI one-liner or the static fallback.
  String? _recapOneLiner;
  bool _recapVisible = false;

  static const _schoolHoursPerDay = 6;
  static final _numFmt = NumberFormat('#,###');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final data = SchoolDataService.getCached();
    setState(() {
      _schoolYear = data;
      _loading = false;
    });
    if (data != null) {
      _startTimer();
      _updateRingValue();
      _checkAchievements(data);
      _maybeShowBreakReveal(data);
    }
    _checkAppOpenAchievements();
  }

  /// If a new break just became active, show the break-reveal overlay once.
  /// Uses StorageService key 'last_break_reveal_id' to dedupe.
  Future<void> _maybeShowBreakReveal(SchoolYear sy) async {
    final now = DateTime.now();
    SchoolBreak? active;
    for (final b in sy.breaks) {
      if (!now.isBefore(b.startDate) && !now.isAfter(b.endDate)) {
        active = b;
        break;
      }
    }
    if (active == null) return;
    final revealKey = '${sy.academicYear}_${active.name}';
    final last = StorageService.getString('last_break_reveal_id');
    if (last == revealKey) return;
    await StorageService.saveString('last_break_reveal_id', revealKey);
    // Also record seasonal achievement.
    final season = _seasonForBreakName(active.name);
    if (season != null) {
      await AchievementService.onBreakReached(season);
    }
    if (!mounted) return;
    // Defer slightly so the initial build paints before the overlay arrives.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await BreakRevealOverlay.show(context, breakName: active.name);
  }

  String? _seasonForBreakName(String name) {
    final n = name.toLowerCase();
    if (n.contains('summer')) {
      return 'summer';
    }
    if (n.contains('winter') ||
        n.contains('christmas') ||
        n.contains('iarna')) {
      return 'winter';
    }
    if (n.contains('spring') ||
        n.contains('easter') ||
        n.contains('primavara') ||
        n.contains('primăvară')) {
      return 'spring';
    }
    if (n.contains('autumn') ||
        n.contains('fall') ||
        n.contains('october') ||
        n.contains('toamna') ||
        n.contains('toamnă')) {
      return 'autumn';
    }
    return null;
  }

  Future<void> _checkAchievements(dynamic schoolYear) async {
    final newIds = await AchievementService.checkSchoolProgress(schoolYear);
    for (final id in newIds) {
      if (mounted) {
        await AchievementUnlockOverlay.show(context, id);
      }
    }
    // Record today's mood snapshot + surface any mood-streak unlocks.
    if (schoolYear is SchoolYear) {
      final moodIds = await MoodService.recordDailyMood(schoolYear);
      for (final id in moodIds) {
        if (mounted) {
          await AchievementUnlockOverlay.show(context, id);
        }
      }
      // Pre-generate / load recap when appropriate. Non-blocking.
      unawaited(_loadWeeklyRecap(schoolYear));
    }
  }

  /// Build the weekly recap, generate (or read cached) one-liner, schedule
  /// the Sunday notification, and show the in-app card Sun 19:00 → Mon 09:00
  /// if the user hasn't seen it yet for the current ISO week.
  Future<void> _loadWeeklyRecap(SchoolYear sy) async {
    final now = DateTime.now();
    // Bumps this week: every first_meet unlock is one unique peer; we simply
    // count any social unlocks within the last 7 days as a proxy for bumps.
    final recent = AchievementService.allUnlocks.where((u) {
      return now.difference(u.unlockedAt).inDays <= 7;
    }).toList();
    final bumps = recent
        .where((u) => const [
              'first_meet',
              'social_butterfly',
              'networker',
              'met_the_pack',
            ].contains(u.id))
        .length;
    final stats = MoodService.buildWeeklyRecap(
      anchor: now,
      bumpsThisWeek: bumps,
      achievementsThisWeek: recent.map((u) => u.id).toList(),
      dominantPersona: PersonaService.instance.current.id,
    );

    // Only pre-generate on weekends (Sat/Sun) to avoid spam; allow any day if
    // cache is already populated (returns instantly in that case).
    final weekday = now.weekday;
    final shouldGenerate = weekday == DateTime.saturday ||
        weekday == DateTime.sunday;
    if (!shouldGenerate &&
        StorageService.getString(
                'recap_cache_${RecapAiService.isoWeekKey(now)}') ==
            null) {
      return;
    }

    final oneLiner = await RecapAiService.generateOneLiner(
      stats,
      PersonaService.instance.current.id,
    );
    if (!mounted) return;
    setState(() => _recapOneLiner = oneLiner);
    unawaited(NotificationService.scheduleWeeklyRecap(body: oneLiner));

    // Show in-app card Sunday 19:00 → Monday 09:00 if user hasn't seen
    // this week's recap yet.
    final seenKey =
        'recap_seen_${RecapAiService.isoWeekKey(now)}';
    final seen = StorageService.getBool(seenKey) ?? false;
    final inWindow = (weekday == DateTime.sunday && now.hour >= 19) ||
        (weekday == DateTime.monday && now.hour < 9);
    if (!seen && inWindow) {
      setState(() => _recapVisible = true);
    }
  }

  Future<void> _dismissRecap() async {
    final key = 'recap_seen_${RecapAiService.isoWeekKey(DateTime.now())}';
    await StorageService.saveBool(key, true);
    // Bump recap-streak counters.
    await AchievementService.increment('recap_regular', goal: 5);
    await AchievementService.increment('recap_master', goal: 20);
    await AchievementService.increment('recap_streaker', goal: 10);
    if (mounted) setState(() => _recapVisible = false);
  }

  Future<void> _checkAppOpenAchievements() async {
    final newIds = await AchievementService.recordAppOpen();
    for (final id in newIds) {
      if (mounted) {
        await AchievementUnlockOverlay.show(context, id);
      }
    }
    // one_month + future mood-streak day dedup lives here — single source of
    // truth for "the user opened the app today".
    final dayIds = await AchievementService.recordDayOpen();
    for (final id in dayIds) {
      if (mounted) {
        await AchievementUnlockOverlay.show(context, id);
      }
    }
  }

  void _startTimer() {
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateCountdown();
        if (_ringMode != CounterRingMode.milliseconds) _updateRingValue();
      }
    });
  }

  void _updateCountdown() {
    final sy = _schoolYear;
    if (sy == null) return;
    final next = CalculatorService.nextBreak(sy);
    final target = next?.isActive == true
        ? next!.endDate
        : next?.startDate ?? sy.endDate;
    final cd =
        CalculatorService.formatCountdown(CalculatorService.countdown(target));
    setState(() {
      _days = cd['days']!;
      _hours = cd['hours']!;
      _minutes = cd['minutes']!;
      _seconds = cd['seconds']!;
    });
  }

  void _cycleRingMode() {
    final next = CounterRingMode.values[(_ringMode.index + 1) % CounterRingMode.values.length];
    _msTicker?.cancel();
    _msTicker = null;
    setState(() => _ringMode = next);
    _updateRingValue();
    if (next == CounterRingMode.milliseconds) {
      _msTicker = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (mounted) _updateRingValue();
      });
    }
  }

  void _updateRingValue() {
    final sy = _schoolYear;
    if (sy == null) return;
    final activeDays = CalculatorService.activeSchoolDaysRemaining(sy);
    String value;
    String label;
    switch (_ringMode) {
      case CounterRingMode.percent:
        value = '${(sy.yearProgress * 100).round()}%';
        label = 'School Year';
        break;
      case CounterRingMode.days:
        value = '$activeDays';
        label = 'school days left';
        break;
      case CounterRingMode.hours:
        value = _fmt(activeDays * _schoolHoursPerDay);
        label = 'school hours left';
        break;
      case CounterRingMode.minutes:
        value = _fmt(activeDays * _schoolHoursPerDay * 60);
        label = 'minutes left';
        break;
      case CounterRingMode.seconds:
        value = _fmt(activeDays * _schoolHoursPerDay * 3600);
        label = 'seconds left';
        break;
      case CounterRingMode.milliseconds:
        final baseMs = activeDays * _schoolHoursPerDay * 3600 * 1000;
        final liveMs = 1000 - DateTime.now().millisecondsSinceEpoch % 1000;
        value = _fmt(baseMs + liveMs);
        label = 'ms left';
        break;
    }
    setState(() {
      _ringValue = value;
      _ringLabel = label;
    });
  }

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 10000) return _numFmt.format(v);
    return v.toString();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _msTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const CounterShimmer();
    if (_schoolYear == null) return const CounterNoData();
    return _buildContent();
  }

  Widget _buildContent() {
    final sy = _schoolYear!;
    final next = CalculatorService.nextBreak(sy);
    final onBreak = CalculatorService.isOnBreak(sy);
    final yearOver = CalculatorService.isYearOver(sy);
    final stats = CalculatorService.getDayStats(sy);
    final activeBreakName = onBreak
        ? sy.breaks.firstWhere((b) => b.isActive).name
        : null;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.colorScheme.primary.withAlpha(12), Colors.transparent],
                ),
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                    child: Column(
                      children: [
                        CounterStatusBadge(
                          onBreak: onBreak,
                          yearOver: yearOver,
                          next: next,
                          activeBreakName: activeBreakName,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const CurrentClassCard(),
                        const SizedBox(height: AppSpacing.lg),
                        if (!yearOver) _buildCountdownCard(),
                        if (yearOver) _buildYearOverBadge(),
                        const SizedBox(height: AppSpacing.xxl),
                        if (!yearOver) _buildProgressRing(sy),
                        const SizedBox(height: AppSpacing.xl),
                        if (next != null)
                          CounterNextBreakCard(next: next, onBreak: onBreak),
                        const SizedBox(height: AppSpacing.md),
                        CounterStatsRow(stats: stats),
                        const SizedBox(height: AppSpacing.lg),
                        CounterTimelineSection(schoolYear: sy),
                        const SizedBox(height: AppSpacing.lg),
                        if (_recapVisible && _recapOneLiner != null) ...[
                          _WeeklyRecapCard(
                            oneLiner: _recapOneLiner!,
                            onDismiss: _dismissRecap,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Top-right icon row — Vibe + Achievements full-view shortcuts.
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: AppSpacing.md,
            child: _TopIconsRow(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(SchoolYear sy) => CounterProgressRing(
        progress: sy.yearProgress,
        ringValue: _ringValue,
        ringLabel: _ringLabel,
        ringMode: _ringMode,
        onTap: _cycleRingMode,
      );

  Widget _buildCountdownCard() => CounterCountdownCard(
        days: _days,
        hours: _hours,
        minutes: _minutes,
        seconds: _seconds,
      );

  Widget _buildYearOverBadge() => const CounterYearOverBadge();
}

/// Dismissible weekly recap card — shows the AI-generated (or fallback) one
/// liner plus a quick mood bar chart. Only rendered on Sunday evening through
/// Monday morning.
class _WeeklyRecapCard extends StatelessWidget {
  final String oneLiner;
  final VoidCallback onDismiss;

  const _WeeklyRecapCard({
    required this.oneLiner,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final personaId = PersonaService.instance.current.id;
    final stats = MoodService.weeklyBreakdown();
    final intro = PersonaCopy.get(personaId, 'recap_intro',
        fallback: 'Your week, at a glance.');

    return GlassmorphicCard(
      borderColor: context.personaTint.withAlpha(120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 16, color: context.personaTint),
              const SizedBox(width: 6),
              Text(
                'WEEKLY VIBE',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.personaTint,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              InkResponse(
                radius: 16,
                onTap: onDismiss,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded,
                      size: 16, color: Theme.of(context).colorScheme.onSurface.withAlpha(140)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            intro,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            oneLiner,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Mini mood breakdown — 7 bars, one per mood index.
          Row(
            children: List.generate(6, (i) {
              final count = stats[i] ?? 0;
              final emoji = MoodService.emojiFor(i);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 2),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: count > 0
                              ? context.personaTint
                                  .withAlpha(30 + count * 30)
                              : Theme.of(context).dividerTheme.color ?? AppColors.surfaceBorder,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Top-right pair of icons on the Counter tab: Vibe + Achievements shortcuts
/// to their full-view screens. Small red-dot badge appears on the Achievements
/// icon when there are unseen unlocks.
class _TopIconsRow extends StatefulWidget {
  @override
  State<_TopIconsRow> createState() => _TopIconsRowState();
}

class _TopIconsRowState extends State<_TopIconsRow> {
  @override
  void initState() {
    super.initState();
    AchievementService.addUnlockListener(_onUnlock);
  }

  @override
  void dispose() {
    AchievementService.removeUnlockListener(_onUnlock);
    super.dispose();
  }

  void _onUnlock(String _) {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Simple "fresh unlock" indicator — any unlock in last 24h lights the dot.
    final now = DateTime.now();
    final hasFresh = AchievementService.allUnlocks.any(
      (u) => now.difference(u.unlockedAt).inHours < 24,
    );
    return Row(
      children: [
        _HeaderIconButton(
          icon: Icons.auto_awesome_rounded,
          tooltip: 'Vibe',
          onTap: () => Navigator.pushNamed(context, '/vibe'),
          theme: theme,
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(
          icon: Icons.emoji_events_rounded,
          tooltip: 'Achievements',
          badge: hasFresh,
          onTap: () => Navigator.pushNamed(context, '/achievements'),
          theme: theme,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool badge;
  final VoidCallback onTap;
  final ThemeData theme;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.theme,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        theme.dividerTheme.color ?? AppColors.surfaceBorder,
                  ),
                  boxShadow: const [AppElevation.low],
                ),
                child: Icon(icon,
                    size: 18, color: theme.colorScheme.onSurface),
              ),
              if (badge)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
