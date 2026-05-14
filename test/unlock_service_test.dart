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
    await UnlockService.resetForTests();
    UnlockService.init();
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

  group('Permanent unlock persistence', () {
    test('recordThemeUnlock persists across init() reload with zero streak', () async {
      expect(UnlockService.isThemeUnlocked('lavender'), isFalse);
      await UnlockService.recordThemeUnlock('lavender');
      expect(UnlockService.isThemeUnlocked('lavender'), isTrue);
      // Simulate reload (e.g. after restore).
      UnlockService.init();
      expect(UnlockService.isThemeUnlocked('lavender'), isTrue,
          reason: 'should remain unlocked after re-init with streak = 0');
    });

    test('recordPersonaUnlock persists across init() reload with zero streak', () async {
      expect(UnlockService.isPersonaUnlocked('nerd'), isFalse);
      await UnlockService.recordPersonaUnlock('nerd');
      expect(UnlockService.isPersonaUnlocked('nerd'), isTrue);
      UnlockService.init();
      expect(UnlockService.isPersonaUnlocked('nerd'), isTrue,
          reason: 'should remain unlocked after re-init with streak = 0');
    });

    test('backup round-trip: pre-seeded storage key unlocks theme on init()', () async {
      // Simulate a restored backup that contains the permanent-unlock key.
      await StorageService.saveString('unlocked_themes_v1', '["lavender","forest"]');
      UnlockService.init();
      expect(UnlockService.isThemeUnlocked('lavender'), isTrue);
      expect(UnlockService.isThemeUnlocked('forest'), isTrue);
      // Streak is still 0 — unlock must come from the persisted set alone.
      expect(StreakService.currentStreak, 0);
    });

    test('resetForTests clears permanent sets', () async {
      await UnlockService.recordThemeUnlock('lavender');
      await UnlockService.resetForTests();
      UnlockService.init();
      expect(UnlockService.isThemeUnlocked('lavender'), isFalse);
    });

    test('init() backfills themes from longestStreak', () async {
      // Simulate a user who already has a 7-day streak but no permanent sets.
      await StreakService.debugSet(7);
      await UnlockService.resetForTests();
      UnlockService.init();
      // Give the unawaited backfill a microtask to complete.
      await Future<void>.delayed(Duration.zero);
      expect(UnlockService.isThemeUnlocked('lavender'), isTrue,
          reason: 'lavender requires streak 7 — should be backfilled');
      expect(UnlockService.isThemeUnlocked('forest'), isFalse,
          reason: 'forest requires streak 14 — should not be backfilled at 7');
    });

    test('init() backfills personas from longestStreak', () async {
      await StreakService.debugSet(14);
      await UnlockService.resetForTests();
      UnlockService.init();
      await Future<void>.delayed(Duration.zero);
      expect(UnlockService.isPersonaUnlocked('nerd'), isTrue);   // streak 3
      expect(UnlockService.isPersonaUnlocked('tired'), isTrue);  // streak 7
      expect(UnlockService.isPersonaUnlocked('ice'), isTrue);    // streak 14
      expect(UnlockService.isPersonaUnlocked('gremlin'), isFalse); // streak 21
    });
  });
}
