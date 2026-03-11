import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app/constants.dart';
import '../app/routes.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../services/schedule_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _reminders = ReminderService.getReminders());
  }

  @override
  Widget build(BuildContext context) {
    final upcoming =
        _reminders.where((r) => !r.isPast && !r.isCompleted).toList();
    final past =
        _reminders.where((r) => r.isPast || r.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _reminders.isEmpty
                  ? _buildEmpty(context)
                  : _buildList(upcoming, past, context),
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, Routes.addReminder);
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            Text('Reminders',
                style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_none_outlined,
              size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.lg),
          Text('No reminders',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap + to add a reminder for a test or break.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      List<Reminder> upcoming, List<Reminder> past, BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionHeader('Upcoming'),
          ...upcoming.map((r) => _ReminderTile(
                reminder: r,
                onDelete: () => _delete(r.id),
                onTap: () => _openEdit(context, r),
              )),
        ],
        if (past.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _SectionHeader('Past'),
          ...past.map((r) => _ReminderTile(
                reminder: r,
                onDelete: () => _delete(r.id),
                onTap: () => _openEdit(context, r),
              )),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Future<void> _delete(String id) async {
    await ReminderService.deleteReminder(id);
    _load();
  }

  Future<void> _openEdit(BuildContext context, Reminder r) async {
    await Navigator.pushNamed(context, Routes.addReminder, arguments: r);
    _load();
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ReminderTile({
    required this.reminder,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subject = reminder.subjectId != null
        ? ScheduleService.subjectById(reminder.subjectId!)
        : null;
    final isPast = reminder.isPast;

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(40),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              _TypeIcon(type: reminder.type, isPast: isPast),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isPast
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                        decoration: reminder.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEE, d MMM • HH:mm')
                          .format(reminder.eventDate),
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: AppColors.textTertiary),
                    ),
                    if (subject != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subject.name,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Color(subject.colorValue),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isPast)
                const Icon(Icons.check_circle_outline,
                    size: 16, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final ReminderType type;
  final bool isPast;

  const _TypeIcon({required this.type, required this.isPast});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (type) {
      case ReminderType.exam:
        icon = Icons.assignment_outlined;
        color = AppColors.error;
      case ReminderType.test:
        icon = Icons.quiz_outlined;
        color = AppColors.warning;
      case ReminderType.assignment:
        icon = Icons.edit_note_outlined;
        color = AppColors.primaryBlue;
      case ReminderType.breakStarts:
        icon = Icons.beach_access_outlined;
        color = AppColors.success;
      case ReminderType.breakEnds:
        icon = Icons.school_outlined;
        color = AppColors.primaryPurple;
      case ReminderType.custom:
        icon = Icons.notifications_outlined;
        color = AppColors.accentCyan;
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(isPast ? 20 : 40),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon,
          size: 20, color: isPast ? color.withAlpha(100) : color),
    );
  }
}
