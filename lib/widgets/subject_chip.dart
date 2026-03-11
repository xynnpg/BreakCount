import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/subject.dart';
import '../app/constants.dart';

/// A colored pill chip representing a subject.
class SubjectChip extends StatelessWidget {
  final Subject subject;
  final bool selected;
  final VoidCallback? onTap;
  final bool showTeacher;

  const SubjectChip({
    super.key,
    required this.subject,
    this.selected = false,
    this.onTap,
    this.showTeacher = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(subject.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.microInteraction,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(60) : color.withAlpha(30),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? color : color.withAlpha(80),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              subject.name,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? color : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (showTeacher && subject.teacher != null) ...[
              const SizedBox(width: 4),
              Text(
                '• ${subject.teacher}',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
