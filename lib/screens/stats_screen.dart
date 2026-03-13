import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/school_year.dart';
import '../services/school_data_service.dart';
import '../services/calculator_service.dart';
import '../services/exam_service.dart';
import '../widgets/glassmorphic_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  SchoolYear? _sy;
  Map<String, int> _stats = {};
  int _totalBreaks = 0;
  int _pastBreaks = 0;
  int _futureBreaks = 0;
  int _totalBreakDays = 0;
  int _daysUntilSummer = 0;
  int _upcomingExams = 0;
  int _totalExams = 0;
  int _daysUntilNextBreak = 0;
  String _nextBreakName = '—';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final sy = SchoolDataService.getCached();
    if (sy == null) return;
    final stats = CalculatorService.getDayStats(sy);
    final nextBreak = CalculatorService.nextBreak(sy);
    final now = DateTime.now();

    final totalBreakDays = sy.breaks
        .fold<int>(0, (sum, b) => sum + b.durationDays);
    final pastB = sy.breaks.where((b) => b.isPast).length;
    final futureB = sy.breaks.where((b) => b.isFuture).length;
    final daysUntilSummer =
        sy.endDate.isAfter(now) ? sy.endDate.difference(now).inDays : 0;
    final daysUntilNext =
        nextBreak == null || nextBreak.isActive
            ? 0
            : nextBreak.startDate.difference(now).inDays;

    final upcoming = ExamService.getUpcoming();
    final allExams = ExamService.getExams();

    setState(() {
      _sy = sy;
      _stats = stats;
      _totalBreaks = sy.breaks.length;
      _pastBreaks = pastB;
      _futureBreaks = futureB;
      _totalBreakDays = totalBreakDays;
      _daysUntilSummer = daysUntilSummer;
      _daysUntilNextBreak = daysUntilNext;
      _nextBreakName = nextBreak?.name ?? '—';
      _upcomingExams = upcoming.length;
      _totalExams = allExams.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 15, color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'Statistics',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (_sy == null)
                      _buildNoData()
                    else
                      _buildContent(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Icon(Icons.bar_chart_rounded,
                size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              'No school data yet',
              style: GoogleFonts.outfit(
                  color: AppColors.textTertiary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final progress = (_sy!.yearProgress * 100).round();
    return Column(
      children: [
        // School days row
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
                  color: AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Progress + week
        GlassmorphicCard(
          child: Row(
            children: [
              _BigStat(
                  label: 'Year Progress',
                  value: '$progress%',
                  unit: 'complete',
                  color: AppColors.primary),
              _Divider(),
              _BigStat(
                  label: 'Current Week',
                  value: '${_stats['weekNumber'] ?? 0}',
                  unit: 'of year'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Breaks grid
        _SectionHeader('School Breaks'),
        const SizedBox(height: AppSpacing.sm),
        GlassmorphicCard(
          child: Row(
            children: [
              _BigStat(
                  label: 'Total Breaks',
                  value: '$_totalBreaks',
                  unit: 'this year'),
              _Divider(),
              _BigStat(
                  label: 'Passed',
                  value: '$_pastBreaks',
                  unit: 'done',
                  color: AppColors.success),
              _Divider(),
              _BigStat(
                  label: 'Upcoming',
                  value: '$_futureBreaks',
                  unit: 'ahead',
                  color: AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        GlassmorphicCard(
          child: Row(
            children: [
              _BigStat(
                  label: 'Total Break Days',
                  value: '$_totalBreakDays',
                  unit: 'days off'),
              _Divider(),
              _BigStat(
                  label: 'Next Break In',
                  value: '$_daysUntilNextBreak',
                  unit: _nextBreakName,
                  color: AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Summer countdown
        _SectionHeader('Milestones'),
        const SizedBox(height: AppSpacing.sm),
        GlassmorphicCard(
          child: Row(
            children: [
              _BigStat(
                  label: 'Days Until Summer',
                  value: '$_daysUntilSummer',
                  unit: 'days',
                  color: AppColors.warning),
              _Divider(),
              _BigStat(
                  label: 'Exams Upcoming',
                  value: '$_upcomingExams',
                  unit: 'of $_totalExams total',
                  color: AppColors.error),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 1.5,
        ),
      ),
    );
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color ?? AppColors.textPrimary,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 44, width: 1, color: AppColors.surfaceBorder);
}
