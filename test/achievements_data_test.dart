import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/data/achievements_data.dart';
import 'package:breakcount/services/achievement_service.dart';
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
    AchievementService.init();
  });

  group('kAchievements', () {
    test('has ~100 entries', () {
      expect(kAchievements.length, greaterThanOrEqualTo(90));
    });

    test('ids are unique', () {
      final ids = kAchievements.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every achievement has effectiveXp > 0', () {
      for (final a in kAchievements) {
        expect(a.effectiveXp, greaterThan(0), reason: a.id);
      }
    });

    test('every category is used', () {
      final used = kAchievements.map((a) => a.category).toSet();
      // All new categories should be represented.
      expect(used, containsAll([
        AchievementCategory.streaks,
        AchievementCategory.appOpen,
        AchievementCategory.themes,
        AchievementCategory.personas,
        AchievementCategory.study,
        AchievementCategory.seasonal,
      ]));
    });
  });

  group('v2.1.0 helper fires', () {
    test('onStreakMilestone(7) unlocks streak_7', () async {
      final newly = await AchievementService.onStreakMilestone(7);
      expect(newly, contains('streak_7'));
      expect(AchievementService.isUnlocked('streak_7'), isTrue);
    });

    test('onStreakMilestone with non-milestone day is noop', () async {
      final newly = await AchievementService.onStreakMilestone(4);
      expect(newly, isEmpty);
    });

    test('onThemeUnlocked ladder', () async {
      final n3 = await AchievementService.onThemeUnlocked(3);
      expect(n3, contains('theme_explorer'));
      final n6 = await AchievementService.onThemeUnlocked(6);
      expect(n6, contains('theme_collector'));
    });

    test('onBreakReached summer unlocks and all_seasonal_breaks triggers when all 4 seen', () async {
      await AchievementService.onBreakReached('autumn');
      await AchievementService.onBreakReached('winter');
      await AchievementService.onBreakReached('spring');
      final n = await AchievementService.onBreakReached('summer');
      expect(n, contains('survived_summer'));
      expect(n, contains('all_seasonal_breaks'));
    });

    test('onStudySessionLogged 3h unlocks marathon', () async {
      final n = await AchievementService.onStudySessionLogged(
          totalSessions: 1, sessionMinutes: 180);
      expect(n, contains('first_study'));
      expect(n, contains('study_marathon'));
    });

    test('onAchievementCountChanged ticks hunter ladder', () async {
      // Force-unlock 10 distinct ids.
      for (var i = 0; i < 10; i++) {
        await AchievementService.unlock('_test_$i');
      }
      final n = await AchievementService.onAchievementCountChanged();
      expect(n, contains('achievement_hunter_10'));
    });

    test('onLevelReached unlocks level tier', () async {
      final n = await AchievementService.onLevelReached(5);
      expect(n, contains('level_5'));
    });
  });
}
