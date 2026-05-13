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
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: Theme.of(c).colorScheme.copyWith(
                primary: theme.colorScheme.primary,
                surface: theme.colorScheme.surface,
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
          timePickerTheme: TimePickerThemeData(
            backgroundColor: theme.colorScheme.surface,
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
    final theme = Theme.of(context);
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
                  style: theme.textTheme.titleLarge,
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
                              color: theme.colorScheme.primary,
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
                          GoogleFonts.outfit(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title,
                            color: theme.colorScheme.onSurface.withAlpha(140)),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type',
            style: GoogleFonts.outfit(
                color: theme.colorScheme.onSurface.withAlpha(140), fontSize: 12)),
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
                      ? theme.colorScheme.primary.withAlpha(60)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.dividerTheme.color ?? AppColors.surfaceBorder,
                  ),
                ),
                child: Text(
                  t.label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withAlpha(200),
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: theme.dividerTheme.color ?? AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.event_outlined,
                color: theme.colorScheme.onSurface.withAlpha(140), size: 20),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date & Time',
                    style: GoogleFonts.outfit(
                        color: theme.colorScheme.onSurface.withAlpha(140), fontSize: 11)),
                Text(
                  DateFormat('EEE, d MMM yyyy • HH:mm')
                      .format(_eventDate),
                  style: GoogleFonts.outfit(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit_outlined,
                color: theme.colorScheme.onSurface.withAlpha(140), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTimingSelector() {
    final theme = Theme.of(context);
    return DropdownButtonFormField<AlertTiming>(
      initialValue: _alertTiming,
      dropdownColor: theme.colorScheme.surface,
      decoration: InputDecoration(
        labelText: 'Alert',
        prefixIcon: Icon(Icons.alarm_outlined,
            color: theme.colorScheme.onSurface.withAlpha(140)),
      ),
      items: AlertTiming.values
          .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.label,
                    style:
                        GoogleFonts.outfit(color: theme.colorScheme.onSurface)),
              ))
          .toList(),
      onChanged: (v) => setState(() => _alertTiming = v!),
    );
  }

  Widget _buildSubjectSelector() {
    final theme = Theme.of(context);
    return DropdownButtonFormField<String?>(
      initialValue: _selectedSubjectId,
      dropdownColor: theme.colorScheme.surface,
      decoration: InputDecoration(
        labelText: 'Subject (optional)',
        prefixIcon: Icon(Icons.book_outlined,
            color: theme.colorScheme.onSurface.withAlpha(140)),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text('None',
              style: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withAlpha(140))),
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
                          color: theme.colorScheme.onSurface)),
                ],
              ),
            )),
      ],
      onChanged: (v) => setState(() => _selectedSubjectId = v),
    );
  }
}
