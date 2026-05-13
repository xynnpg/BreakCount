import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/app/theme_preset.dart';
import 'package:breakcount/data/achievements_data.dart';
import 'package:breakcount/services/achievement_service.dart';
import 'package:breakcount/services/storage_service.dart';
import 'package:breakcount/services/streak_service.dart';
import 'package:breakcount/services/unlock_service.dart';
import 'package:breakcount/services/xp_service.dart';

/// Integration test verifying the v2.1.0 cross-cutting flows work end-to-end.
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
    AppThemeController.init(null);
  });

  test('fresh state → XP 0, level 1, streak 0', () {
    expect(XpService.totalXp(), 0);
    expect(XpService.level(), 1);
    expect(StreakService.currentStreak, 0);
  });

  test('unlock achievement → XP increments', () async {
    await AchievementService.unlock('first_day');
    expect(XpService.totalXp(), greaterThan(0));
  });

  test('streak recordOpen → streak becomes 1', () async {
    final s = await StreakService.recordOpen(now: DateTime(2026, 5, 12));
    expect(s, 1);
    expect(StreakService.currentStreak, 1);
  });

  test('default themes unlocked, streak-gated themes locked at streak 0', () {
    expect(UnlockService.isThemeUnlocked('coffee'), true);
    expect(UnlockService.isThemeUnlocked('midnight'), true);
    expect(UnlockService.isThemeUnlocked('lavender'), false);
    expect(UnlockService.isThemeUnlocked('amoled'), false);
  });

  test('ThemePreset.fromId resolves all presets for widget payload', () {
    final midnight = ThemePreset.fromId('midnight');
    expect(midnight.id, 'midnight');
    expect(midnight.dark, true);
    expect(midnight.bgSurface.toARGB32(), isNonZero);
    expect(midnight.primary.toARGB32(), isNonZero);
  });

  test('achievement count matches data integrity', () {
    expect(kAchievements.length, greaterThanOrEqualTo(90));
    final ids = kAchievements.map((a) => a.id).toSet();
    expect(ids.length, kAchievements.length, reason: 'no duplicate IDs');
  });
}
