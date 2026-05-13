import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/services/achievement_service.dart';
import 'package:breakcount/services/quest_service.dart';
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
    await QuestService.resetForTests();
  });

  group('today', () {
    test('returns 3 quests', () async {
      final quests = await QuestService.today(now: DateTime(2026, 5, 12));
      expect(quests, hasLength(3));
    });

    test('same date returns the same 3 ids (deterministic)', () async {
      final a = await QuestService.today(now: DateTime(2026, 5, 12));
      final b = await QuestService.today(now: DateTime(2026, 5, 12, 23, 59));
      expect(a.map((q) => q.id).toList(), b.map((q) => q.id).toList());
    });

    test('different dates produce different triplets', () async {
      final a = await QuestService.today(now: DateTime(2026, 5, 12));
      await QuestService.resetForTests();
      final b = await QuestService.today(now: DateTime(2026, 5, 13));
      expect(a.map((q) => q.id).toSet(), isNot(equals(b.map((q) => q.id).toSet())));
    });
  });

  group('progress', () {
    test('progress on an active quest persists', () async {
      final quests = await QuestService.today(now: DateTime(2026, 5, 12));
      final first = quests.first;
      final completed =
          await QuestService.progress(first.id, now: DateTime(2026, 5, 12));
      // For single-step goals the first call completes.
      if (first.template.goal == 1) {
        expect(completed, isTrue);
      } else {
        expect(completed, isFalse);
      }
      // Fetch again — progress should persist.
      final refreshed = await QuestService.today(now: DateTime(2026, 5, 12));
      final refreshedFirst =
          refreshed.firstWhere((q) => q.id == first.id);
      expect(refreshedFirst.progress, greaterThanOrEqualTo(1));
    });

    test('progress on an unknown quest is a noop', () async {
      final r = await QuestService.progress('q_nonexistent');
      expect(r, isFalse);
    });

    test('completing a quest grants bonus XP', () async {
      await QuestService.today(now: DateTime(2026, 5, 12));
      final before = XpService.totalXp();
      final quests = await QuestService.today(now: DateTime(2026, 5, 12));
      final goal1 =
          quests.firstWhere((q) => q.template.goal == 1);
      await QuestService.progress(goal1.id, now: DateTime(2026, 5, 12));
      final after = XpService.totalXp();
      expect(after, greaterThan(before));
    });
  });

  group('rollover', () {
    test('new calendar day resets progress + may pick different ids', () async {
      await QuestService.today(now: DateTime(2026, 5, 12));
      final ids1 = (await QuestService.today(now: DateTime(2026, 5, 12)))
          .map((q) => q.id)
          .toList();
      // Complete all we can today.
      for (final id in ids1) {
        await QuestService.progress(id, now: DateTime(2026, 5, 12));
      }
      // Next day.
      final tomorrow = await QuestService.today(now: DateTime(2026, 5, 13));
      expect(tomorrow.every((q) => q.progress == 0), isTrue);
    });
  });
}
