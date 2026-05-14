import 'dart:convert';

import '../models/school_year.dart';
import '../services/achievement_service.dart';
import '../services/calculator_service.dart';
import '../services/storage_service.dart';

/// Mood index scale used across the app. Keep in sync with the emoji order in
/// [MoodService.kMoodEmojis].
class MoodKind {
  /// Index 0 — 💀 absolutely done
  static const int dead = 0;

  /// Index 1 — 😩 struggling
  static const int struggle = 1;

  /// Index 2 — 😐 neutral
  static const int neutral = 2;

  /// Index 3 — 👀 hopeful
  static const int hopeful = 3;

  /// Index 4 — 🔥 on fire
  static const int fire = 4;

  /// Index 5 — 🤩 hyped
  static const int hyped = 5;

  /// Index 6 — 🏖️ on break
  static const int onBreak = 6;
}

/// Snapshot of how the user felt on a specific day, derived from their
/// distance-to-break + day/time modifiers.
class MoodSnapshot {
  final DateTime date; // date-only (UTC-naive calendar date)
  final int index;
  const MoodSnapshot({required this.date, required this.index});
}

/// Aggregated weekly recap stats, consumed by the recap AI service and the
/// in-app recap card.
class WeeklyRecap {
  /// mood index → count over the past 7 days
  final Map<int, int> moodCounts;
  final int bumpCount;
  final List<String> achievementsUnlocked;
  final int streakPeak;
  final String dominantPersona;
  final DateTime anchor;

  const WeeklyRecap({
    required this.moodCounts,
    required this.bumpCount,
    required this.achievementsUnlocked,
    required this.streakPeak,
    required this.dominantPersona,
    required this.anchor,
  });

  /// JSON of anonymized stats — safe to send to an AI endpoint.
  /// Does not include: display name, dates, achievement ids.
  Map<String, dynamic> toAnonJson() => {
        'mood_counts': moodCounts.map((k, v) => MapEntry('$k', v)),
        'bumps': bumpCount,
        'unlocks': achievementsUnlocked.length,
        'streak_peak': streakPeak,
        'persona': dominantPersona,
      };

  int get totalDaysRecorded => moodCounts.values.fold(0, (a, b) => a + b);

  /// Dominant mood index (most frequent). Returns null if no data.
  int? get dominantMood {
    if (moodCounts.isEmpty) return null;
    var best = moodCounts.entries.first;
    for (final e in moodCounts.entries) {
      if (e.value > best.value) best = e;
    }
    return best.key;
  }
}

/// Persists daily mood snapshots and computes streaks / weekly breakdown.
///
/// Storage layout:
///   key 'mood_history_v1' &rarr; JSON `Map<String, int>` (ISO date &rarr; mood index)
class MoodService {
  static const String _historyKey = 'mood_history_v1';

  static const List<String> kMoodEmojis = [
    '💀', // dead
    '😩', // struggle
    '😐', // neutral
    '👀', // hopeful
    '🔥', // fire
    '🤩', // hyped
    '🏖️', // onBreak
  ];

  // ── Public API ───────────────────────────────────────────────────────────

  /// Returns the mood emoji for a given index. Safe for 0..6.
  static String emojiFor(int index) {
    if (index < 0 || index >= kMoodEmojis.length) return '😐';
    return kMoodEmojis[index];
  }

  /// Compute the mood index from raw context (days to break, on-break flag,
  /// current wallclock time). Keeps logic identical to the original inline
  /// version in counter_personality_card.dart so we don't shift user-facing
  /// behaviour when extracting.
  static int computeMoodIndex(
    int daysUntilBreak,
    bool isOnBreak, {
    DateTime? now,
  }) {
    if (isOnBreak) return MoodKind.onBreak;
    int mood;
    if (daysUntilBreak <= 2) {
      mood = 5;
    } else if (daysUntilBreak <= 7) {
      mood = 4;
    } else if (daysUntilBreak <= 15) {
      mood = 3;
    } else if (daysUntilBreak <= 30) {
      mood = 2;
    } else if (daysUntilBreak <= 60) {
      mood = 1;
    } else {
      mood = 0;
    }
    final n = now ?? DateTime.now();
    if (n.weekday == DateTime.friday && n.hour >= 14) mood++;
    if (n.weekday == DateTime.monday && n.hour < 10) mood--;
    return mood.clamp(0, 6);
  }

  /// Persist today's mood for the given schoolYear.
  /// Idempotent within a day (overwrites same-day entry with the latest value
  /// so cycling the app at different times reflects the latest mood).
  ///
  /// Returns newly unlocked achievement ids (fire streaks, hell week,
  /// rollercoaster). The caller is expected to surface overlays.
  static Future<List<String>> recordDailyMood(
    SchoolYear sy, {
    DateTime? now,
  }) async {
    final n = now ?? DateTime.now();
    final next = CalculatorService.nextBreak(sy);
    final isOnBreak = CalculatorService.isOnBreak(sy);
    int daysUntil = 0;
    if (next != null) {
      final target =
          next.isActive ? next.endDate : next.startDate;
      daysUntil = target.difference(n).inDays;
      if (daysUntil < 0) daysUntil = 0;
    }
    final mood = computeMoodIndex(daysUntil, isOnBreak, now: n);
    final history = _readHistory();
    history[_isoDate(n)] = mood;
    await _writeHistory(history);

    // Fire off achievement checks using current streak stats.
    final fireStreak = currentStreak(MoodKind.fire, now: n);
    final deadStreak = currentStreak(MoodKind.dead, now: n);
    final rollercoaster = hasRollercoaster(now: n);
    return AchievementService.checkMoodAchievements(
      fireStreak: fireStreak,
      deadStreak: deadStreak,
      rollercoaster: rollercoaster,
      totalMoodLogs: history.length,
    );
  }

