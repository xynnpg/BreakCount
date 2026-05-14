import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/exam.dart';
import '../services/exam_service.dart';
import '../services/calendar_service.dart';
import '../services/storage_service.dart';
import '../services/subject_importance_service.dart';
import '../services/achievement_service.dart';
import '../widgets/achievement_unlock_overlay.dart';
import 'exams_tab_card.dart';
import 'exams_tab_form.dart';

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
    return SubjectImportanceService.getImportance(name, _country,
        profileId: StorageService.getString(StorageKeys.schoolProfile));
  }

  Future<void> _openAddEdit({Exam? existing}) async {
    final result = await showModalBottomSheet<Exam>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExamFormSheet(existing: existing, country: _country),
    );
    if (result != null) {
      if (existing == null) {
        await ExamService.addExam(result);
        final allExams = [...ExamService.getUpcoming(), ...ExamService.getPast()];
        final total = allExams.length;
        final examDates = allExams.map((e) => e.date).toList();
        final unlocked =
            await AchievementService.onExamAdded(totalExams: total, examDates: examDates);
        for (final id in unlocked) {
          if (mounted) AchievementUnlockOverlay.show(context, id);
        }
      } else {
        await ExamService.updateExam(result);
      }
      _reload();
    }
  }

  Future<void> _delete(Exam exam) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete exam?'),
        content: Text(exam.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withAlpha(120))),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.8,
                            ),
                          ),
                          Text(
                            'Tests & Assessments',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withAlpha(120),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (_upcoming.isNotEmpty)
                            Text(
                              '${_upcoming.length} upcoming',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
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
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withAlpha(60),
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
                            color: theme.colorScheme.onSurface.withAlpha(120), fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ..._upcoming.asMap().entries.map((entry) => ExamCard(
                        exam: entry.value,
                        importance: _importance(entry.value),
                        onEdit: () => _openAddEdit(existing: entry.value),
                        onDelete: () => _delete(entry.value),
                        onExport: () =>
                            CalendarService.exportExam(entry.value),
                        animationDelay: entry.key * 60,
                      )),
                  if (_past.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showPast = !_showPast),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.dividerTheme.color ?? AppColors.surfaceBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Past (${_past.length})',
                              style: GoogleFonts.outfit(
                                  color: theme.colorScheme.onSurface.withAlpha(180),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showPast
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: theme.colorScheme.onSurface.withAlpha(120),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showPast) ...[
                      const SizedBox(height: 10),
                      ..._past.map((exam) => ExamCard(
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withAlpha(20),
            ),
            child: Icon(Icons.event_note_outlined,
                size: 32, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'No exams yet',
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Nothing coming up. Enjoy it while it lasts.',
            style: GoogleFonts.outfit(
                fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(120)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Add exam',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
