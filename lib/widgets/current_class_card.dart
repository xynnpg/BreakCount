import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../services/schedule_service.dart';
import '../services/storage_service.dart';
import 'glassmorphic_card.dart';

/// Shows the student's current class situation based on their schedule.
/// Modes: in class · between classes (break) · no more classes today · no schedule
class CurrentClassCard extends StatelessWidget {
  const CurrentClassCard({super.key});

  @override
  Widget build(BuildContext context) {
    final schedule = ScheduleService.getSchedule();
    final subjects = ScheduleService.getSubjects();
    if (schedule.entries.isEmpty) return const SizedBox.shrink();

    final savedWeek =
        StorageService.getString(StorageKeys.currentWeekType) ?? 'a';
    final currentWeek = WeekTypeExt.fromString(savedWeek);
    final situation = _computeSituation(schedule, subjects, currentWeek);

    return GlassmorphicCard(
      animationDelay: 50,
      child: _buildContent(context, situation),
    );
  }

  Widget _buildContent(BuildContext context, _ClassSituation s) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: s.color.withAlpha(30),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(s.icon, color: s.color, size: 22),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s.title,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (s.subtitle != null)
                Text(
                  s.subtitle!,
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
        if (s.badge != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: s.color.withAlpha(30),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              s.badge!,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: s.color,
              ),
            ),
          ),
      ],
    );
  }

  _ClassSituation _computeSituation(
      Schedule schedule, List<Subject> subjects, WeekType currentWeek) {
    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1=Mon…7=Sun

    // Weekend
    if (dayOfWeek > 5) {
      final next = _nextSchoolEntry(schedule, subjects, currentWeek, now);
      return _ClassSituation(
        icon: Icons.weekend_outlined,
        color: AppColors.accentCyan,
        label: 'WEEKEND',
        title: 'No school today',
        subtitle:
            next != null ? 'Next: ${next.subjectName} on ${_dayName(next.dayOfWeek)}' : null,
      );
    }

    final todayEntries = _sortedEntriesForDay(schedule, dayOfWeek, currentWeek);

    if (todayEntries.isEmpty) {
      return _ClassSituation(
        icon: Icons.free_breakfast_outlined,
        color: AppColors.success,
        label: 'TODAY',
        title: 'No classes today',
        subtitle: 'Enjoy your free day',
      );
    }

    final nowFrac = now.hour + now.minute / 60.0;

    // Check if currently in a class
    for (final e in todayEntries) {
      final start = e.entry.startTime.toFractionalHours();
      final end = e.entry.endTime.toFractionalHours();
      if (nowFrac >= start && nowFrac < end) {
        final remaining = end - nowFrac;
        final mins = (remaining * 60).round();
        return _ClassSituation(
          icon: Icons.book_outlined,
          color: Color(e.subject.colorValue),
          label: 'IN CLASS NOW',
          title: e.subjectName,
          subtitle: _buildSubjectSubtitle(e.entry, e.subject),
          badge: '${mins}m left',
        );
      }
    }

    // Find next class today
    _EntryWithSubject? nextToday;
    for (final e in todayEntries) {
      final start = e.entry.startTime.toFractionalHours();
      if (start > nowFrac) {
        nextToday = e;
        break;
      }
    }

    if (nextToday != null) {
      final start = nextToday.entry.startTime;
      final minsUntil =
          ((start.toFractionalHours() - nowFrac) * 60).round();
      return _ClassSituation(
        icon: Icons.schedule_outlined,
        color: AppColors.primaryPurple,
        label: 'NEXT CLASS',
        title: nextToday.subjectName,
        subtitle: _buildSubjectSubtitle(nextToday.entry, nextToday.subject),
        badge: minsUntil <= 60
            ? 'in ${minsUntil}m'
            : 'at ${start.format24h()}',
      );
    }

    // All classes done for today
    final lastEntry = todayEntries.last;
    final freeHoursLeft = 24 - lastEntry.entry.endTime.toFractionalHours();
    final freeH = freeHoursLeft.floor();
    return _ClassSituation(
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.success,
      label: 'DONE FOR TODAY',
      title: 'Classes finished',
      subtitle: 'Last was ${lastEntry.subjectName}',
      badge: '${freeH}h free',
    );
  }

  String _buildSubjectSubtitle(ScheduleEntry entry, Subject subject) {
    final parts = <String>[];
    if (subject.teacher != null) parts.add(subject.teacher!);
    final room = entry.room ?? subject.room;
    if (room != null) parts.add('Room $room');
    parts.add(
        '${entry.startTime.format24h()} – ${entry.endTime.format24h()}');
    return parts.join(' · ');
  }

  List<_EntryWithSubject> _sortedEntriesForDay(
      Schedule schedule, int dayOfWeek, WeekType currentWeek) {
    final subjects = ScheduleService.getSubjects();
    return schedule
        .entriesForDay(dayOfWeek, currentWeek)
        .map((e) {
          Subject? subj;
          try {
            subj = subjects.firstWhere((s) => s.id == e.subjectId);
          } catch (_) {}
          return subj == null ? null : _EntryWithSubject(entry: e, subject: subj);
        })
        .whereType<_EntryWithSubject>()
        .toList()
      ..sort((a, b) => a.entry.startTime
          .toFractionalHours()
          .compareTo(b.entry.startTime.toFractionalHours()));
  }

  _EntryWithSubject? _nextSchoolEntry(Schedule schedule,
      List<Subject> subjects, WeekType currentWeek, DateTime now) {
    for (int offset = 1; offset <= 7; offset++) {
      final day = now.add(Duration(days: offset));
      if (day.weekday > 5) continue;
      final entries = _sortedEntriesForDay(schedule, day.weekday, currentWeek);
      if (entries.isNotEmpty) return entries.first;
    }
    return null;
  }

  String _dayName(int day) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(day - 1).clamp(0, 6)];
  }
}

class _EntryWithSubject {
  final ScheduleEntry entry;
  final Subject subject;

  _EntryWithSubject({required this.entry, required this.subject});

  String get subjectName => subject.name;
  int get dayOfWeek => entry.dayOfWeek;
}

class _ClassSituation {
  final IconData icon;
  final Color color;
  final String label;
  final String title;
  final String? subtitle;
  final String? badge;

  const _ClassSituation({
    required this.icon,
    required this.color,
    required this.label,
    required this.title,
    this.subtitle,
    this.badge,
  });
}
