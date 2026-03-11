import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../services/ai_schedule_service.dart';
import '../widgets/glassmorphic_card.dart';

// ── Mutable entry for editing ────────────────────────────────────────────────

/// Mutable flat representation of one AI-detected class for editing.
class _ReviewEntry {
  final String key;
  final TextEditingController nameController;
  int day; // 1–5
  int startHour;
  int startMinute;
  int endHour;
  int endMinute;
  int colorValue;
  String? teacher;

  _ReviewEntry({
    required String name,
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.colorValue,
    this.teacher,
    String? key,
  })  : key = key ?? '${DateTime.now().microsecondsSinceEpoch}_${name.hashCode}',
        nameController = TextEditingController(text: name);

  String get name => nameController.text.trim();

  void dispose() => nameController.dispose();
}

// ── Screen ───────────────────────────────────────────────────────────────────

/// Day-by-day wizard for reviewing and editing an AI-scanned timetable.
/// Compatible with the same constructor signature as before.
class AiReviewScreen extends StatefulWidget {
  final AiScheduleResult initialResult;

  const AiReviewScreen({super.key, required this.initialResult});

  @override
  State<AiReviewScreen> createState() => _AiReviewScreenState();
}

class _AiReviewScreenState extends State<AiReviewScreen> {
  late List<_ReviewEntry> _entries;
  int _step = 0; // 0–4 = Mon–Fri, 5 = confirm screen

