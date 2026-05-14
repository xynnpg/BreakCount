import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import 'exams_tab_card.dart';

// ── Subject picker ────────────────────────────────────────────────────────────

class ExamSubjectPicker extends StatelessWidget {
  final List<Subject> subjects;
  final String selectedName;
  final String importanceLabel;
  final Color importanceColor;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  const ExamSubjectPicker({
    super.key,
    required this.subjects,
    required this.selectedName,
    required this.importanceLabel,
    required this.importanceColor,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExamFormLabel('Subject'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: subjects.map((s) {
              final sel = selectedName == s.name;
              final subjectColor = Color(s.colorValue);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(s.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? subjectColor.withAlpha(18) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? subjectColor : (Theme.of(context).dividerTheme.color ?? AppColors.surfaceBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              color: subjectColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          s.name,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: sel
                                ? subjectColor
                                : Theme.of(context).colorScheme.onSurface.withAlpha(200),
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (selectedName.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                selectedName,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(180)),
              ),
              const SizedBox(width: 6),
              ExamTypeBadge(label: importanceLabel, color: importanceColor),
              const Spacer(),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded,
                    size: 16, color: theme.colorScheme.onSurface.withAlpha(120)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Type picker ───────────────────────────────────────────────────────────────

class ExamTypePicker extends StatelessWidget {
  final ExamType selectedType;
  final ValueChanged<ExamType> onSelect;

  const ExamTypePicker(
      {super.key, required this.selectedType, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExamFormLabel('Type'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ExamType.values.map((t) {
              final sel = selectedType == t;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? theme.colorScheme.primary.withAlpha(18) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel
                            ? theme.colorScheme.primary
                            : (theme.dividerTheme.color ?? AppColors.surfaceBorder),
                      ),
                    ),
                    child: Text(
                      t.label,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: sel
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withAlpha(200),
                        fontWeight:
                            sel ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Form helpers ──────────────────────────────────────────────────────────────

class ExamFormLabel extends StatelessWidget {
  final String text;
  const ExamFormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 11,
        color: theme.colorScheme.onSurface.withAlpha(120),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class ExamFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const ExamFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExamFormLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerTheme.color ?? AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: GoogleFonts.outfit(
                      color: theme.colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.outfit(
                        color: theme.colorScheme.onSurface.withAlpha(120), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                  ),
                ),
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: suffix!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
