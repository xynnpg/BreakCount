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
import 'ai_review_screen.dart';
import '../widgets/timetable_grid.dart';

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
    // Use user's own key if set; otherwise the service falls back to the
    // Cloudflare Worker proxy (5 free scans/day).
    final rawKey = StorageService.getString(StorageKeys.aiApiKey) ?? '';
    final apiKey = rawKey.trim().isEmpty ? null : rawKey.trim();
    final country =
        StorageService.getString(StorageKeys.selectedCountry) ?? 'Romania';

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _PhotoSourceSheet(),
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
          builder: (_) => AiReviewScreen(
              initialResult: result, country: country)),
    );
    if (edited == null || !mounted) return;

    bool replace = false;
    if (_schedule.entries.isNotEmpty) {
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => _MergeDialog(),
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${edited.entries.length} classes imported from photo')),
      );
    }
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
              _ScheduleHeader(
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
                    ? _EmptyState(
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
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Analyzing photo…',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
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
      builder: (_) => _EntryDetailSheet(
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
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ScheduleHeader extends StatelessWidget {
  final Schedule schedule;
  final WeekType currentWeek;
  final VoidCallback onToggleWeek;
  final VoidCallback onScanPhoto;
  final VoidCallback onAdd;

  const _ScheduleHeader({
    required this.schedule,
    required this.currentWeek,
    required this.onToggleWeek,
    required this.onScanPhoto,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.scaffoldBg,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                if (schedule.entries.isNotEmpty)
                  Text(
                    '${schedule.entries.length} classes',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            if (schedule.useAlternatingWeeks) ...[
              _WeekPill(currentWeek: currentWeek, onToggle: onToggleWeek),
              const SizedBox(width: AppSpacing.xs),
            ],
            _HeaderIcon(
              icon: Icons.camera_alt_outlined,
              tooltip: 'Scan photo',
              onTap: onScanPhoto,
            ),
            _AddButton(onTap: onAdd),
          ],
        ),
      ),
    );
  }
}

class _WeekPill extends StatelessWidget {
  final WeekType currentWeek;
  final VoidCallback onToggle;

  const _WeekPill(
      {required this.currentWeek, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.primary.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentWeek.label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.swap_horiz_rounded,
                size: 13, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIcon(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: AppColors.textSecondary, size: 22),
        onPressed: onTap,
        splashRadius: 20,
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 4, right: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(70),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onScanPhoto;

  const _EmptyState({required this.onAdd, required this.onScanPhoto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.grid_view_rounded,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No classes yet',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add manually or scan your\nprinted timetable with AI.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Subject'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg)),
                  textStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onScanPhoto,
                icon: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.textSecondary, size: 18),
                label: Text(
                  'Scan Timetable Photo',
                  style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photo source bottom sheet ────────────────────────────────────────────────

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Import Timetable',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'AI will read and extract your schedule.',
                style: GoogleFonts.outfit(
                    fontSize: 13, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SourceTile(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                sub: 'Point camera at printed timetable',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                sub: 'Pick a saved image',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: GoogleFonts.outfit(
                          color: AppColors.textTertiary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                  Text(sub,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Merge dialog ──────────────────────────────────────────────────────────────

class _MergeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Existing schedule found',
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      content: Text(
        'Do you want to add these classes to your existing schedule, or replace everything?',
        style: GoogleFonts.outfit(
            color: AppColors.textSecondary, fontSize: 13, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: Text('Cancel',
              style: GoogleFonts.outfit(color: AppColors.textTertiary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'add'),
          child: Text('Add to existing',
              style: GoogleFonts.outfit(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'replace'),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text('Replace all',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ── Entry detail sheet ────────────────────────────────────────────────────────

class _EntryDetailSheet extends StatelessWidget {
  final ScheduleEntry entry;
  final Subject subject;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _EntryDetailSheet({
    required this.entry,
    required this.subject,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(subject.colorValue);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${entry.startTime.format24h()} – ${entry.endTime.format24h()}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.textSecondary, size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.surfaceBorder, height: 1),
            const SizedBox(height: AppSpacing.md),

            if (subject.teacher != null)
              _DetailRow(icon: Icons.person_outline, text: subject.teacher!),
            if (entry.room != null || subject.room != null)
              _DetailRow(
                  icon: Icons.room_outlined,
                  text: entry.room ?? subject.room!),
            _DetailRow(
                icon: Icons.calendar_today_outlined,
                text: entry.weekType.label),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Text(text,
              style: GoogleFonts.outfit(
                  color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
