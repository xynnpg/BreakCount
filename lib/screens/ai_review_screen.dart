import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../services/ai_schedule_service.dart';
import '../data/subject_suggestions.dart';
import '../data/subject_colors.dart';

// ── Mutable entry for editing ─────────────────────────────────────────────────

class _ReviewEntry {
  final String key;
  String name;
  int day; // 1–5
  int startHour, startMinute, endHour, endMinute;
  int colorValue;

  _ReviewEntry({
    required this.name,
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.colorValue,
    String? key,
  }) : key = key ?? '${DateTime.now().microsecondsSinceEpoch}_${name.hashCode}';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AiReviewScreen extends StatefulWidget {
  final AiScheduleResult initialResult;
  final String country;

  const AiReviewScreen({
    super.key,
    required this.initialResult,
    this.country = 'Romania',
  });

  @override
  State<AiReviewScreen> createState() => _AiReviewScreenState();
}

class _AiReviewScreenState extends State<AiReviewScreen> {
  late List<_ReviewEntry> _entries;
  late List<String> _suggestions;
  int _step = 0; // 0–4 = Mon–Fri, 5 = confirm

  static const _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
  ];

  @override
  void initState() {
    super.initState();
    _suggestions = getSuggestionsForCountry(widget.country);
    final src = widget.initialResult.entries;
    _entries = [
      for (int i = 0; i < src.length; i++) () {
        final e = src[i];
        final s = widget.initialResult.subjects.firstWhere(
          (s) => s.id == e.subjectId,
          orElse: () => Subject(id: '', name: '?', colorValue: 0xFF6F4E37),
        );
        return _ReviewEntry(
          name: s.name,
          day: e.dayOfWeek,
          startHour: e.startTime.hour,
          startMinute: e.startTime.minute,
          endHour: e.endTime.hour,
          endMinute: e.endTime.minute,
          colorValue: s.colorValue,
          key: 'init_${e.id}_$i',
        );
      }(),
    ];
  }

  List<_ReviewEntry> _forDay(int day) =>
      _entries.where((e) => e.day == day).toList();

  void _delete(String key) =>
      setState(() => _entries.removeWhere((e) => e.key == key));

  void _addEntry(int day) {
    final color = _suggestions.isNotEmpty
        ? subjectDifficultyColor(_suggestions[0])
        : 0xFF6F4E37;
    setState(() {
      _entries.add(_ReviewEntry(
        name: '',
        day: day,
        startHour: 8, startMinute: 0,
        endHour: 8, endMinute: 50,
        colorValue: color,
        key: 'new_${DateTime.now().microsecondsSinceEpoch}',
      ));
    });
  }

