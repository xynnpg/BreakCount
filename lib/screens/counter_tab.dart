import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app/constants.dart';
import '../models/school_year.dart';
import '../services/school_data_service.dart';
import '../services/calculator_service.dart';
import '../services/achievement_service.dart';
import '../widgets/achievement_unlock_overlay.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/current_class_card.dart';
import 'counter_tab_widgets.dart';
import 'counter_tab_cards.dart';
import 'counter_progress_ring.dart';
import 'counter_personality_card.dart';
import 'counter_achievements_section.dart';


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
    }
    _checkAppOpenAchievements();
  }

  Future<void> _checkAchievements(dynamic schoolYear) async {
    final newIds = await AchievementService.checkSchoolProgress(schoolYear);
    for (final id in newIds) {
      if (mounted) {
        await AchievementUnlockOverlay.show(context, id);
      }
    }
  }

  Future<void> _checkAppOpenAchievements() async {
    final newIds = await AchievementService.recordAppOpen();
    for (final id in newIds) {
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
                        PersonalityCard(
                          daysUntilBreak: _days,
                          isOnBreak: onBreak,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const CounterAchievementsSection(),
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
