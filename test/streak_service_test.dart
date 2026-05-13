import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/services/storage_service.dart';
import 'package:breakcount/services/streak_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    await StreakService.resetForTests();
    StreakService.init();
  });

  group('StreakService.recordOpen', () {
    test('first open → streak becomes 1', () async {
      final s = await StreakService.recordOpen(now: DateTime(2026, 5, 1));
      expect(s, 1);
      expect(StreakService.currentStreak, 1);
      expect(StreakService.longestStreak, 1);
    });

    test('same-day reopen → noop', () async {
      await StreakService.recordOpen(now: DateTime(2026, 5, 1, 8));
      final s =
          await StreakService.recordOpen(now: DateTime(2026, 5, 1, 20));
      expect(s, 1);
      expect(StreakService.currentStreak, 1);
    });

    test('consecutive days → increments', () async {
      await StreakService.recordOpen(now: DateTime(2026, 5, 1));
      await StreakService.recordOpen(now: DateTime(2026, 5, 2));
      final s = await StreakService.recordOpen(now: DateTime(2026, 5, 3));
      expect(s, 3);
      expect(StreakService.longestStreak, 3);
    });

    test('skipped day → resets to 1 but longest stays', () async {
      await StreakService.recordOpen(now: DateTime(2026, 5, 1));
      await StreakService.recordOpen(now: DateTime(2026, 5, 2));
      await StreakService.recordOpen(now: DateTime(2026, 5, 3));
      // Skip May 4
      final s = await StreakService.recordOpen(now: DateTime(2026, 5, 5));
      expect(s, 1);
      expect(StreakService.currentStreak, 1);
      expect(StreakService.longestStreak, 3);
    });

    test('fires milestone listener with current streak', () async {
      final events = <int>[];
      StreakService.addMilestoneListener(events.add);
      await StreakService.recordOpen(now: DateTime(2026, 5, 1));
      await StreakService.recordOpen(now: DateTime(2026, 5, 2));
      expect(events, [1, 2]);
    });
  });

  group('StreakService persistence', () {
    test('init reads persisted values', () async {
      await StreakService.recordOpen(now: DateTime(2026, 5, 1));
      await StreakService.recordOpen(now: DateTime(2026, 5, 2));
      expect(StreakService.currentStreak, 2);
      // Simulate restart: drop in-memory, call init again.
      StreakService.currentNotifier.value = 0;
      StreakService.longestNotifier.value = 0;
      StreakService.init();
      expect(StreakService.currentStreak, 2);
      expect(StreakService.longestStreak, 2);
    });
  });
}
