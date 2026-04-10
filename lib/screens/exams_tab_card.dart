import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/exam.dart';
import '../services/subject_importance_service.dart';
import '../widgets/glassmorphic_card.dart';

// ── Importance color helper ───────────────────────────────────────────────────

extension ImportanceStyling on SubjectImportance {
  Color get color {
    switch (this) {
      case SubjectImportance.critical:
        return AppColors.error;
      case SubjectImportance.high:
        return AppColors.warning;
      case SubjectImportance.medium:
        return AppColors.primary;
      case SubjectImportance.low:
        return AppColors.textTertiary;
    }
  }
}

// ── Exam Card ─────────────────────────────────────────────────────────────────

class ExamCard extends StatelessWidget {
  final Exam exam;
  final SubjectImportance importance;
  final bool isPast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onExport;
  final int animationDelay;

  const ExamCard({
    super.key,
    required this.exam,
    required this.importance,
    this.isPast = false,
    required this.onEdit,
    required this.onDelete,
    this.onExport,
    this.animationDelay = 0,
  });

  int get _daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(exam.date.year, exam.date.month, exam.date.day);
    return examDay.difference(today).inDays;
  }

  String get _dateLabel {
    final d = exam.date;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final color = isPast ? AppColors.textTertiary : importance.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onLongPress: onEdit,
        child: GlassmorphicCard(
          animate: animationDelay >= 0,
          animationDelay: animationDelay,
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent stripe — gradient top→bottom
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color, Color.lerp(color, const Color(0xFFA0714F), 0.5)!],
                    ),
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(AppRadius.lg)),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (exam.subjectName != null &&
                                  exam.subjectName!.isNotEmpty)
                                Text(
                                  exam.subjectName!,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isPast
                                        ? AppColors.textTertiary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              if (exam.title.isNotEmpty &&
                                  exam.title != exam.subjectName)
                                Text(
                                  exam.title,
                                  style: GoogleFonts.outfit(
                                    fontSize:
                                        exam.subjectName != null ? 12 : 15,
                                    fontWeight: exam.subjectName != null
                                        ? FontWeight.w400
                                        : FontWeight.w700,
                                    color: isPast
                                        ? AppColors.textTertiary
                                        : (exam.subjectName != null
                                            ? AppColors.textSecondary
                                            : AppColors.textPrimary),
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  ExamTypeBadge(
                                      label: exam.type.label, color: color),
                                  const SizedBox(width: 6),
                                  Text(
                                    _dateLabel,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  if (exam.date.hour != 0 ||
                                      exam.date.minute != 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '${exam.date.hour.toString().padLeft(2, '0')}:${exam.date.minute.toString().padLeft(2, '0')}',
                                      style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          color: AppColors.textTertiary),
                                    ),
                                  ],
                                  if (exam.room != null &&
                                      exam.room!.isNotEmpty) ...[
                                    const SizedBox(width: 5),
                                    const Icon(Icons.room_outlined,
                                        size: 11,
                                        color: AppColors.textTertiary),
                                    Text(
                                      exam.room!,
                                      style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          color: AppColors.textTertiary),
                                    ),
                                  ],
                                ],
                              ),
                              if (!isPast &&
                                  importance == SubjectImportance.critical)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withAlpha(18),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color:
                                              AppColors.error.withAlpha(60)),
                                    ),
                                    child: Text(
                                      'HIGH PRIORITY',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.error,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Right: days badge + actions
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ExamDaysBadge(
                              daysLeft: _daysLeft,
                              color: color,
                              isPast: isPast,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (!isPast && onExport != null)
                                  GestureDetector(
                                    onTap: onExport,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                          Icons.calendar_month_outlined,
                                          size: 16,
                                          color: AppColors.primary
                                              .withAlpha(160)),
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: onEdit,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(Icons.edit_outlined,
                                        size: 16,
                                        color: AppColors.textTertiary),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: onDelete,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                        color:
                                            AppColors.error.withAlpha(180)),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}

// ── Days Badge ────────────────────────────────────────────────────────────────

class ExamDaysBadge extends StatelessWidget {
  final int daysLeft;
  final Color color;
  final bool isPast;

  const ExamDaysBadge({
    super.key,
    required this.daysLeft,
    required this.color,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(60)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isPast && daysLeft > 0)
            Text(
              '$daysLeft',
              style: GoogleFonts.outfit(
                fontSize: daysLeft > 99 ? 14 : 18,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1,
              ),
            ),
          Text(
            isPast
                ? 'done'
                : daysLeft == 0
                    ? 'today'
                    : daysLeft == 1
                        ? '1 day'
                        : 'days',
            style: GoogleFonts.outfit(
              fontSize: isPast || daysLeft == 0 ? 11 : 9,
              color: color,
              fontWeight:
                  isPast || daysLeft == 0 ? FontWeight.w600 : FontWeight.w400,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Type Badge ────────────────────────────────────────────────────────────────

class ExamTypeBadge extends StatelessWidget {
  final String label;
  final Color color;

  const ExamTypeBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
