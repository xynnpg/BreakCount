import '../models/school_year.dart';

/// Pure functions — no state, no I/O.
class CalculatorService {
  const CalculatorService._();

  /// Returns the next upcoming or currently active break.
  static SchoolBreak? nextBreak(SchoolYear schoolYear) {
    final now = DateTime.now();
    final upcoming = schoolYear.breaks
        .where((b) => b.isActive || b.startDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// Duration from now until [target]. Negative if target is past.
  static Duration countdown(DateTime target) {
    return target.difference(DateTime.now());
  }

  /// Progress through [semester] from 0.0 to 1.0.
  static double semesterProgress(Semester semester) {
    return semester.progress;
  }

  /// Progress through the full school year from 0.0 to 1.0.
  static double yearProgress(SchoolYear schoolYear) {
    return schoolYear.yearProgress;
  }

  /// The semester that contains today, or null.
  static Semester? currentSemester(SchoolYear schoolYear) {
    return schoolYear.currentSemester;
  }

  /// Stats map with keys: daysSurvived, daysRemaining, weekNumber, totalDays.
  static Map<String, int> getDayStats(SchoolYear schoolYear) {
    final now = DateTime.now();
    final start = schoolYear.startDate;
    final end = schoolYear.endDate;

    final total = end.difference(start).inDays;
    final survived = now.isAfter(start)
        ? now.difference(start).inDays.clamp(0, total)
        : 0;
    final remaining = now.isBefore(end)
        ? end.difference(now).inDays.clamp(0, total)
        : 0;

    // ISO week number
    final weekNumber = _isoWeekNumber(now);

    return {
      'daysSurvived': survived,
      'daysRemaining': remaining,
      'weekNumber': weekNumber,
      'totalDays': total,
    };
  }

  /// Days remaining until next break. Returns 0 if break is active, -1 if none.
  static int daysUntilNextBreak(SchoolYear schoolYear) {
    final next = nextBreak(schoolYear);
    if (next == null) return -1;
    if (next.isActive) return 0;
    return next.startDate.difference(DateTime.now()).inDays;
  }

  /// Whether we are currently in a break period.
  static bool isOnBreak(SchoolYear schoolYear) {
    return schoolYear.breaks.any((b) => b.isActive);
  }

  /// The active break, if any.
  static SchoolBreak? activeBreak(SchoolYear schoolYear) {
    try {
      return schoolYear.breaks.firstWhere((b) => b.isActive);
    } catch (_) {
      return null;
    }
  }

  /// School year ended (all breaks in the past, end date passed).
  static bool isYearOver(SchoolYear schoolYear) {
    return DateTime.now().isAfter(schoolYear.endDate);
  }

  // ISO 8601 week number
  static int _isoWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) return 52;
    if (woy > 52) return 1;
    return woy;
  }

  /// Format a Duration into {"days": d, "hours": h, "minutes": m, "seconds": s}
  static Map<String, int> formatCountdown(Duration duration) {
    if (duration.isNegative) {
      return {'days': 0, 'hours': 0, 'minutes': 0, 'seconds': 0};
    }
    final totalSeconds = duration.inSeconds;
    final days = totalSeconds ~/ 86400;
    final hours = (totalSeconds % 86400) ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }
}
