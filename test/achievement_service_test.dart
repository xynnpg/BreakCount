import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/models/school_year.dart';
import 'package:breakcount/services/achievement_service.dart';
import 'package:breakcount/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Isolate every test — fresh SharedPreferences + fresh in-memory state.
    SharedPreferences.setMockInitialValues({});
    // Silence platform channels the achievement service calls into
    // (local notifications + timezone). Returning null keeps the flow alive.
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

  group('unlock', () {
    test('returns true first time, false when called again', () async {
      expect(await AchievementService.unlock('first_day'), isTrue);
      expect(await AchievementService.unlock('first_day'), isFalse);
      expect(AchievementService.isUnlocked('first_day'), isTrue);
    });
  });

  group('increment', () {
    test('crosses goal exactly once', () async {
      expect(await AchievementService.increment('shake_master', goal: 3),
          isFalse);
      expect(await AchievementService.increment('shake_master', goal: 3),
          isFalse);
      expect(await AchievementService.increment('shake_master', goal: 3),
          isTrue);
      // Subsequent calls should not re-unlock.
      expect(await AchievementService.increment('shake_master', goal: 3),
          isFalse);
      expect(AchievementService.getCount('shake_master'), 4);
    });
  });

  group('onShake', () {
    test('three shakes unlock shake_master', () async {
      await AchievementService.onShake();
      await AchievementService.onShake();
      expect(AchievementService.isUnlocked('shake_master'), isFalse);
      await AchievementService.onShake();
      expect(AchievementService.isUnlocked('shake_master'), isTrue);
    });
  });

  group('onEarlyClass', () {
    test('unlocks early_bird once', () async {
      expect(await AchievementService.onEarlyClass(), isTrue);
      expect(await AchievementService.onEarlyClass(), isFalse);
      expect(AchievementService.isUnlocked('early_bird'), isTrue);
    });
  });

  group('recordDayOpen', () {
    test('deduplicates per calendar day', () async {
      await AchievementService.recordDayOpen();
      final second = await AchievementService.recordDayOpen();
      // Count only bumped once.
      expect(AchievementService.getCount('one_month'), 1);
      // Second call returns empty because we already counted today.
      expect(second, isEmpty);
    });

    test('eventually unlocks one_month after 30 unique days', () async {
      // Force-feed increments directly to simulate 30 distinct days.
      for (var i = 0; i < 30; i++) {
        await AchievementService.increment('one_month', goal: 30);
      }
      expect(AchievementService.isUnlocked('one_month'), isTrue);
    });
  });

  group('onMeet', () {
    test('dedupes by anonId and tracks personas', () async {
      await AchievementService.onMeet(
          anonId: 'abc', peerPersona: 'chill', myPersona: 'hype');
      await AchievementService.onMeet(
          anonId: 'abc', peerPersona: 'chill', myPersona: 'hype');
      expect(AchievementService.metAnonIds, hasLength(1));
      expect(AchievementService.isUnlocked('first_meet'), isTrue);
      // opposite pair (hype ↔ chill) should also unlock.
      expect(AchievementService.isUnlocked('opposites_attract'), isTrue);
    });

    test('mirror unlocks on same persona', () async {
      await AchievementService.onMeet(
          anonId: 'dup', peerPersona: 'dramatic', myPersona: 'dramatic');
      expect(AchievementService.isUnlocked('mirror'), isTrue);
    });

    test('met_the_pack requires all 4 base personas', () async {
      await AchievementService.onMeet(
          anonId: 'h', peerPersona: 'hype', myPersona: 'chill');
      await AchievementService.onMeet(
          anonId: 'c', peerPersona: 'chill', myPersona: 'chill');
      await AchievementService.onMeet(
          anonId: 'd', peerPersona: 'dramatic', myPersona: 'chill');
      expect(AchievementService.isUnlocked('met_the_pack'), isFalse);
      await AchievementService.onMeet(
          anonId: 's', peerPersona: 'sarcastic', myPersona: 'chill');
      expect(AchievementService.isUnlocked('met_the_pack'), isTrue);
    });
  });

  group('onScheduleShared', () {
    test('echo on first, mentor at 3, teacher at 10', () async {
      final n1 = await AchievementService.onScheduleShared();
      expect(n1, contains('echo'));
      for (var i = 0; i < 2; i++) {
        await AchievementService.onScheduleShared();
      }
      expect(AchievementService.isUnlocked('mentor'), isTrue);
      for (var i = 0; i < 7; i++) {
        await AchievementService.onScheduleShared();
      }
      expect(AchievementService.isUnlocked('teacher'), isTrue);
    });
  });

  group('checkSchoolProgress — all_mondays detection', () {
    test('seeds monday_count cleanly', () async {
      final sy = SchoolYear(
        country: 'Romania',
        academicYear: '2025-2026',
        startDate: DateTime(2025, 9, 1),  // a Monday
        endDate: DateTime(2025, 9, 21),   // Sunday
        semesters: const [],
        breaks: const [],
        cachedAt: DateTime.now(),
      );
      // Mondays between Sep 1–Sep 21 inclusive: 1, 8, 15 → 3 Mondays.
      for (var i = 0; i < 3; i++) {
        await AchievementService.increment('monday_count', goal: 9999);
      }
      await AchievementService.checkSchoolProgress(sy);
      // This path only fires unlock when "today is a Monday during school".
      // We verify the counter is preserved through the check — full unlock
      // is covered by integration / manual runs.
      expect(AchievementService.getCount('monday_count'), 3);
    });
  });
}