  static const List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
  ];

  static const List<int> _subjectColors = AppColors.subjectColors;

  @override
  void initState() {
    super.initState();
    final srcEntries = widget.initialResult.entries;
    _entries = [
      for (int i = 0; i < srcEntries.length; i++)
        () {
          final entry = srcEntries[i];
          final subject = widget.initialResult.subjects.firstWhere(
            (s) => s.id == entry.subjectId,
            orElse: () => Subject(id: '', name: '?', colorValue: 0xFF6F4E37),
          );
          return _ReviewEntry(
            name: subject.name,
            day: entry.dayOfWeek,
            startHour: entry.startTime.hour,
            startMinute: entry.startTime.minute,
            endHour: entry.endTime.hour,
            endMinute: entry.endTime.minute,
            colorValue: subject.colorValue,
            teacher: subject.teacher,
            key: 'init_${entry.id}_$i',
          );
        }(),
    ];
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  List<_ReviewEntry> _entriesForDay(int day) =>
      _entries.where((e) => e.day == day).toList();

  void _deleteEntry(String key) {
    setState(() => _entries.removeWhere((e) => e.key == key));
  }

  void _addEntry(int day) {
    setState(() {
      _entries.add(_ReviewEntry(
        name: '',
        day: day,
        startHour: 8,
        startMinute: 0,
        endHour: 8,
        endMinute: 50,
        colorValue: _subjectColors[_entries.length % _subjectColors.length],
        key: 'new_${DateTime.now().microsecondsSinceEpoch}',
      ));
    });
  }

  Future<void> _pickTime(_ReviewEntry entry, bool isStart) async {
    final initial = TimeOfDay(
      hour: isStart ? entry.startHour : entry.endHour,
      minute: isStart ? entry.startMinute : entry.endMinute,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        entry.startHour = picked.hour;
        entry.startMinute = picked.minute;
      } else {
        entry.endHour = picked.hour;
        entry.endMinute = picked.minute;
      }
    });
  }

  /// Converts the edited entries back into an AiScheduleResult.
  AiScheduleResult _buildResult() {
    final subjectCache = <String, Subject>{};
    final subjects = <Subject>[];
    final entries = <ScheduleEntry>[];

    for (int i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      final name = e.name.isEmpty ? 'Unknown' : e.name;
      final cacheKey = name.toLowerCase();

      Subject? subject = subjectCache[cacheKey];
      if (subject == null) {
        subject = Subject(
          id: 'ai_subj_${DateTime.now().millisecondsSinceEpoch}_$i',
          name: name,
          colorValue: e.colorValue,
          teacher: e.teacher,
        );
        subjects.add(subject);
        subjectCache[cacheKey] = subject;
      }

      entries.add(ScheduleEntry(
        id: 'ai_entry_${DateTime.now().millisecondsSinceEpoch}_$i',
        subjectId: subject.id,
        dayOfWeek: e.day.clamp(1, 5),
        startTime: ScheduleTime(hour: e.startHour, minute: e.startMinute),
        endTime: ScheduleTime(hour: e.endHour, minute: e.endMinute),
        weekType: WeekType.both,
      ));
    }

    return AiScheduleResult(subjects: subjects, entries: entries);
  }

  void _goNext() {
    if (_step < 5) setState(() => _step++);
  }

  void _goBack() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 5) return _buildConfirmScreen();
    return _buildDayScreen(_step);
  }

  // ── Day screen ─────────────────────────────────────────────────────────────

  Widget _buildDayScreen(int dayIndex) {
    final day = dayIndex + 1; // 1–5
    final dayEntries = _entriesForDay(day);
    final isLast = dayIndex == 4;
    final nextLabel = isLast ? 'Review & Save' : 'Next: ${_dayNames[dayIndex + 1]}';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildDayHeader(dayIndex),
            _buildProgressBar(dayIndex),
            Expanded(
              child: dayEntries.isEmpty
                  ? _buildDayEmptyState(day)
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: dayEntries.length,
                      itemBuilder: (ctx, i) => _EntryCard(
                        entry: dayEntries[i],
                        onDelete: () =>
                            _deleteEntry(dayEntries[i].key),
                        onPickStartTime: () =>
                            _pickTime(dayEntries[i], true),
                        onPickEndTime: () =>
                            _pickTime(dayEntries[i], false),
                        onChanged: () => setState(() {}),
                      ),
                    ),
            ),
            // Add class button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () => _addEntry(day),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '+ Add class',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Navigation
            _buildNavBar(
              showBack: dayIndex > 0,
              nextLabel: nextLabel,
              onBack: _goBack,
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeader(int dayIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _dayNames[dayIndex],
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Text(
            '${dayIndex + 1} / 5',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: List.generate(5, (i) {
          final filled = i <= currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 4 ? 4 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                decoration: BoxDecoration(
                  color: filled ? AppColors.primary : AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayEmptyState(int day) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.free_breakfast_outlined,
                size: 28, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Free day',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No classes — tap "+ Add class" to add one',
            style: GoogleFonts.outfit(
                fontSize: 13, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar({
    required bool showBack,
    required String nextLabel,
    required VoidCallback onBack,
    required VoidCallback onNext,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          if (showBack)
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.surfaceBorder),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
              ),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(nextLabel),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirm screen (step 6) ─────────────────────────────────────────────────

  Widget _buildConfirmScreen() {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _goBack,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textSecondary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: GoogleFonts.outfit(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Review Schedule',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _entries.isEmpty
                  ? Center(
                      child: Text(
                        'No classes to import',
                        style: GoogleFonts.outfit(color: AppColors.textTertiary),
                      ),
                    )
                  : ListView(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        for (int dayIdx = 0; dayIdx < 5; dayIdx++) ...[
                          if (_entriesForDay(dayIdx + 1).isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, bottom: 8),
                              child: Text(
                                _dayNames[dayIdx],
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            ..._entriesForDay(dayIdx + 1).map(
                              (e) => _ConfirmEntryRow(entry: e),
                            ),
                          ],
                        ],
                        const SizedBox(height: 16),
                        Text(
                          '${_entries.length} class${_entries.length == 1 ? '' : 'es'} total',
                          style: GoogleFonts.outfit(
                              color: AppColors.textTertiary, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border:
                    Border(top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _entries.isEmpty
                      ? null
                      : () => Navigator.pop(context, _buildResult()),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg)),
                    textStyle:
                        GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Save Schedule'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Entry Card ────────────────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  final _ReviewEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final VoidCallback onChanged;

  const _EntryCard({
    required this.entry,
    required this.onDelete,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.onChanged,
  });

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(entry.colorValue);
    return Dismissible(
      key: ValueKey(entry.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(15),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.error.withAlpha(40)),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassmorphicCard(
          animate: false,
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color dot
              Container(
                width: 4,
                height: 60,
                margin: const EdgeInsets.only(right: 12, top: 2),
                decoration: BoxDecoration(
                  color: subjectColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Fields
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: entry.nameController,
                      onChanged: (_) => onChanged(),
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Subject name',
                        hintStyle: GoogleFonts.outfit(
                            color: AppColors.textTertiary, fontSize: 14),
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Chip(
                          label:
                              '${_fmt(entry.startHour, entry.startMinute)} – ${_fmt(entry.endHour, entry.endMinute)}',
                          onTap: onPickStartTime,
                          icon: Icons.schedule_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete button
              GestureDetector(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8, top: 2),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const _Chip({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confirm entry row ─────────────────────────────────────────────────────────

class _ConfirmEntryRow extends StatelessWidget {
  final _ReviewEntry entry;
  const _ConfirmEntryRow({required this.entry});

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final color = Color(entry.colorValue);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassmorphicCard(
        animate: false,
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name.isEmpty ? 'Unknown' : entry.name,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (entry.teacher != null && entry.teacher!.isNotEmpty)
                    Text(
                      entry.teacher!,
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            Text(
              '${_fmt(entry.startHour, entry.startMinute)} – ${_fmt(entry.endHour, entry.endMinute)}',
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
