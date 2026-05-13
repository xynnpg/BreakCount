import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/app/constants.dart';
import 'package:breakcount/data/personas_data.dart';
import 'package:breakcount/services/achievement_service.dart';
import 'package:breakcount/services/persona_service.dart';
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
    await PersonaService.instance.resetForTests();
    PersonaService.instance.init();
  });

  group('PersonaService', () {
    test('base 4 personas unlocked on fresh install', () {
      final ids = PersonaService.instance.unlockedPersonas
          .map((p) => p.id)
          .toSet();
      expect(ids, containsAll(['hype', 'chill', 'dramatic', 'sarcastic']));
      expect(ids.length, 4);
    });

    test('setPersona refuses locked personas', () async {
      final ok = await PersonaService.instance.setPersona('ghost');
      expect(ok, isFalse);
      expect(PersonaService.instance.current.id, 'hype');
    });

    test('setPersona persists + updates notifier for unlocked ids', () async {
      final ok = await PersonaService.instance.setPersona('dramatic');
      expect(ok, isTrue);
      expect(PersonaService.instance.current.id, 'dramatic');
      expect(StorageService.getString(StorageKeys.widgetPersona), 'dramatic');
    });

    test('unlocking 50_mondays makes ghost available', () async {
      await AchievementService.unlock('50_mondays');
      final ids = PersonaService.instance.unlockedPersonas
          .map((p) => p.id)
          .toSet();
      expect(ids, contains('ghost'));
    });

    test('menace requires 25 total unlocks', () async {
      // With zero unlocks, menace is locked.
      expect(PersonaService.instance.isUnlocked('menace'), isFalse);
      // Force-unlock 25 distinct achievements.
      for (var i = 0; i < 25; i++) {
        await AchievementService.unlock('test_ach_$i');
      }
      expect(PersonaService.instance.isUnlocked('menace'), isTrue);
    });

    test('checkUnlocks returns newly-unlocked ids once', () async {
      await AchievementService.unlock('50_mondays');
      final first = await PersonaService.instance.checkUnlocks();
      expect(first, contains('ghost'));
      final second = await PersonaService.instance.checkUnlocks();
      expect(second, isEmpty);
    });

    test('persona lookup is total — returns hype for unknown ids', () {
      final p = personaById('does-not-exist');
      expect(p.id, 'hype');
    });
  });
}
