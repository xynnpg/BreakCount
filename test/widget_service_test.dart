import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/app/theme_preset.dart';
import 'package:breakcount/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  group('Widget theme payload keys', () {
    test('ThemePreset.midnight has expected color values for widget', () {
      final preset = ThemePreset.midnight;
      expect(preset.bgSurface.toARGB32(), 0xFF1A1F2E);
      expect(preset.primary.toARGB32(), 0xFF7C8EF0);
      expect(preset.dark, true);
    });

    test('ThemePreset.fromId resolves all default presets', () {
      for (final id in ['coffee', 'midnight', 'mint', 'sakura', 'ocean', 'sunset']) {
        final preset = ThemePreset.fromId(id);
        expect(preset.id, id);
      }
    });

    test('hex conversion matches widget_service format', () {
      final preset = ThemePreset.midnight;
      String toHex(dynamic c) =>
          '#${(c.toARGB32() as int).toRadixString(16).padLeft(8, '0').substring(2)}';
      expect(toHex(preset.bgSurface), '#1a1f2e');
      expect(toHex(preset.primary), '#7c8ef0');
    });
  });
}
