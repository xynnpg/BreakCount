import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app/constants.dart';
import '../models/school_year.dart';
import '../services/storage_service.dart';
import '../services/school_data_service.dart';
import '../services/calculator_service.dart';
import '../services/calendar_service.dart';
import '../widgets/animated_counter.dart';
import '../widgets/progress_ring.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/break_timeline.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/current_class_card.dart';
import 'counter_tab_widgets.dart';

enum _RingMode { percent, days, hours, minutes, seconds, milliseconds }

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

  // Ring centre cycling
  _RingMode _ringMode = _RingMode.percent;
  String _ringValue = '';
  String _ringLabel = '';

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
    }
  }

  void _startTimer() {
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateCountdown();
        if (_ringMode != _RingMode.milliseconds) _updateRingValue();
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
    final next = _RingMode.values[(_ringMode.index + 1) % _RingMode.values.length];
    _msTicker?.cancel();
    _msTicker = null;
    setState(() => _ringMode = next);
    _updateRingValue();
    if (next == _RingMode.milliseconds) {
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
      case _RingMode.percent:
        value = '${(sy.yearProgress * 100).round()}%';
        label = 'School Year';
        break;
      case _RingMode.days:
        value = '$activeDays';
        label = 'school days left';
        break;
      case _RingMode.hours:
        value = _fmt(activeDays * _schoolHoursPerDay);
        label = 'school hours left';
        break;
      case _RingMode.minutes:
        value = _fmt(activeDays * _schoolHoursPerDay * 60);
        label = 'minutes left';
        break;
      case _RingMode.seconds:
        value = _fmt(activeDays * _schoolHoursPerDay * 3600);
        label = 'seconds left';
        break;
      case _RingMode.milliseconds:
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
    if (_schoolYear == null) return _buildNoData();
    return _buildContent();
  }

  Widget _buildNoData() {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_off_outlined,
                    size: 34, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No school data',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Go to Settings and refresh your\nschool calendar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final sy = _schoolYear!;
    final next = CalculatorService.nextBreak(sy);
    final onBreak = CalculatorService.isOnBreak(sy);
    final yearOver = CalculatorService.isYearOver(sy);
    final stats = CalculatorService.getDayStats(sy);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x0C6F4E37), Colors.transparent],
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
                        _buildStatusBadge(onBreak, yearOver, next),
                        const SizedBox(height: AppSpacing.lg),
                        const CurrentClassCard(),
                        const SizedBox(height: AppSpacing.lg),
                        if (!yearOver) _buildCountdownCard(),
                        if (yearOver) _buildYearOverBadge(),
                        const SizedBox(height: AppSpacing.xxl),
                        if (!yearOver) _buildProgressRing(sy),
                        const SizedBox(height: AppSpacing.xl),
                        if (next != null)
                          _buildNextBreakCard(next, onBreak),
                        const SizedBox(height: AppSpacing.md),
                        _buildStatsRow(stats),
                        const SizedBox(height: AppSpacing.lg),
                        _buildTimelineSection(sy),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(SchoolYear sy) {
    final isPercent = _ringMode == _RingMode.percent;
    final valueSize = isPercent ? 30.0 : _ringMode == _RingMode.milliseconds ? 18.0 : 24.0;

    return GestureDetector(
      onTap: _cycleRingMode,
      child: ProgressRing(
        progress: sy.yearProgress,
        size: 176,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                _ringValue.isEmpty
                    ? '${(sy.yearProgress * 100).round()}%'
                    : _ringValue,
                key: ValueKey(_ringValue + _ringMode.name),
                style: GoogleFonts.outfit(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _ringLabel.isEmpty ? 'School Year' : _ringLabel,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Icon(Icons.touch_app_outlined,
                size: 10, color: AppColors.textTertiary.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF8F5), Color(0xFFFAF3EC)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFFEDD9C8), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A6F4E37),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x056F4E37),
            blurRadius: 48,
            spreadRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'COUNTDOWN',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedCounter(
            days: _days,
            hours: _hours,
            minutes: _minutes,
            seconds: _seconds,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool onBreak, bool yearOver, SchoolBreak? next) {
    String label;
    Color color;
    if (yearOver) {
      label = 'School year complete';
      color = AppColors.success;
    } else if (onBreak) {
      final active = _schoolYear!.breaks.firstWhere((b) => b.isActive);
      label = '${active.name} — enjoy it!';
      color = AppColors.primary;
    } else if (next != null) {
      label = 'Until ${next.name}';
      color = AppColors.textSecondary;
    } else {
      label = 'Until end of school year';
      color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.surfaceBorder),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CounterPulsingDot(color: color, pulse: onBreak),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearOverBadge() {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Column(
        children: [
          Text(
            'See you next year!',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'School year is complete.',
            style: GoogleFonts.outfit(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextBreakCard(SchoolBreak next, bool onBreak) {
    final fmt = DateFormat('d MMM yyyy');
    return GlassmorphicCard(
      animationDelay: 80,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.lg)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            onBreak ? 'BREAK ENDS' : 'NEXT BREAK',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            next.name,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${fmt.format(next.startDate)} – ${fmt.format(next.endDate)}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${next.durationDays}',
                          style: GoogleFonts.outfit(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            height: 1,
                          ),
                        ),
                        Text(
                          'days',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    return GlassmorphicCard(
      animationDelay: 160,
      child: Row(
        children: [
          CounterStatItem(
            label: 'Survived',
            value: '${stats['daysSurvived']}',
            unit: 'days',
            valueColor: AppColors.success,
          ),
          Container(height: 44, width: 1, color: AppColors.surfaceBorder),
          CounterStatItem(
            label: 'Remaining',
            value: '${stats['daysRemaining']}',
            unit: 'days',
            valueColor: AppColors.primary,
          ),
          Container(height: 44, width: 1, color: AppColors.surfaceBorder),
          CounterStatItem(
            label: 'Week',
            value: '${stats['weekNumber']}',
            unit: 'of year',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(SchoolYear sy) {
    final accent =
        Color(StorageService.getInt(StorageKeys.accentColor) ?? 0xFF6F4E37);
    return GlassmorphicCard(
      animationDelay: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ALL BREAKS',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => CalendarService.exportBreaks(sy),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_month_outlined,
                      size: 15, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BreakTimeline(
            breaks: sy.breaks,
            accentColor: accent,
          ),
        ],
      ),
    );
  }
}