  /// Returns all recorded mood snapshots, ordered chronologically.
  static List<MoodSnapshot> history() {
    final raw = _readHistory();
    final list = raw.entries
        .map((e) {
          final d = DateTime.tryParse(e.key);
          if (d == null) return null;
          return MoodSnapshot(date: d, index: e.value);
        })
        .whereType<MoodSnapshot>()
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Count of consecutive days ending today where mood equals [moodKind].
  /// Missing days break the streak.
  static int currentStreak(int moodKind, {DateTime? now}) {
    final history = _readHistory();
    if (history.isEmpty) return 0;
    var cursor = _dateOnly(now ?? DateTime.now());
    var streak = 0;
    while (true) {
      final key = _isoDate(cursor);
      final recorded = history[key];
      if (recorded == null || recorded != moodKind) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Best consecutive-day streak of [moodKind] found within the trailing
  /// [window]. Used for recap stats.
  static int maxStreakPeak(
    int moodKind, {
    Duration window = const Duration(days: 30),
    DateTime? now,
  }) {
    final history = _readHistory();
    if (history.isEmpty) return 0;
    final end = _dateOnly(now ?? DateTime.now());
    final start = end.subtract(window);
    var best = 0;
    var current = 0;
    for (var d = start;
        !d.isAfter(end);
        d = d.add(const Duration(days: 1))) {
      final rec = history[_isoDate(d)];
      if (rec == moodKind) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  /// Mood&rarr;count map for the trailing 7 days ending at [anchor].
  static Map<int, int> weeklyBreakdown({DateTime? anchor}) {
    final end = _dateOnly(anchor ?? DateTime.now());
    final history = _readHistory();
    final Map<int, int> counts = {};
    for (var i = 0; i < 7; i++) {
      final d = end.subtract(Duration(days: i));
      final rec = history[_isoDate(d)];
      if (rec != null) counts[rec] = (counts[rec] ?? 0) + 1;
    }
    return counts;
  }

  /// True if any rolling 7-day window within [window] contains all 6 "on-school"
  /// mood values (indices 0..5). 🏖️ is excluded since being on break is
  /// a separate state, not a mood to diversify against.
  static bool hasRollercoaster({
    Duration window = const Duration(days: 30),
    DateTime? now,
  }) {
    final end = _dateOnly(now ?? DateTime.now());
    final start = end.subtract(window);
    final history = _readHistory();
    // Build a day→mood list within the window.
    final values = <int?>[];
    for (var d = start;
        !d.isAfter(end);
        d = d.add(const Duration(days: 1))) {
      values.add(history[_isoDate(d)]);
    }
    for (var i = 0; i + 7 <= values.length; i++) {
      final slice = values.sublist(i, i + 7).whereType<int>().toSet();
      slice.remove(MoodKind.onBreak);
      if (slice.length >= 6) return true;
    }
    return false;
  }

  /// Build weekly recap for the week ending at [anchor].
  /// Bumps + unlocks are passed in by the caller (we don't import AchievementService
  /// directly here to keep a clean dependency shape).
  static WeeklyRecap buildWeeklyRecap({
    DateTime? anchor,
    required int bumpsThisWeek,
    required List<String> achievementsThisWeek,
    required String dominantPersona,
  }) {
    final a = anchor ?? DateTime.now();
    return WeeklyRecap(
      moodCounts: weeklyBreakdown(anchor: a),
      bumpCount: bumpsThisWeek,
      achievementsUnlocked: achievementsThisWeek,
      streakPeak: maxStreakPeak(MoodKind.fire,
          window: const Duration(days: 7), now: a),
      dominantPersona: dominantPersona,
      anchor: _dateOnly(a),
    );
  }

  /// Test-only reset.
  static Future<void> resetForTests() async {
    await StorageService.delete(_historyKey);
  }

  /// Test-only: write a specific mood for [date] (date-only). Used to build
  /// deterministic histories in unit tests without depending on
  /// CalculatorService.nextBreak which hard-codes DateTime.now().
  static Future<void> setMoodForTests(DateTime date, int mood) async {
    final history = _readHistory();
    history[_isoDate(date)] = mood;
    await _writeHistory(history);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  static Map<String, int> _readHistory() {
    final raw = StorageService.getString(_historyKey);
    if (raw == null) return <String, int>{};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return <String, int>{};
    }
  }

  static Future<void> _writeHistory(Map<String, int> value) async {
    await StorageService.saveString(_historyKey, jsonEncode(value));
  }

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static String _isoDate(DateTime d) {
    final dd = _dateOnly(d);
    return '${dd.year.toString().padLeft(4, '0')}-'
        '${dd.month.toString().padLeft(2, '0')}-'
        '${dd.day.toString().padLeft(2, '0')}';
  }
}
