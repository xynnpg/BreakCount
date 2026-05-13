import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/services/achievement_service.dart';
import 'package:breakcount/services/storage_service.dart';
import 'package:breakcount/services/streak_service.dart';
import 'package:breakcount/services/unlock_service.dart';

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
    await StreakService.resetForTests();
    StreakService.init();
    await AchievementService.resetForTests();
    AchievementService.init();
  });

  group('Theme unlocks', () {
    test('all six defaults unlocked fresh', () {
      for (final id in const ['coffee', 'midnight', 'mint', 'sakura', 'ocean', 'sunset']) {
        expect(UnlockService.isThemeUnlocked(id), isTrue,
            reason: '$id should be default-unlocked');
      }
    });

    test('lavender locked at 0 streak, unlocks exactly at 7', () async {
      expect(UnlockService.isThemeUnlocked('lavender'), isFalse);
      await StreakService.debugSet(6);
      expect(UnlockService.isThemeUnlocked('lavender'), isFalse);
      await StreakService.debugSet(7);
      expect(UnlockService.isThemeUnlocked('lavender'), isTrue);
    });

    test('amoled unlocks exactly at streak 150', () async {
      expect(UnlockService.isThemeUnlocked('amoled'), isFalse);
      await StreakService.debugSet(149);
      expect(UnlockService.isThemeUnlocked('amoled'), isFalse);
      await StreakService.debugSet(150);
      expect(UnlockService.isThemeUnlocked('amoled'), isTrue);
    });

    test('zen is achievement-gated', () async {
      expect(UnlockService.isThemeUnlocked('zen'), isFalse);
      await AchievementService.unlock('all_seasonal_breaks');
      expect(UnlockService.isThemeUnlocked('zen'), isTrue);
    });
  });

  group('Persona unlocks', () {
    test('base four personas always unlocked', () {
      for (final id in ['hype', 'chill', 'dramatic', 'sarcastic']) {
        expect(UnlockService.isPersonaUnlocked(id), isTrue);
      }
    });

    test('nerd unlocks at 3-day streak', () async {
      expect(UnlockService.isPersonaUnlocked('nerd'), isFalse);
      await StreakService.debugSet(3);
      expect(UnlockService.isPersonaUnlocked('nerd'), isTrue);
    });
  });

  group('Milestone helpers', () {
    test('themesUnlockedByStreak returns exact matches only', () {
      expect(UnlockService.themesUnlockedByStreak(7),
          contains('lavender'));
      expect(UnlockService.themesUnlockedByStreak(14),
          contains('forest'));
      expect(UnlockService.themesUnlockedByStreak(42), isEmpty);
    });

    test('personasUnlockedByAchievement returns the persona gated by it', () {
      expect(UnlockService.personasUnlockedByAchievement('50_mondays'),
          contains('ghost'));
    });
  });
}
