import 'package:add_2_calendar/add_2_calendar.dart';
import '../models/school_year.dart';
import '../models/exam.dart';

/// Exports school breaks and exams to the device calendar.
class CalendarService {
  const CalendarService._();

  /// Adds all future breaks from [sy] to the device calendar.
  static Future<void> exportBreaks(SchoolYear sy) async {
    try {
      final now = DateTime.now();
      final futureBreaks =
          sy.breaks.where((b) => b.endDate.isAfter(now)).toList();
      for (final b in futureBreaks) {
        final event = Event(
          title: b.name,
          description: 'School break — ${b.durationDays} days',
          location: '',
          startDate: b.startDate,
          endDate: b.endDate,
          allDay: true,
        );
        await Add2Calendar.addEvent2Cal(event);
      }
    } catch (_) {
      // Never throw to UI
    }
  }

  /// Adds a single [exam] to the device calendar.
  static Future<void> exportExam(Exam exam) async {
    try {
      final end = exam.date.add(const Duration(hours: 2));
      final event = Event(
        title: exam.subjectName != null && exam.subjectName!.isNotEmpty
            ? '${exam.subjectName} — ${exam.type.label}'
            : '${exam.title} (${exam.type.label})',
        description: exam.notes ?? '',
        location: exam.room ?? '',
        startDate: exam.date,
        endDate: end,
        allDay: false,
      );
      await Add2Calendar.addEvent2Cal(event);
    } catch (_) {
      // Never throw to UI
    }
  }
}
