import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../app/constants.dart';
import '../app/persona_theme_ext.dart';
import '../data/persona_copy.dart';
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
    final tint = context.personaTint;
    final personaId =
        StorageService.getString(StorageKeys.widgetPersona) ?? 'hype';
    final daysToBreak = next.startDate.difference(DateTime.now()).inDays;
    final hint = PersonaCopy.get(
      personaId,
      'next_break_hint',
      vars: {'days': '$daysToBreak', 'name': next.name},
    );
    final theme = Theme.of(context);

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
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    tint,
                    Color.alphaBlend(Colors.white.withAlpha(60), tint),
                  ],
                ),
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
                              color: theme.colorScheme.onSurface.withAlpha(120),
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
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${fmt.format(next.startDate)} – ${fmt.format(next.endDate)}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withAlpha(120),
                            ),
                          ),
                          if (!onBreak && hint.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              hint,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: tint,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
                            color: tint,
                            height: 1,
                            letterSpacing: -1.5,
                          ),
                        ),
                        Text(
                          'days',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withAlpha(120),
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
    final theme = Theme.of(context);
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
                  color: theme.colorScheme.onSurface.withAlpha(120),
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => CalendarService.exportBreaks(schoolYear),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.ios_share_rounded,
                      size: 15, color: theme.colorScheme.primary),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  color: theme.colorScheme.primary.withAlpha(20),
                  shape: BoxShape.circle,
                  boxShadow: const [AppElevation.low],
                ),
                child: Icon(Icons.cloud_off_outlined,
                    size: 32, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No school data',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Go to Settings and refresh your\nschool calendar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: theme.colorScheme.onSurface.withAlpha(120),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                child: Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
