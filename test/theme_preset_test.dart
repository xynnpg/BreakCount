import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/app/constants.dart';
import 'package:breakcount/app/theme_preset.dart';
import 'package:breakcount/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.breakcount.app/timezone'),
      (call) async => 'UTC',
    );
    await StorageService.init();
    AppThemeController.resetForTests();
  });

  group('ThemePreset registry', () {
    test('all presets have unique ids', () {
      final ids = ThemePreset.all.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('default unlocks match expected six', () {
      expect(
        ThemePreset.defaultUnlockedIds,
        {'coffee', 'midnight', 'mint', 'sakura', 'ocean', 'sunset'},
      );
    });

    test('fromId falls back to coffee on unknown', () {
      expect(ThemePreset.fromId('nope').id, 'coffee');
      expect(ThemePreset.fromId('midnight').id, 'midnight');
    });
  });

  group('AppThemeController', () {
    test('init restores saved theme id', () {
      AppThemeController.init('mint');
      expect(AppThemeController.current.id, 'mint');
    });

    test('init with null uses coffee default', () {
      AppThemeController.init(null);
      expect(AppThemeController.current.id, 'coffee');
    });

    test('setTheme updates notifier + persists', () async {
      await AppThemeController.setTheme(ThemePreset.sakura);
      expect(AppThemeController.current.id, 'sakura');
      expect(
        StorageService.getString(StorageKeys.themeId),
        'sakura',
      );
    });

    test('setTheme no-ops when same theme', () async {
      await AppThemeController.setTheme(ThemePreset.ocean);
      var fired = 0;
      listener() => fired++;
      AppThemeController.notifier.addListener(listener);
      await AppThemeController.setTheme(ThemePreset.ocean);
      expect(fired, 0);
      AppThemeController.notifier.removeListener(listener);
    });
  });
}