  Future<void> _editName(_ReviewEntry entry) async {
    final ctrl = TextEditingController(text: entry.name);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NameEditSheet(
        controller: ctrl,
        suggestions: _suggestions,
      ),
    );
    ctrl.dispose();
    if (result == null || !mounted) return;
    final name = result.trim().isEmpty ? entry.name : result.trim();
    setState(() {
      entry.name = name;
      entry.colorValue = subjectDifficultyColor(name);
    });
  }

  Future<void> _pickTime(_ReviewEntry entry) async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: entry.startHour, minute: entry.startMinute),
      helpText: 'Start time',
    );
    if (start == null || !mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: entry.endHour, minute: entry.endMinute),
      helpText: 'End time',
    );
    if (end == null) return;
    setState(() {
      entry.startHour = start.hour; entry.startMinute = start.minute;
      entry.endHour = end.hour; entry.endMinute = end.minute;
    });
  }

  void _cycleColor(_ReviewEntry entry) {
    final colors = AppColors.subjectColors;
    final idx = colors.indexOf(entry.colorValue);
    setState(() => entry.colorValue = colors[(idx + 1) % colors.length]);
  }

  AiScheduleResult _buildResult() {
    final cache = <String, Subject>{};
    final subjects = <Subject>[];
    final entries = <ScheduleEntry>[];
    for (int i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      final name = e.name.isEmpty ? 'Unknown' : e.name;
      final key = name.toLowerCase();
      Subject? subj = cache[key];
      if (subj == null) {
        subj = Subject(
          id: 'ai_subj_${DateTime.now().millisecondsSinceEpoch}_$i',
          name: name,
          colorValue: e.colorValue,
        );
        subjects.add(subj);
        cache[key] = subj;
      }
      entries.add(ScheduleEntry(
        id: 'ai_entry_${DateTime.now().millisecondsSinceEpoch}_$i',
        subjectId: subj.id,
        dayOfWeek: e.day.clamp(1, 5),
        startTime: ScheduleTime(hour: e.startHour, minute: e.startMinute),
        endTime: ScheduleTime(hour: e.endHour, minute: e.endMinute),
        weekType: WeekType.both,
      ));
    }
    return AiScheduleResult(subjects: subjects, entries: entries);
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 5) return _buildConfirmScreen();
    return _buildDayScreen(_step);
  }

  // ── Day screen ────────────────────────────────────────────────────────────

  Widget _buildDayScreen(int dayIdx) {
    final theme = Theme.of(context);
    final day = dayIdx + 1;
    final dayEntries = _forDay(day);
    final isLast = dayIdx == 4;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.initialResult.isOfflineOcr)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.offline_bolt_rounded, color: Color(0xFF2E7D32), size: 20),
                    SizedBox(width: 8),
                    Text('Parsed offline — no API call used',
                      style: TextStyle(color: Color(0xFF2E7D32), fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            _buildHeader(dayIdx),
            _buildProgress(dayIdx),
            Expanded(
              child: dayEntries.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      itemCount: dayEntries.length,
                      itemBuilder: (ctx, i) => _EntryCard(
                        entry: dayEntries[i],
                        onDelete: () => _delete(dayEntries[i].key),
                        onEditName: () => _editName(dayEntries[i]),
                        onPickTime: () => _pickTime(dayEntries[i]),
                        onCycleColor: () => _cycleColor(dayEntries[i]),
                      ),
                    ),
            ),
            _buildAddButton(day),
            _buildNavBar(dayIdx, isLast),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int dayIdx) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _dayNames[dayIdx],
            style: GoogleFonts.outfit(
              fontSize: 28, fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface, letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Text(
            '${dayIdx + 1}/5',
            style: GoogleFonts.outfit(
                fontSize: 14, color: theme.colorScheme.onSurface.withAlpha(140)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(int step) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: List.generate(5, (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 4 ? 4 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              decoration: BoxDecoration(
                color: i <= step ? theme.colorScheme.primary : (theme.dividerTheme.color ?? AppColors.surfaceBorder),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildEmpty() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20), shape: BoxShape.circle),
            child: Icon(Icons.free_breakfast_outlined,
                size: 28, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text('Free day',
              style: GoogleFonts.outfit(
                  fontSize: 17, fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('Tap "+ Add class" to add one',
              style: GoogleFonts.outfit(
                  fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(140))),
        ],
      ),
    );
  }

  Widget _buildAddButton(int day) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => _addEntry(day),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text('+ Add class',
                  style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(int dayIdx, bool isLast) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerTheme.color ?? AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          if (dayIdx > 0)
            OutlinedButton.icon(
              onPressed: () => setState(() => _step--),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withAlpha(200),
                side: BorderSide(color: theme.dividerTheme.color ?? AppColors.surfaceBorder),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
              ),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => setState(() => _step++),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(isLast
                ? 'Review & Save'
                : 'Next: ${_dayNames[dayIdx + 1]}'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg)),
              textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirm screen ────────────────────────────────────────────────────────

  Widget _buildConfirmScreen() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(children: [
                GestureDetector(
                  onTap: () => setState(() => _step--),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_back_rounded,
                        color: theme.colorScheme.onSurface.withAlpha(200), size: 18),
                    const SizedBox(width: 4),
                    Text('Back',
                        style: GoogleFonts.outfit(
                            color: theme.colorScheme.onSurface.withAlpha(200),
                            fontWeight: FontWeight.w500)),
                  ]),
                ),
                const SizedBox(width: 16),
                Text('Review Schedule',
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface)),
              ]),
            ),
            Expanded(
              child: _entries.isEmpty
                  ? Center(
                      child: Text('No classes to import',
                          style: GoogleFonts.outfit(
                              color: theme.colorScheme.onSurface.withAlpha(140))))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        for (int d = 0; d < 5; d++) ...[
                          if (_forDay(d + 1).isNotEmpty) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 8),
                              child: Text(_dayNames[d],
                                  style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary)),
                            ),
                            ..._forDay(d + 1).map((e) => _ConfirmRow(entry: e)),
                          ],
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '${_entries.length} class${_entries.length == 1 ? '' : 'es'} total',
                          style: GoogleFonts.outfit(
                              fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(140)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border:
                    Border(top: BorderSide(color: theme.dividerTheme.color ?? AppColors.surfaceBorder)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _entries.isEmpty
                      ? null
                      : () => Navigator.pop(context, _buildResult()),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg)),
                    textStyle:
                        GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                  child: Text('Save Schedule'),
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
  final VoidCallback onEditName;
  final VoidCallback onPickTime;
  final VoidCallback onCycleColor;

  const _EntryCard({
    required this.entry,
    required this.onDelete,
    required this.onEditName,
    required this.onPickTime,
    required this.onCycleColor,
  });

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(entry.colorValue);
    return Dismissible(
      key: ValueKey(entry.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(15),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.error.withAlpha(40)),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.dividerTheme.color ?? AppColors.surfaceBorder),
          boxShadow: const [
            BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Colored left bar — tap to cycle color
            GestureDetector(
              onTap: onCycleColor,
              child: Tooltip(
                message: 'Tap to change color',
                child: Container(
                  width: 6,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      bottomLeft: Radius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject name — tap to edit
                    GestureDetector(
                      onTap: onEditName,
                      child: Row(children: [
                        Expanded(
                          child: Text(
                            entry.name.isEmpty
                                ? 'Tap to set subject…'
                                : entry.name,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: entry.name.isEmpty
                                  ? theme.colorScheme.onSurface.withAlpha(140)
                                  : theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit_outlined,
                            size: 13, color: theme.colorScheme.onSurface.withAlpha(140)),
                      ]),
                    ),
                    const SizedBox(height: 5),
                    // Time row — tap to edit
                    GestureDetector(
                      onTap: onPickTime,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.schedule_outlined,
                            size: 13, color: theme.colorScheme.onSurface.withAlpha(140)),
                        const SizedBox(width: 4),
                        Text(
                          '${_fmt(entry.startHour, entry.startMinute)} – ${_fmt(entry.endHour, entry.endMinute)}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withAlpha(200),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit_outlined,
                            size: 11, color: theme.colorScheme.onSurface.withAlpha(140)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            // Delete button
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.close_rounded,
                    size: 18, color: theme.colorScheme.onSurface.withAlpha(140)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Name Edit Bottom Sheet ────────────────────────────────────────────────────

class _NameEditSheet extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;

  const _NameEditSheet({
    required this.controller,
    required this.suggestions,
  });

  @override
  State<_NameEditSheet> createState() => _NameEditSheetState();
}

class _NameEditSheetState extends State<_NameEditSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: theme.dividerTheme.color ?? AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Subject name',
              style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 12),
          TextField(
            controller: widget.controller,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.outfit(
                fontSize: 15, color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'e.g. Matematică',
              hintStyle: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withAlpha(140)),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: theme.dividerTheme.color ?? AppColors.surfaceBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: theme.dividerTheme.color ?? AppColors.surfaceBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary.withAlpha(150)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      color: theme.colorScheme.onSurface.withAlpha(140),
                      onPressed: () {
                        widget.controller.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Text('Suggestions',
              style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withAlpha(200))),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.suggestions.length,
              separatorBuilder: (context2, i2) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final s = widget.suggestions[i];
                final selected = widget.controller.text == s;
                return GestureDetector(
                  onTap: () {
                    widget.controller.text = s;
                    widget.controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: s.length));
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withAlpha(60),
                      ),
                    ),
                    child: Text(
                      s,
                      style: GoogleFonts.outfit(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () =>
                  Navigator.pop(context, widget.controller.text),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              child: Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confirm row ───────────────────────────────────────────────────────────────

class _ConfirmRow extends StatelessWidget {
  final _ReviewEntry entry;
  const _ConfirmRow({required this.entry});

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: Color(entry.colorValue), shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.name.isEmpty ? 'Unknown' : entry.name,
              style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface),
            ),
          ),
          Text(
            '${_fmt(entry.startHour, entry.startMinute)} – ${_fmt(entry.endHour, entry.endMinute)}',
            style: GoogleFonts.outfit(
                fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140),
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
