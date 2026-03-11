import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import '../services/exam_service.dart';
import '../services/schedule_service.dart';
import '../services/storage_service.dart';
import '../services/subject_importance_service.dart';
import '../widgets/glassmorphic_card.dart';

class ExamsTab extends StatefulWidget {
  const ExamsTab({super.key});

  @override
  State<ExamsTab> createState() => _ExamsTabState();
}

class _ExamsTabState extends State<ExamsTab> {
  List<Exam> _upcoming = [];
  List<Exam> _past = [];
  bool _showPast = false;

  String get _country =>
      StorageService.getString(StorageKeys.selectedCountry) ?? '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _upcoming = ExamService.getUpcoming();
      _past = ExamService.getPast();
    });
  }

  SubjectImportance _importance(Exam exam) {
    final name = exam.subjectName ?? exam.title;
    return SubjectImportanceService.getImportance(name, _country);
  }

  Future<void> _openAddEdit({Exam? existing}) async {
    final result = await showModalBottomSheet<Exam>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExamFormSheet(existing: existing, country: _country),
    );
    if (result != null) {
      if (existing == null) {
        await ExamService.addExam(result);
      } else {
        await ExamService.updateExam(result);
      }
      _reload();
    }
  }

  Future<void> _delete(Exam exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete exam?'),
        content: Text(exam.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.outfit(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ExamService.deleteExam(exam.id);
      _reload();
    }
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
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exams',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.8,
                            ),
                          ),
                          Text(
                            'Tests & Assessments',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openAddEdit(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(60),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_upcoming.isEmpty && _past.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(onAdd: () => _openAddEdit()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_upcoming.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'No upcoming exams',
                        style: GoogleFonts.outfit(
                            color: AppColors.textTertiary, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ..._upcoming.asMap().entries.map((entry) => _ExamCard(
                        exam: entry.value,
                        importance: _importance(entry.value),
                        onEdit: () => _openAddEdit(existing: entry.value),
                        onDelete: () => _delete(entry.value),
                        animationDelay: entry.key * 60,
                      )),
                  if (_past.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showPast = !_showPast),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Past (${_past.length})',
                              style: GoogleFonts.outfit(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showPast
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textTertiary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showPast) ...[
                      const SizedBox(height: 10),
                      ..._past.map((exam) => _ExamCard(
                            exam: exam,
                            importance: _importance(exam),
                            isPast: true,
                            onEdit: () => _openAddEdit(existing: exam),
                            onDelete: () => _delete(exam),
                          )),
                    ],
                  ],
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Importance styling ────────────────────────────────────────────────────────

extension _ImportanceStyling on SubjectImportance {
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

  // hasGlow removed — no longer used in light theme
}

// ── Exam Card ─────────────────────────────────────────────────────────────────

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final SubjectImportance importance;
  final bool isPast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int animationDelay;

  const _ExamCard({
    required this.exam,
    required this.importance,
    this.isPast = false,
    required this.onEdit,
    required this.onDelete,
    this.animationDelay = 0,
  });

  int get _daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay =
        DateTime(exam.date.year, exam.date.month, exam.date.day);
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
                // Left accent stripe
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(AppRadius.lg)),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
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
                                    fontSize: exam.subjectName != null
                                        ? 12
                                        : 15,
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
                                  _Badge(label: exam.type.label, color: color),
                                  const SizedBox(width: 6),
                                  Text(
                                    _dateLabel,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
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
                                  child: Text(
                                    'HIGH PRIORITY',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.error,
                                      letterSpacing: 1.2,
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
                            _DaysBadge(
                              daysLeft: _daysLeft,
                              color: color,
                              isPast: isPast,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
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
                                        color: AppColors.error
                                            .withAlpha(180)),
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

class _DaysBadge extends StatelessWidget {
  final int daysLeft;
  final Color color;
  final bool isPast;

  const _DaysBadge({
    required this.daysLeft,
    required this.color,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(60)),
      ),
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(4),
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

// ── Add / Edit Form ───────────────────────────────────────────────────────────

class _ExamFormSheet extends StatefulWidget {
  final Exam? existing;
  final String country;

  const _ExamFormSheet({this.existing, required this.country});

  @override
  State<_ExamFormSheet> createState() => _ExamFormSheetState();
}

class _ExamFormSheetState extends State<_ExamFormSheet> {
  late TextEditingController _subjectCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _roomCtrl;
  late ExamType _type;
  late DateTime _date;
  late TimeOfDay _time;
  List<Subject> _subjects = [];

  SubjectImportance get _importance =>
      SubjectImportanceService.getImportance(
          _subjectCtrl.text.trim(), widget.country);

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
    // Default to 09:00 so the "1 hour before" notification fires at 08:00 AM.
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
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.existing == null ? 'Add Exam' : 'Edit Exam',
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 18),
              if (_subjects.isNotEmpty) ...[
                _FormLabel('Subject'),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _subjects.map((s) {
                      final sel = _subjectCtrl.text.trim() == s.name;
                      final subjectColor = Color(s.colorValue);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _subjectCtrl.text = s.name),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? subjectColor.withAlpha(18)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: sel
                                    ? subjectColor
                                    : AppColors.surfaceBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                      color: subjectColor,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  s.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: sel
                                        ? subjectColor
                                        : AppColors.textSecondary,
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.w400,
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
                if (_subjectCtrl.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _subjectCtrl.text.trim(),
                        style: GoogleFonts.outfit(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 6),
                      _Badge(label: imp.label, color: impColor),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _subjectCtrl.clear()),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ] else
                _Field(
                  controller: _subjectCtrl,
                  label: 'Subject',
                  hint: 'e.g. Mathematics, Physics',
                  onChanged: (_) => setState(() {}),
                  suffix: _subjectCtrl.text.trim().isNotEmpty
                      ? _Badge(label: imp.label, color: impColor)
                      : null,
                ),
              const SizedBox(height: 14),
              _Field(
                controller: _titleCtrl,
                label: 'Description (optional)',
                hint: 'e.g. Chapter 5 test, Final exam',
              ),
              const SizedBox(height: 14),
              _FormLabel('Type'),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ExamType.values.map((t) {
                    final sel = _type == t;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primaryLight
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.surfaceBorder,
                            ),
                          ),
                          child: Text(
                            t.label,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              _FormLabel('Date'),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _FormLabel('Time'),
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
              _Field(
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

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 11,
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: GoogleFonts.outfit(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.outfit(
                        color: AppColors.textTertiary, fontSize: 14),
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: const Icon(Icons.event_note_outlined,
                size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'No exams yet',
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Add an exam to track your countdown',
            style: GoogleFonts.outfit(
                fontSize: 13, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Add exam',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
