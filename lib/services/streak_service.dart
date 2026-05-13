import 'package:flutter/foundation.dart';

import 'storage_service.dart';

/// Tracks consecutive-day streaks (currentStreak, longestStreak). Incremented
/// once per calendar day on [recordOpen]. Persisted via SharedPreferences.
class StreakService {
  static const String _lastKey = 'streak_last_open_date';
  static const String _currentKey = 'streak_current';
  static const String _longestKey = 'streak_longest';

  /// Current streak — listeners can rebuild on changes.
  static final ValueNotifier<int> currentNotifier = ValueNotifier<int>(0);

  /// Longest streak observed.
  static final ValueNotifier<int> longestNotifier = ValueNotifier<int>(0);

  /// Callbacks fired when the streak crosses a milestone (same integer, i.e.
  /// when currentStreak == [milestone]). Used by UnlockService to surface
  /// theme/persona unlocks.
  static final List<void Function(int)> _milestoneListeners = [];

  static void addMilestoneListener(void Function(int) fn) =>
      _milestoneListeners.add(fn);

  static void removeMilestoneListener(void Function(int) fn) =>
      _milestoneListeners.remove(fn);

  static int get currentStreak => currentNotifier.value;
  static int get longestStreak => longestNotifier.value;

  /// Loads persisted streak into memory. Must be called once at startup.
  static void init() {
    currentNotifier.value = StorageService.getInt(_currentKey) ?? 0;
    longestNotifier.value = StorageService.getInt(_longestKey) ?? 0;
  }

  /// Records today's open. Returns the new current streak value.
  ///
  /// - Same day as last open → no-op.
  /// - Next day → streak++ (and longest if beaten).
  /// - Gap of 2+ days → streak resets to 1.
  /// - First open ever → streak becomes 1.
  static Future<int> recordOpen({DateTime? now}) async {
    final today = _dateOnly(now ?? DateTime.now());
    final todayIso = _iso(today);
    final last = StorageService.getString(_lastKey);

    int newStreak;
    if (last == null) {
      newStreak = 1;
    } else if (last == todayIso) {
      return currentStreak; // same day — no-op
    } else {
      final lastDate = DateTime.tryParse(last);
      if (lastDate == null) {
        newStreak = 1;
      } else {
        final diff = today.difference(_dateOnly(lastDate)).inDays;
        newStreak = diff == 1 ? currentStreak + 1 : 1;
      }
    }

    await StorageService.saveString(_lastKey, todayIso);
    await StorageService.saveInt(_currentKey, newStreak);
    currentNotifier.value = newStreak;

    if (newStreak > longestStreak) {
      await StorageService.saveInt(_longestKey, newStreak);
      longestNotifier.value = newStreak;
    }

    // Fire milestone listeners — useful for theme/persona unlock hooks.
    for (final fn in List.of(_milestoneListeners)) {
      try {
        fn(newStreak);
      } catch (_) {}
    }

    return newStreak;
  }

  /// Debug helper — force-sets the current streak. Used by settings debug row.
  @visibleForTesting
  static Future<void> debugSet(int streak) async {
    await StorageService.saveInt(_currentKey, streak);
    currentNotifier.value = streak;
    if (streak > longestStreak) {
      await StorageService.saveInt(_longestKey, streak);
      longestNotifier.value = streak;
    }
    for (final fn in List.of(_milestoneListeners)) {
      try {
        fn(streak);
      } catch (_) {}
    }
  }

  /// Test-only reset.
  @visibleForTesting
  static Future<void> resetForTests() async {
    currentNotifier.value = 0;
    longestNotifier.value = 0;
    _milestoneListeners.clear();
    await StorageService.delete(_lastKey);
    await StorageService.delete(_currentKey);
    await StorageService.delete(_longestKey);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
