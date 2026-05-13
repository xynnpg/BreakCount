import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'achievement_service.dart';
import 'storage_service.dart';

/// One logged study session.
class StudyLog {
  final String id;
  final String subjectId;
  final String subjectName;
  final int minutes;
  final DateTime timestamp;

  const StudyLog({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.minutes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject_id': subjectId,
        'subject_name': subjectName,
        'minutes': minutes,
        'ts': timestamp.toIso8601String(),
      };

  factory StudyLog.fromJson(Map<String, dynamic> j) => StudyLog(
        id: j['id'] as String,
        subjectId: j['subject_id'] as String,
        subjectName: j['subject_name'] as String? ?? '',
        minutes: j['minutes'] as int,
        timestamp: DateTime.parse(j['ts'] as String),
      );
}

/// Persists user-logged study sessions and computes aggregates for the Stats
/// screen.
class StudyLogService {
  static const String _key = 'study_log_v1';

  /// Listeners for UI refreshes.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Log a new session. Fires achievement ladder via
  /// [AchievementService.onStudySessionLogged].
  static Future<void> logSession({
    required String subjectId,
    required String subjectName,
    required int minutes,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now();
    final all = _readAll();
    final entry = StudyLog(
      id: 'sl_${ts.microsecondsSinceEpoch}',
      subjectId: subjectId,
      subjectName: subjectName,
      minutes: minutes,
      timestamp: ts,
    );
    all.add(entry);
    await StorageService.saveString(
        _key, jsonEncode(all.map((e) => e.toJson()).toList()));
    revision.value++;

    // Achievements.
    final weeklyMinutes = _weeklyMinutesFor(entry.timestamp, all);
    await AchievementService.onStudySessionLogged(
      totalSessions: all.length,
      sessionMinutes: minutes,
      weeklyMinutesAfterThis: weeklyMinutes,
    );
  }

  /// All logged sessions, ordered newest first.
  static List<StudyLog> all() {
    final list = _readAll()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Minutes logged per subject name over the trailing 7 days ending at
  /// [anchor].
  static Map<String, int> weeklyBreakdown({DateTime? anchor}) {
    final end = anchor ?? DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    final result = <String, int>{};
    for (final log in _readAll()) {
      if (log.timestamp.isBefore(start) || log.timestamp.isAfter(end)) continue;
      result[log.subjectName] = (result[log.subjectName] ?? 0) + log.minutes;
    }
    return result;
  }

  /// Total minutes for the calendar-week containing [date].
  static int totalMinutesInWeekOf(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7));
    var total = 0;
    for (final log in _readAll()) {
      if (log.timestamp.isAfter(weekStart) &&
          log.timestamp.isBefore(weekEnd)) {
        total += log.minutes;
      }
    }
    return total;
  }

  /// Total minutes ever logged.
  static int totalMinutes() {
    return _readAll().fold(0, (sum, l) => sum + l.minutes);
  }

  /// Total sessions ever logged.
  static int totalSessions() => _readAll().length;

  @visibleForTesting
  static Future<void> resetForTests() async {
    revision.value = 0;
    await StorageService.delete(_key);
  }

  // ── Internals ────────────────────────────────────────────────────────────

  static List<StudyLog> _readAll() {
    final raw = StorageService.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => StudyLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static int _weeklyMinutesFor(DateTime date, List<StudyLog> all) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7));
    var total = 0;
    for (final log in all) {
      if (log.timestamp.isAfter(weekStart) &&
          log.timestamp.isBefore(weekEnd)) {
        total += log.minutes;
      }
    }
    return total;
  }
}
