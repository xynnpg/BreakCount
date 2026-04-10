import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import '../services/schedule_service.dart';
import '../services/storage_service.dart';
import '../services/subject_importance_service.dart';
import 'exams_tab_card.dart';
import 'exams_tab_pickers.dart'; // ExamSubjectPicker, ExamTypePicker, ExamFormLabel, ExamFormField

// ── Add / Edit Form ───────────────────────────────────────────────────────────

class ExamFormSheet extends StatefulWidget {
  final Exam? existing;
  final String country;

  const ExamFormSheet({super.key, this.existing, required this.country});

  @override
  State<ExamFormSheet> createState() => _ExamFormSheetState();
}

class _ExamFormSheetState extends State<ExamFormSheet> {
  late TextEditingController _subjectCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _roomCtrl;
  late ExamType _type;
  late DateTime _date;
  late TimeOfDay _time;
  List<Subject> _subjects = [];

  SubjectImportance get _importance =>
      SubjectImportanceService.getImportance(
          _subjectCtrl.text.trim(), widget.country,
          profileId: StorageService.getString(StorageKeys.schoolProfile));

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _subjectCtrl = TextEditingController(text: e?.subjectName ?? '');
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _roomCtrl = TextEditingController(text: e?.room ?? '');
    _type = e?.type ?? ExamType.quiz;
    final base = e?.date ?? DateTime.now().add(const Duration(days: 7));
    _date = base;
    _time = (e != null && (e.date.hour != 0 || e.date.minute != 0))
        ? TimeOfDay(hour: e.date.hour, minute: e.date.minute)
        : const TimeOfDay(hour: 9, minute: 0);
    _subjects = ScheduleService.getSubjects();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _titleCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    final subject = _subjectCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    if (subject.isEmpty && title.isEmpty) return;
    final examDateTime = DateTime(
        _date.year, _date.month, _date.day, _time.hour, _time.minute);
    final exam = Exam(
      id: widget.existing?.id ??
          'exam_${DateTime.now().millisecondsSinceEpoch}',
      title: title.isEmpty ? subject : title,
      type: _type,
      date: examDateTime,
      subjectName: subject.isEmpty ? null : subject,
      room: _roomCtrl.text.trim().isEmpty ? null : _roomCtrl.text.trim(),
      notes: null,
    );
    Navigator.pop(context, exam);
  }

  String get _dateLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[_date.month - 1]} ${_date.day}, ${_date.year}';
  }

  String get _timeLabel {
    final h = _time.hour.toString().padLeft(2, '0');
    final m = _time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _daysAwayHint {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(_date.year, _date.month, _date.day);
    final diff = examDay.difference(today).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'tomorrow';
    if (diff < 0) return '${diff.abs()} days ago';
    return '$diff days away';
  }

  @override
  Widget build(BuildContext context) {
    final imp = _importance;
    final impColor = imp.color;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 3,
                  margin: const EdgeInsets.only(top: 4, bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.existing == null ? 'Add Exam' : 'Edit Exam',
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 18),
              if (_subjects.isNotEmpty)
                ExamSubjectPicker(
                  subjects: _subjects,
                  selectedName: _subjectCtrl.text.trim(),
                  importanceLabel: imp.label,
                  importanceColor: impColor,
                  onSelect: (name) => setState(() => _subjectCtrl.text = name),
                  onClear: () => setState(() => _subjectCtrl.clear()),
                )
              else
                ExamFormField(
                  controller: _subjectCtrl,
                  label: 'Subject',
                  hint: 'e.g. Mathematics, Physics',
                  onChanged: (_) => setState(() {}),
                  suffix: _subjectCtrl.text.trim().isNotEmpty
                      ? ExamTypeBadge(label: imp.label, color: impColor)
                      : null,
                ),
              const SizedBox(height: 14),
              ExamFormField(
                controller: _titleCtrl,
                label: 'Description (optional)',
                hint: 'e.g. Chapter 5 test, Final exam',
              ),
              const SizedBox(height: 14),
              ExamTypePicker(
                selectedType: _type,
                onSelect: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 14),
              ExamFormLabel('Date'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 9),
                      Text(
                        _dateLabel,
                        style: GoogleFonts.outfit(
                            color: AppColors.textPrimary, fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        _daysAwayHint,
                        style: GoogleFonts.outfit(
                            color: AppColors.textTertiary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ExamFormLabel('Time'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 9),
                      Text(
                        _timeLabel,
                        style: GoogleFonts.outfit(
                            color: AppColors.textPrimary, fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        'Notified 24h & 1h before',
                        style: GoogleFonts.outfit(
                            color: AppColors.textTertiary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ExamFormField(
                controller: _roomCtrl,
                label: 'Room (optional)',
                hint: 'e.g. Room 204',
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    widget.existing == null ? 'Add Exam' : 'Save Changes',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

