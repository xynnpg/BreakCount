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
  int _days = 0, _hours = 0, _minutes = 0, _seconds = 0;

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
    }
  }

  void _startTimer() {
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateCountdown();
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

  @override
  void dispose() {
    _timer?.cancel();
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
                    if (!yearOver)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFDF8F5),
                              Color(0xFFFAF3EC),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                              color: Color(0xFFEDD9C8), width: 1),
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
                      ),
                    if (yearOver) _buildYearOverBadge(),
                    const SizedBox(height: AppSpacing.xxl),
                    if (!yearOver)
                      ProgressRing(
                        progress: sy.yearProgress,
                        size: 176,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(sy.yearProgress * 100).round()}%',
                              style: GoogleFonts.outfit(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'School Year',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
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
          _PulsingDot(color: color, pulse: onBreak),
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
          _StatItem(
            label: 'Survived',
            value: '${stats['daysSurvived']}',
            unit: 'days',
            valueColor: AppColors.success,
          ),
          Container(height: 44, width: 1, color: AppColors.surfaceBorder),
          _StatItem(
            label: 'Remaining',
            value: '${stats['daysRemaining']}',
            unit: 'days',
            valueColor: AppColors.primary,
          ),
          Container(height: 44, width: 1, color: AppColors.surfaceBorder),
          _StatItem(
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  const _StatItem(
      {required this.label, required this.value, required this.unit, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style:
                GoogleFonts.outfit(fontSize: 10, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final bool pulse;
  const _PulsingDot({required this.color, this.pulse = false});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 2.6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0.55, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.pulse) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(_PulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_ctrl.isAnimating) _ctrl.repeat();
    if (!widget.pulse && _ctrl.isAnimating) _ctrl.stop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.pulse)
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => Transform.scale(
                scale: _scale.value,
                child: Opacity(
                  opacity: _fade.value,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: widget.color, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: widget.color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
