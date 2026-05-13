import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/services/achievement_service.dart';
import 'package:breakcount/services/mood_service.dart';
import 'package:breakcount/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (call) async => null,
      )
      ..setMockMethodCallHandler(
        const MethodChannel('com.breakcount.app/timezone'),
        (call) async => 'UTC',
      );
    await StorageService.init();
    await AchievementService.resetForTests();
    await MoodService.resetForTests();
    AchievementService.init();
  });

  group('computeMoodIndex', () {
    test('on-break always returns onBreak mood', () {
      final mood = MoodService.computeMoodIndex(0, true,
          now: DateTime(2025, 12, 25, 12));
      expect(mood, MoodKind.onBreak);
    });

    test('far-away break yields dead mood', () {
      final mood = MoodService.computeMoodIndex(120, false,
          now: DateTime(2025, 10, 15, 12));
      expect(mood, MoodKind.dead);
    });

    test('nearby break yields hyped mood', () {
      final mood = MoodService.computeMoodIndex(1, false,
          now: DateTime(2025, 12, 20, 12));
      expect(mood, MoodKind.hyped);
    });

    test('friday afternoon bumps the mood up', () {
      final noBoost = MoodService.computeMoodIndex(10, false,
          now: DateTime(2025, 10, 1, 10)); // Wednesday morning
      final friBoost = MoodService.computeMoodIndex(10, false,
          now: DateTime(2025, 10, 3, 15)); // Friday 15:00
      expect(friBoost, greaterThan(noBoost));
    });

    test('monday morning drops the mood down', () {
      final tue = MoodService.computeMoodIndex(10, false,
          now: DateTime(2025, 10, 7, 8)); // Tuesday 8am
      final mon = MoodService.computeMoodIndex(10, false,
          now: DateTime(2025, 10, 6, 8)); // Monday 8am
      expect(mon, lessThan(tue));
    });
  });

  group('currentStreak', () {
    test('empty history returns 0', () {
      expect(MoodService.currentStreak(MoodKind.fire), 0);
    });

    test('counts consecutive matching days only', () async {
      // Deterministic seeding — no dependency on CalculatorService.nextBreak.
      for (var i = 15; i <= 18; i++) {
        await MoodService.setMoodForTests(
            DateTime(2025, 12, i, 12), MoodKind.fire);
      }
      expect(
          MoodService.currentStreak(MoodKind.fire,
              now: DateTime(2025, 12, 18, 20)),
          4);
      // Missing day Dec 19 — streak broken if asked for Dec 20.
      expect(
          MoodService.currentStreak(MoodKind.fire,
              now: DateTime(2025, 12, 20, 20)),
          0);
    });

    test('mixed moods stop the streak', () async {
      await MoodService.setMoodForTests(
          DateTime(2025, 12, 17), MoodKind.fire);
      await MoodService.setMoodForTests(
          DateTime(2025, 12, 18), MoodKind.neutral);
      await MoodService.setMoodForTests(
          DateTime(2025, 12, 19), MoodKind.fire);
      expect(
          MoodService.currentStreak(MoodKind.fire,
              now: DateTime(2025, 12, 19, 20)),
          1);
    });
  });

  group('weeklyBreakdown', () {
    test('returns only recorded days in the trailing 7', () async {
      await MoodService.setMoodForTests(
          DateTime(2025, 12, 18), MoodKind.fire);
      await MoodService.setMoodForTests(
          DateTime(2025, 12, 19), MoodKind.hyped);
      final map = MoodService.weeklyBreakdown(
          anchor: DateTime(2025, 12, 21, 12));
      expect(map.values.fold<int>(0, (a, b) => a + b), 2);
      expect(map[MoodKind.fire], 1);
      expect(map[MoodKind.hyped], 1);
    });
  });

  group('hasRollercoaster', () {
    test('true when all 6 school moods appear within a 7-day window',
        () async {
      for (var i = 0; i < 6; i++) {
        await MoodService.setMoodForTests(
            DateTime(2025, 10, 1 + i), i);
      }
      expect(
          MoodService.hasRollercoaster(
              window: const Duration(days: 14),
              now: DateTime(2025, 10, 7)),
          isTrue);
    });

    test('false when fewer than 6 distinct moods', () async {
      for (var i = 0; i < 3; i++) {
        await MoodService.setMoodForTests(
            DateTime(2025, 10, 1 + i), i);
      }
      expect(
          MoodService.hasRollercoaster(
              window: const Duration(days: 14),
              now: DateTime(2025, 10, 7)),
          isFalse);
    });
  });

  group('recordDailyMood integration', () {
    test('seven fire days unlock on_fire_7', () async {
      await AchievementService.checkMoodAchievements(
        fireStreak: 7,
        deadStreak: 0,
        rollercoaster: false,
      );
      expect(AchievementService.isUnlocked('on_fire_7'), isTrue);
    });

    test('three dead days unlock hell_week', () async {
      await AchievementService.checkMoodAchievements(
        fireStreak: 0,
        deadStreak: 3,
        rollercoaster: false,
      );
      expect(AchievementService.isUnlocked('hell_week'), isTrue);
    });

    test('rollercoaster flag unlocks mood_rollercoaster', () async {
      await AchievementService.checkMoodAchievements(
        fireStreak: 0,
        deadStreak: 0,
        rollercoaster: true,
      );
      expect(AchievementService.isUnlocked('mood_rollercoaster'), isTrue);
    });
  });
}
