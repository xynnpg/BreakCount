import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../app/constants.dart';
import '../models/school_year.dart';
import '../services/calendar_service.dart';
import '../services/storage_service.dart';
import '../widgets/break_timeline.dart';
import '../widgets/glassmorphic_card.dart';
import 'counter_tab_widgets.dart';

/// Next break / break-ends card with gradient accent stripe.
class CounterNextBreakCard extends StatelessWidget {
  final SchoolBreak next;
  final bool onBreak;

  const CounterNextBreakCard({
    super.key,
    required this.next,
    required this.onBreak,
  });

  @override
  Widget build(BuildContext context) {
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, Color(0xFFA0714F)],
                ),
                borderRadius: BorderRadius.horizontal(
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
                            letterSpacing: -1.5,
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
}

/// Stats row with gradient dividers.
class CounterStatsRow extends StatelessWidget {
  final Map<String, int> stats;

  const CounterStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
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
          const CounterGradientDivider(),
          CounterStatItem(
            label: 'Remaining',
            value: '${stats['daysRemaining']}',
            unit: 'days',
            valueColor: AppColors.primary,
          ),
          const CounterGradientDivider(),
          CounterStatItem(
            label: 'Week',
            value: '${stats['weekNumber']}',
            unit: 'of year',
          ),
        ],
      ),
    );
  }
}

/// Timeline section with the export button.
class CounterTimelineSection extends StatelessWidget {
  final SchoolYear schoolYear;

  const CounterTimelineSection({super.key, required this.schoolYear});

  @override
  Widget build(BuildContext context) {
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
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => CalendarService.exportBreaks(schoolYear),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.ios_share_rounded,
                      size: 15, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BreakTimeline(
            breaks: schoolYear.breaks,
            accentColor: accent,
          ),
        ],
      ),
    );
  }
}

/// No-data empty state with "Open Settings" CTA.
class CounterNoData extends StatelessWidget {
  const CounterNoData({super.key});

  @override
  Widget build(BuildContext context) {
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
                  gradient: const RadialGradient(
                    colors: [AppColors.primaryLight, Color(0xFFF5E8DC)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: const [AppElevation.low],
                ),
                child: const Icon(Icons.cloud_off_outlined,
                    size: 32, color: AppColors.primary),
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
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
