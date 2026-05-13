import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';
import '../app/persona_theme_ext.dart';
import '../models/school_year.dart';
import '../models/subject.dart';
import '../services/achievement_service.dart';
import '../services/calculator_service.dart';
import '../services/mood_service.dart';
import '../services/schedule_service.dart';
import '../services/school_data_service.dart';
import '../services/study_log_service.dart';
import '../widgets/glassmorphic_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

enum _MoodWindow { week, month }

class _StatsScreenState extends State<StatsScreen> {
  SchoolYear? _sy;
  Map<String, int> _stats = {};
  _MoodWindow _moodWindow = _MoodWindow.week;

  @override
  void initState() {
    super.initState();
    StudyLogService.revision.addListener(_onChange);
    _load();
  }

  @override
  void dispose() {
    StudyLogService.revision.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  void _load() {
    final sy = SchoolDataService.getCached();
    if (sy == null) {
      setState(() => _sy = null);
      return;
    }
    setState(() {
      _sy = sy;
      _stats = CalculatorService.getDayStats(sy);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _buildLogFab(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildHeader(theme),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _sy == null
                ? _buildNoData(theme)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                    child: _buildContent(theme),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                  color:
                      theme.dividerTheme.color ?? AppColors.surfaceBorder),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 15, color: theme.colorScheme.onSurface),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'Statistics',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildNoData(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 48, color: theme.colorScheme.onSurface.withAlpha(140)),
          const SizedBox(height: 12),
          Text(
            'No school data yet',
            style: GoogleFonts.outfit(
                color: theme.colorScheme.onSurface.withAlpha(140),
                fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final progress = (_sy!.yearProgress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Big stats row.
        GlassmorphicCard(
          child: Row(
            children: [
              _BigStat(
                  label: 'Survived',
                  value: '${_stats['daysSurvived'] ?? 0}',
                  unit: 'days',
                  color: AppColors.success),
              _Divider(),
              _BigStat(
                  label: 'Remaining',
                  value: '${_stats['daysRemaining'] ?? 0}',
                  unit: 'days',
                  color: context.personaTint),
              _Divider(),
              _BigStat(
                  label: 'Year',
                  value: '$progress%',
                  unit: 'done'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        _section('WEEKLY HOURS BY SUBJECT'),
        const SizedBox(height: AppSpacing.sm),
        GlassmorphicCard(child: _buildWeeklyHoursBar(theme)),
        const SizedBox(height: AppSpacing.md),

        _section('SUBJECT DISTRIBUTION'),
        const SizedBox(height: AppSpacing.sm),
        GlassmorphicCard(child: _buildSubjectPie(theme)),
        const SizedBox(height: AppSpacing.md),

        _section('MOOD DISTRIBUTION'),
        const SizedBox(height: AppSpacing.sm),
        GlassmorphicCard(child: _buildMoodSection(theme)),
        const SizedBox(height: AppSpacing.md),

        _section('ACHIEVEMENT PACE (last 60d)'),
        const SizedBox(height: AppSpacing.sm),
        GlassmorphicCard(child: _buildUnlockPaceLine(theme)),
        const SizedBox(height: AppSpacing.md),

        _section('STUDY LOG'),
        const SizedBox(height: AppSpacing.sm),
        GlassmorphicCard(child: _buildStudyLogSection(theme)),
      ],
    );
  }

  Widget _section(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withAlpha(140),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ── Weekly hours bar chart ──────────────────────────────────────────────
  Widget _buildWeeklyHoursBar(ThemeData theme) {
    final scheduled = _scheduledMinutesPerSubject();
    final logged = StudyLogService.weeklyBreakdown();
    final subjects = {...scheduled.keys, ...logged.keys}.toList()
      ..sort((a, b) =>
          ((scheduled[b] ?? 0) + (logged[b] ?? 0))
              .compareTo((scheduled[a] ?? 0) + (logged[a] ?? 0)));
    if (subjects.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text('No schedule yet.',
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withAlpha(140))),
        ),
      );
    }
    final maxMin = subjects
        .map((s) => ((scheduled[s] ?? 0) + (logged[s] ?? 0)).toDouble())
        .fold<double>(60, (m, v) => v > m ? v : m);
    final tint = context.personaTint;
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxMin * 1.2,
          barGroups: [
            for (var i = 0; i < subjects.length && i < 6; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: (scheduled[subjects[i]] ?? 0).toDouble() +
                        (logged[subjects[i]] ?? 0).toDouble(),
                    rodStackItems: [
                      BarChartRodStackItem(
                        0,
                        (scheduled[subjects[i]] ?? 0).toDouble(),
                        tint.withAlpha(160),
                      ),
                      BarChartRodStackItem(
                        (scheduled[subjects[i]] ?? 0).toDouble(),
                        (scheduled[subjects[i]] ?? 0).toDouble() +
                            (logged[subjects[i]] ?? 0).toDouble(),
                        tint,
                      ),
                    ],
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, m) => Text(
                  '${(v / 60).toStringAsFixed(0)}h',
                  style: GoogleFonts.outfit(
                      fontSize: 9,
                      color: theme.colorScheme.onSurface.withAlpha(140)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, m) {
                  final i = v.toInt();
                  if (i < 0 || i >= subjects.length) {
                    return const SizedBox.shrink();
                  }
                  final name = subjects[i];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      name.length > 5 ? '${name.substring(0, 5)}…' : name,
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        color:
                            theme.colorScheme.onSurface.withAlpha(160),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  // ── Subject pie ─────────────────────────────────────────────────────────
  Widget _buildSubjectPie(ThemeData theme) {
    final sched = _scheduledMinutesPerSubject();
    if (sched.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text('No schedule yet.',
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withAlpha(140))),
        ),
      );
    }
    final total =
        sched.values.fold<int>(0, (sum, v) => sum + v).toDouble();
    final entries = sched.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final tint = context.personaTint;
    final colors = [
      tint,
      Color.alphaBlend(Colors.white.withAlpha(40), tint),
      Color.alphaBlend(Colors.black.withAlpha(40), tint),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
    ];
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  for (var i = 0; i < entries.length; i++)
                    PieChartSectionData(
                      value: entries[i].value.toDouble(),
                      color: colors[i % colors.length],
                      radius: 56,
                      title:
                          '${((entries[i].value / total) * 100).round()}%',
                      titleStyle: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < entries.length && i < 6; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entries[i].key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mood distribution ───────────────────────────────────────────────────
  Widget _buildMoodSection(ThemeData theme) {
    final days = _moodWindow == _MoodWindow.week ? 7 : 30;
    final counts = <int, int>{};
    final history = MoodService.history();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    for (final m in history) {
      if (m.date.isBefore(cutoff)) continue;
      counts[m.index] = (counts[m.index] ?? 0) + 1;
    }
    final tint = context.personaTint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final w in _MoodWindow.values)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(w == _MoodWindow.week ? '7d' : '30d'),
                  selected: _moodWindow == w,
                  onSelected: (_) => setState(() => _moodWindow = w),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (counts.isEmpty)
          Text('No mood data yet.',
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withAlpha(140)))
        else
          Row(
            children: List.generate(7, (i) {
              final c = counts[i] ?? 0;
              return Expanded(
                child: Column(
                  children: [
                    Text(MoodService.emojiFor(i),
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Container(
                      height: 6 + (c * 4).clamp(0, 48).toDouble(),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: c > 0
                            ? tint.withAlpha(40 + c * 15)
                            : (theme.dividerTheme.color ??
                                AppColors.surfaceBorder),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('$c',
                        style: GoogleFonts.outfit(
                            fontSize: 10,
                            color:
                                theme.colorScheme.onSurface.withAlpha(160))),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }

  // ── Unlock pace line chart ───────────────────────────────────────────────
  Widget _buildUnlockPaceLine(ThemeData theme) {
    final now = DateTime.now();
    final points = <FlSpot>[];
    var running = 0;
    // 60 daily buckets (backwards); running total at end of each day.
    final buckets = List<int>.filled(60, 0);
    for (final u in AchievementService.allUnlocks) {
      final diff = now.difference(u.unlockedAt).inDays;
      if (diff >= 0 && diff < 60) {
        buckets[59 - diff]++;
      }
    }
    for (var i = 0; i < 60; i++) {
      running += buckets[i];
      points.add(FlSpot(i.toDouble(), running.toDouble()));
    }
    if (points.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text('No unlocks yet.',
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withAlpha(140))),
        ),
      );
    }
    final tint = context.personaTint;
    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: true,
              barWidth: 2.5,
              color: tint,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [tint.withAlpha(80), tint.withAlpha(0)],
                ),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, m) => Text(
                  v.toInt().toString(),
                  style: GoogleFonts.outfit(
                      fontSize: 9,
                      color: theme.colorScheme.onSurface.withAlpha(140)),
                ),
              ),
            ),
            bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  // ── Study log section ────────────────────────────────────────────────────
  Widget _buildStudyLogSection(ThemeData theme) {
    final total = StudyLogService.totalMinutes();
    final sessions = StudyLogService.totalSessions();
    final thisWeek = StudyLogService.totalMinutesInWeekOf(DateTime.now());
    final recent = StudyLogService.all().take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ChipStat(label: 'Total', value: '${(total / 60).toStringAsFixed(1)}h'),
            const SizedBox(width: 6),
            _ChipStat(label: 'Sessions', value: '$sessions'),
            const SizedBox(width: 6),
            _ChipStat(label: 'This week', value: '${(thisWeek / 60).toStringAsFixed(1)}h'),
          ],
        ),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          Text('No sessions logged yet.',
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withAlpha(140)))
        else
          for (final s in recent)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_outlined, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 12),
                    ),
                  ),
                  Text('${s.minutes}m',
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withAlpha(160))),
                ],
              ),
            ),
      ],
    );
  }

  Widget _buildLogFab(BuildContext context) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.add_rounded),
      label: Text('Log study'),
      onPressed: () => _showLogSheet(context),
    );
  }

  Future<void> _showLogSheet(BuildContext context) async {
    final subjects = ScheduleService.getSubjects();
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add a subject first to log study time.',
              style: GoogleFonts.outfit(fontSize: 13)),
        ),
      );
      return;
    }
    Subject? selected = subjects.first;
    int minutes = 30;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log a study session',
                style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              DropdownButton<Subject>(
                isExpanded: true,
                value: selected,
                items: [
                  for (final s in subjects)
                    DropdownMenuItem(value: s, child: Text(s.name)),
                ],
                onChanged: (v) => setLocal(() => selected = v),
              ),
              const SizedBox(height: 8),
              Text('Duration: $minutes minutes'),
              Slider(
                value: minutes.toDouble(),
                min: 5,
                max: 300,
                divisions: 59,
                label: '$minutes min',
                onChanged: (v) => setLocal(() => minutes = v.toInt()),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  if (selected == null) return;
                  await StudyLogService.logSession(
                    subjectId: selected!.id,
                    subjectName: selected!.name,
                    minutes: minutes,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sum of scheduled class minutes per subject across Mon–Fri.
  Map<String, int> _scheduledMinutesPerSubject() {
    final sched = ScheduleService.getSchedule();
    final subs = ScheduleService.getSubjects();
    final byId = {for (final s in subs) s.id: s.name};
    final result = <String, int>{};
    for (final e in sched.entries) {
      final start = e.startTime.hour * 60 + e.startTime.minute;
      final end = e.endTime.hour * 60 + e.endTime.minute;
      final minutes = (end - start).abs();
      // For weekly aggregate, both WeekType.both and A+B double-count if
      // alternating; simplest is to count week A + both, but we show a
      // representative week so just count everything once.
      final name = byId[e.subjectId] ?? 'Unknown';
      result[name] = (result[name] ?? 0) + minutes;
    }
    return result;
  }
}

class _BigStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? color;

  const _BigStat({
    required this.label,
    required this.value,
    required this.unit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: color ?? theme.colorScheme.onSurface,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: GoogleFonts.outfit(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withAlpha(140),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withAlpha(170),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      height: 44,
      width: 1,
      color: Theme.of(context).dividerTheme.color);
}

class _ChipStat extends StatelessWidget {
  final String label;
  final String value;
  const _ChipStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.dividerTheme.color?.withAlpha(80),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withAlpha(160))),
          const SizedBox(width: 4),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
