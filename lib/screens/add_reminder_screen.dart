import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app/constants.dart';
import '../models/reminder.dart';
import '../models/subject.dart';
import '../services/reminder_service.dart';
import '../services/schedule_service.dart';
import '../widgets/animated_gradient_bg.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder;

  const AddReminderScreen({super.key, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  ReminderType _type = ReminderType.custom;
  AlertTiming _alertTiming = AlertTiming.oneDayBefore;
  DateTime _eventDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSubjectId;
  bool _saving = false;

  List<Subject> _subjects = [];

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _titleController = TextEditingController(text: r?.title ?? '');
    if (r != null) {
      _type = r.type;
      _alertTiming = r.alertTiming;
      _eventDate = r.eventDate;
      _selectedSubjectId = r.subjectId;
    }
    _subjects = ScheduleService.getSubjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: Theme.of(c).colorScheme.copyWith(
                primary: AppColors.primaryPurple,
                surface: AppColors.bgDark,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDate),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: AppColors.bgDark,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;
    setState(() {
      _eventDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time?.hour ?? _eventDate.hour,
        time?.minute ?? _eventDate.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final id = widget.reminder?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final reminder = Reminder(
      id: id,
      title: _titleController.text.trim(),
      type: _type,
      eventDate: _eventDate,
      alertTiming: _alertTiming,
      subjectId: _selectedSubjectId,
    );

    if (widget.reminder != null) {
      await ReminderService.updateReminder(reminder);
    } else {
      await ReminderService.addReminder(reminder);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBg(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                title: Text(
                  widget.reminder != null ? 'Edit Reminder' : 'Add Reminder',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                actions: [
                  TextButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Save',
                            style: GoogleFonts.outfit(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    TextFormField(
                      controller: _titleController,
                      style:
                          GoogleFonts.outfit(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title,
                            color: AppColors.textTertiary),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTypeSelector(),
                    const SizedBox(height: AppSpacing.md),
                    _buildDateButton(),
                    const SizedBox(height: AppSpacing.md),
                    _buildAlertTimingSelector(),
                    if (_subjects.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildSubjectSelector(),
                    ],
                    const SizedBox(height: AppSpacing.xxxl),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type',
            style: GoogleFonts.outfit(
                color: AppColors.textTertiary, fontSize: 12)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ReminderType.values.map((t) {
            final selected = t == _type;
            return GestureDetector(
              onTap: () => setState(() => _type = t),
              child: AnimatedContainer(
                duration: AppDurations.microInteraction,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryPurple.withAlpha(60)
                      : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryPurple
                        : Colors.white.withAlpha(20),
                  ),
                ),
                child: Text(
                  t.label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: selected
                        ? AppColors.primaryPurple
                        : AppColors.textSecondary,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateButton() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_outlined,
                color: AppColors.textTertiary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date & Time',
                    style: GoogleFonts.outfit(
                        color: AppColors.textTertiary, fontSize: 11)),
                Text(
                  DateFormat('EEE, d MMM yyyy • HH:mm')
                      .format(_eventDate),
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.edit_outlined,
                color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTimingSelector() {
    return DropdownButtonFormField<AlertTiming>(
      initialValue: _alertTiming,
      dropdownColor: AppColors.bgDark,
      decoration: const InputDecoration(
        labelText: 'Alert',
        prefixIcon: Icon(Icons.alarm_outlined,
            color: AppColors.textTertiary),
      ),
      items: AlertTiming.values
          .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.label,
                    style:
                        GoogleFonts.outfit(color: AppColors.textPrimary)),
              ))
          .toList(),
      onChanged: (v) => setState(() => _alertTiming = v!),
    );
  }

  Widget _buildSubjectSelector() {
    return DropdownButtonFormField<String?>(
      initialValue: _selectedSubjectId,
      dropdownColor: AppColors.bgDark,
      decoration: const InputDecoration(
        labelText: 'Subject (optional)',
        prefixIcon: Icon(Icons.book_outlined,
            color: AppColors.textTertiary),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text('None',
              style: GoogleFonts.outfit(color: AppColors.textTertiary)),
        ),
        ..._subjects.map((s) => DropdownMenuItem(
              value: s.id,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(s.colorValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(s.name,
                      style: GoogleFonts.outfit(
                          color: AppColors.textPrimary)),
                ],
              ),
            )),
      ],
      onChanged: (v) => setState(() => _selectedSubjectId = v),
    );
  }
}
