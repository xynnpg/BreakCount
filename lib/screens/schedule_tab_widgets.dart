import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/schedule.dart';

// ── Schedule Header ───────────────────────────────────────────────────────────

class ScheduleHeader extends StatelessWidget {
  final Schedule schedule;
  final WeekType currentWeek;
  final VoidCallback onToggleWeek;
  final VoidCallback onScanPhoto;
  final VoidCallback onAdd;

  const ScheduleHeader({
    super.key,
    required this.schedule,
    required this.currentWeek,
    required this.onToggleWeek,
    required this.onScanPhoto,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.scaffoldBg,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
                if (schedule.entries.isNotEmpty)
                  Text(
                    '${schedule.entries.length} classes',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            if (schedule.useAlternatingWeeks) ...[
              _WeekPill(currentWeek: currentWeek, onToggle: onToggleWeek),
              const SizedBox(width: AppSpacing.xs),
            ],
            Tooltip(
              message: 'Scan photo',
              child: IconButton(
                icon: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.textSecondary, size: 22),
                onPressed: onScanPhoto,
                splashRadius: 20,
              ),
            ),
            _AddButton(onTap: onAdd),
          ],
        ),
      ),
    );
  }
}

class _WeekPill extends StatelessWidget {
  final WeekType currentWeek;
  final VoidCallback onToggle;

  const _WeekPill({required this.currentWeek, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.primary.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentWeek.label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.swap_horiz_rounded,
                size: 13, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.only(left: 4, right: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(70),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class ScheduleEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onScanPhoto;

  const ScheduleEmptyState(
      {super.key, required this.onAdd, required this.onScanPhoto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.grid_view_rounded,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No classes yet',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add manually or scan your\nprinted timetable with AI.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Subject'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg)),
                  textStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onScanPhoto,
                icon: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.textSecondary, size: 18),
                label: Text(
                  'Scan Timetable Photo',
                  style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
