import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../app/constants.dart';
import '../app/routes.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../services/storage_service.dart';
import '../services/schedule_service.dart';
import '../services/ai_schedule_service.dart';
import '../services/achievement_service.dart';
import '../widgets/achievement_unlock_overlay.dart';
import '../widgets/timetable_grid.dart';
import 'ai_review_screen.dart';
import 'schedule_tab_sheets.dart';
import 'schedule_tab_entry_detail.dart';
import 'schedule_tab_widgets.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab>
    with AutomaticKeepAliveClientMixin {
  Schedule _schedule = const Schedule.empty();
  List<Subject> _subjects = [];
  WeekType _currentWeek = WeekType.a;
  bool _aiProcessing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
    ScheduleService.scheduleRefresh.addListener(_load);
  }

  void _load() {
    final savedWeek =
        StorageService.getString(StorageKeys.currentWeekType) ?? 'a';
    setState(() {
      _schedule = ScheduleService.getSchedule();
      _subjects = ScheduleService.getSubjects();
      _currentWeek = WeekTypeExt.fromString(savedWeek);
    });
  }

  Future<void> _toggleWeek() async {
    final next = _currentWeek == WeekType.a ? WeekType.b : WeekType.a;
    await StorageService.saveString(
        StorageKeys.currentWeekType, next.jsonValue);
    setState(() => _currentWeek = next);
  }

  @override
  void dispose() {
    ScheduleService.scheduleRefresh.removeListener(_load);
    super.dispose();
  }

  // ── AI Photo Import ──────────────────────────────────────────────────────────

  Future<void> _aiImportPhoto() async {
    final rawKey = StorageService.getString(StorageKeys.aiApiKey) ?? '';
    final apiKey = rawKey.trim().isEmpty ? null : rawKey.trim();
    final country =
        StorageService.getString(StorageKeys.selectedCountry) ?? 'Romania';

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const PhotoSourceSheet(),
    );
    if (source == null || !mounted) return;

    XFile? picked;
    try {
      picked =
          await ImagePicker().pickImage(source: source, imageQuality: 92);
    } catch (_) {}
    if (picked == null || !mounted) return;

    setState(() => _aiProcessing = true);

    String? aiError;
    final result = await AiScheduleService.parseImage(
      File(picked.path),
      apiKey,
      country: country,
      onError: (msg) => aiError = msg,
    );

    if (!mounted) return;
    setState(() => _aiProcessing = false);

    if (result == null || result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(aiError ??
              'Could not read schedule from photo. Try a clearer image.'),
        ),
      );
      return;
    }

    final edited = await Navigator.push<AiScheduleResult>(
      context,
      MaterialPageRoute(
          builder: (_) =>
              AiReviewScreen(initialResult: result, country: country)),
    );
    if (edited == null || !mounted) return;

    bool replace = false;
    if (_schedule.entries.isNotEmpty) {
      final choice = await showDialog<String>(
        context: context,
        builder: (_) => const MergeDialog(),
      );
      if (choice == null || choice == 'cancel') return;
      replace = choice == 'replace';
    }

    if (replace) await ScheduleService.clearAll();
    for (final s in edited.subjects) {
      await ScheduleService.addSubject(s);
    }
    for (final e in edited.entries) {
      await ScheduleService.addEntry(e);
    }

    _load();

    if (await AchievementService.onAiScan() && mounted) {
      AchievementUnlockOverlay.show(context, 'ai_wizard');
    }
    if (await AchievementService.onScheduleFullWeek() && mounted) {
      AchievementUnlockOverlay.show(context, 'fully_loaded');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${edited.entries.length} classes imported from photo')),
      );
    }
  }

  void _onEntryTap(BuildContext context, ScheduleEntry entry) {
    Subject? subject;
    try {
      subject = _subjects.firstWhere((s) => s.id == entry.subjectId);
    } catch (_) {}
    if (subject == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EntryDetailSheet(
        entry: entry,
        subject: subject!,
        onDelete: () async {
          final nav = Navigator.of(context);
          await ScheduleService.deleteEntry(entry.id);
          if (!mounted) return;
          nav.pop();
          _load();
        },
        onEdit: () async {
          final nav = Navigator.of(context);
          nav.pop();
          await nav.pushNamed(Routes.addSubject, arguments: subject);
          _load();
        },
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          Column(
            children: [
              ScheduleHeader(
                schedule: _schedule,
                currentWeek: _currentWeek,
                onToggleWeek: _toggleWeek,
                onScanPhoto: _aiImportPhoto,
                onAdd: () async {
                  await Navigator.pushNamed(context, Routes.addSubject);
                  _load();
                },
              ),
              Expanded(
                child: _schedule.entries.isEmpty
                    ? ScheduleEmptyState(
                        onAdd: () async {
                          await Navigator.pushNamed(
                              context, Routes.addSubject);
                          _load();
                        },
                        onScanPhoto: _aiImportPhoto,
                      )
                    : TimetableGrid(
                        schedule: _schedule,
                        subjects: _subjects,
                        currentWeek: _currentWeek,
                        onEntryTap: (entry) =>
                            _onEntryTap(context, entry),
                        onEntryMoved: (entry, newDay, start, end) async {
                          final conflict = _schedule.entries
                              .where((e) =>
                                  e.id != entry.id &&
                                  e.dayOfWeek == newDay &&
                                  e.startTime.hour == start.hour)
                              .toList();
                          final updated = entry.copyWith(
                              dayOfWeek: newDay,
                              startTime: start,
                              endTime: end);
                          await ScheduleService.updateEntry(updated);
                          if (conflict.isNotEmpty) {
                            final old = entry.startTime;
                            await ScheduleService.updateEntry(
                              conflict.first.copyWith(
                                dayOfWeek: entry.dayOfWeek,
                                startTime: old,
                                endTime: ScheduleTime(
                                    hour: old.hour, minute: 50),
                              ),
                            );
                          }
                          _load();
                        },
                      ),
              ),
            ],
          ),

          // AI processing overlay
          if (_aiProcessing)
            Container(
              color: Colors.white.withAlpha(200),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 48),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.surfaceBorder),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 24,
                          offset: Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Reading timetable...',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'AI is reading your timetable',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
