import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/data/achievements_data.dart';
import 'package:breakcount/services/achievement_service.dart';
import 'package:breakcount/services/storage_service.dart';
import 'package:breakcount/services/xp_service.dart';

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

  test('fresh install → level 1, rank Newcomer', () {
    expect(XpService.totalXp(), 0);
    expect(XpService.level(), 1);
    expect(XpService.rankName(), 'Newcomer');
    expect(XpService.progress(), 0);
  });

  test('unlocking first_day (bronze) awards 25 xp', () async {
    await AchievementService.unlock('first_day');
    expect(XpService.totalXp(), 25);
    expect(XpService.level(), 1);
    expect(XpService.rankName(), 'Newcomer');
  });

  test('crossing 200 XP promotes to level 2 Rookie', () async {
    await XpService.grantBonusXp(200);
    expect(XpService.totalXp(), 200);
    expect(XpService.level(), 2);
    expect(XpService.rankName(), 'Rookie');
    expect(XpService.progress(), 0);
  });

  test('progress math halfway through a band', () async {
    // Level 2 (200) → Level 3 (600) → band of 400. Put 400 total XP (200 in band).
    await XpService.grantBonusXp(400);
    expect(XpService.level(), 2);
    expect(XpService.progress(), 0.5);
    expect(XpService.xpToNextLevel(), 200);
  });

  test('past level 10 thresholds extend by 25k steps', () async {
    await XpService.grantBonusXp(85000); // L10=60k; 85k → level 11
    expect(XpService.level(), 11);
    expect(XpService.rankName(), 'Eternal');
  });

  test('AchievementService.getRank matches XpService.rankName', () async {
    await AchievementService.unlock('first_day');
    await AchievementService.unlock('first_monday');
    expect(AchievementService.getRank(), XpService.rankName());
  });

  test('every achievement has a positive effective XP', () {
    for (final a in kAchievements) {
      expect(a.effectiveXp, greaterThan(0),
          reason: '${a.id} has zero XP');
    }
  });
}
