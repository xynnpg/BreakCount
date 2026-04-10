import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/school_year.dart';
import '../app/constants.dart';

/// Vertical timeline of school breaks. Current position glows.
class BreakTimeline extends StatelessWidget {
  final List<SchoolBreak> breaks;
  final Color accentColor;

  const BreakTimeline({
    super.key,
    required this.breaks,
    this.accentColor = AppColors.primaryPurple,
  });

  @override
  Widget build(BuildContext context) {
    if (breaks.isEmpty) {
      return Center(
        child: Text(
          'No breaks scheduled',
          style: GoogleFonts.outfit(color: AppColors.textTertiary),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: breaks.length,
      itemBuilder: (context, index) {
        final breakItem = breaks[index];
        final isLast = index == breaks.length - 1;
        final isActive = breakItem.isActive;
        final isPast = breakItem.isPast;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    _TimelineDot(
                      isActive: isActive,
                      isPast: isPast,
                      accentColor: accentColor,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isPast
                              ? accentColor.withAlpha(40)
                              : AppColors.surfaceBorder,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : AppSpacing.lg,
                  ),
                  child: _BreakCard(
                    breakItem: breakItem,
                    isActive: isActive,
                    isPast: isPast,
                    accentColor: accentColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final bool isActive;
  final bool isPast;
  final Color accentColor;

  const _TimelineDot({
    required this.isActive,
    required this.isPast,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Container(
        width: 16,
        height: 16,
        margin: const EdgeInsets.only(top: 4, left: 12),
        decoration: BoxDecoration(
          color: accentColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accentColor.withAlpha(160),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    }
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(top: 7, left: 15),
      decoration: BoxDecoration(
        color: isPast ? accentColor.withAlpha(100) : AppColors.surfaceBorder,
        shape: BoxShape.circle,
        border: Border.all(
          color: isPast ? accentColor.withAlpha(60) : AppColors.surfaceBorder,
        ),
      ),
    );
  }
}

class _BreakCard extends StatelessWidget {
  final SchoolBreak breakItem;
  final bool isActive;
  final bool isPast;
  final Color accentColor;

  const _BreakCard({
    required this.breakItem,
    required this.isActive,
    required this.isPast,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM');
    final dateRange =
        '${fmt.format(breakItem.startDate)} – ${fmt.format(breakItem.endDate)}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? accentColor.withAlpha(20)
            : (isPast ? AppColors.scaffoldBg : Colors.white),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isActive
              ? accentColor.withAlpha(80)
              : AppColors.surfaceBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  breakItem.name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPast
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  dateRange,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(
            breakItem: breakItem,
            isActive: isActive,
            isPast: isPast,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SchoolBreak breakItem;
  final bool isActive;
  final bool isPast;
  final Color accentColor;

  const _StatusBadge({
    required this.breakItem,
    required this.isActive,
    required this.isPast,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: accentColor.withAlpha(60),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          'NOW',
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: accentColor,
            letterSpacing: 1,
          ),
        ),
      );
    }
    if (isPast) {
      return Text(
        '${breakItem.durationDays}d',
        style: GoogleFonts.outfit(
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
      );
    }
    final daysAway = breakItem.startDate.difference(DateTime.now()).inDays;
    return Text(
      'in ${daysAway}d',
      style: GoogleFonts.outfit(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }
}
