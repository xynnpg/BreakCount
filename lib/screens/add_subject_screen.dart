import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/subject.dart';
import '../models/schedule.dart';
import '../services/storage_service.dart';
import '../services/schedule_service.dart';
import '../data/subject_suggestions.dart';
import '../widgets/glassmorphic_card.dart';

class AddSubjectScreen extends StatefulWidget {
  final Subject? subject;

  const AddSubjectScreen({super.key, this.subject});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _teacherController;
  late final TextEditingController _roomController;

  int _selectedColor = AppColors.subjectColors[0];
  int _selectedDay = 1;
  ScheduleTime _startTime = const ScheduleTime(hour: 8, minute: 0);
  ScheduleTime _endTime = const ScheduleTime(hour: 9, minute: 0);
  WeekType _weekType = WeekType.both;
  bool _saving = false;

  static const List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.subject;
    _nameController = TextEditingController(text: s?.name ?? '');
    _teacherController = TextEditingController(text: s?.teacher ?? '');
    _roomController = TextEditingController(text: s?.room ?? '');
    if (s != null) _selectedColor = s.colorValue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final id = widget.subject?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final subject = Subject(
      id: id,
      name: _nameController.text.trim(),
      colorValue: _selectedColor,
      teacher: _teacherController.text.trim().isEmpty
          ? null
          : _teacherController.text.trim(),
      room: _roomController.text.trim().isEmpty
          ? null
          : _roomController.text.trim(),
    );

    final entry = ScheduleEntry(
      id: '${id}_entry_${DateTime.now().millisecondsSinceEpoch}',
      subjectId: id,
      dayOfWeek: _selectedDay,
      startTime: _startTime,
      endTime: _endTime,
      weekType: _weekType,
      room: _roomController.text.trim().isEmpty
          ? null
          : _roomController.text.trim(),
    );

    if (widget.subject != null) {
      await ScheduleService.updateSubject(subject);
    } else {
      await ScheduleService.addSubject(subject);
      await ScheduleService.addEntry(entry);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickTime(bool isStart) async {
    final current = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null) return;
    final t = ScheduleTime(hour: picked.hour, minute: picked.minute);
    setState(() {
      if (isStart) {
        _startTime = t;
        if (_endTime.toFractionalHours() <= t.toFractionalHours()) {
          _endTime = ScheduleTime(
              hour: t.hour + 1 > 23 ? 23 : t.hour + 1, minute: t.minute);
        }
      } else {
        _endTime = t;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final country =
        StorageService.getString(StorageKeys.selectedCountry) ?? '';
    final suggestions = getSuggestionsForCountry(country);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 1,
              title: Text(
                widget.subject != null ? 'Edit Subject' : 'Add Subject',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          )
                        : Text(
                            'Save',
                            style: GoogleFonts.outfit(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildNameField(suggestions),
                  const SizedBox(height: AppSpacing.md),
                  _buildColorPicker(),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(_teacherController, 'Teacher (optional)',
                      Icons.person_outline),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                      _roomController, 'Room (optional)', Icons.room_outlined),
                  if (widget.subject == null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildScheduleSection(),
                  ],
                  const SizedBox(height: AppSpacing.xxxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(List<String> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.outfit(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Subject name',
            prefixIcon:
                Icon(Icons.book_outlined, color: AppColors.textTertiary),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Name is required' : null,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (_, i) => ActionChip(
              label: Text(
                suggestions[i],
                style: GoogleFonts.outfit(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.surfaceBorder),
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              onPressed: () =>
                  setState(() => _nameController.text = suggestions[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return GlassmorphicCard(
      animate: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color',
              style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppColors.subjectColors.map((c) {
              final selected = c == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: AnimatedContainer(
                  duration: AppDurations.microInteraction,
                  width: selected ? 34 : 28,
                  height: selected ? 34 : 28,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.white, width: 2.5)
                        : Border.all(
                            color: Color(c).withAlpha(0), width: 0),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                                color: Color(c).withAlpha(80),
                                blurRadius: 8,
                                spreadRadius: 1)
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      style: GoogleFonts.outfit(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return GlassmorphicCard(
      animate: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Schedule',
              style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: AppSpacing.md),
          // Day selector
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final selected = _selectedDay == i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = i + 1),
                  child: AnimatedContainer(
                    duration: AppDurations.microInteraction,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryLight
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surfaceBorder,
                      ),
                    ),
                    child: Text(
                      _dayNames[i].substring(0, 3),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Time row
          Row(
            children: [
              Expanded(
                child: _TimeButton(
                  label: 'Start',
                  time: _startTime,
                  onTap: () => _pickTime(true),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TimeButton(
                  label: 'End',
                  time: _endTime,
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Week type
          DropdownButtonFormField<WeekType>(
            initialValue: _weekType,
            decoration: const InputDecoration(
              labelText: 'Week',
              prefixIcon: Icon(Icons.repeat_rounded,
                  color: AppColors.textTertiary),
            ),
            items: WeekType.values
                .map((w) => DropdownMenuItem(
                      value: w,
                      child: Text(w.label,
                          style: GoogleFonts.outfit(
                              color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _weekType = v!),
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final ScheduleTime time;
  final VoidCallback onTap;

  const _TimeButton(
      {required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 11, color: AppColors.textTertiary)),
            Text(
              time.format24h(),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
