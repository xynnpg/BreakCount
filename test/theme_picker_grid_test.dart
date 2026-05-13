import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/app/theme_preset.dart';
import 'package:breakcount/services/achievement_service.dart';
import 'package:breakcount/services/storage_service.dart';
import 'package:breakcount/services/streak_service.dart';
import 'package:breakcount/widgets/theme_picker_grid.dart';

/// Layout/alignment tests for the Settings → Appearance → Theme grid.
///
/// These pin down two concrete regressions in `_ThemeSwatch`:
///   (a) no RenderFlex / layout overflow exceptions on a narrow 360dp phone,
///   (b) picking a theme must not change the inner content position — the
///       border width must stay constant so text/dot do not reflow by 1 px.
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
    await AchievementService.resetForTests();
    AchievementService.init();
    StreakService.resetForTests();
    AppThemeController.resetForTests();
  });

  Widget harness(Widget child) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 640,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      );

  testWidgets('theme swatch grid renders at 360dp without overflow',
      (tester) async {
    await tester.pumpWidget(harness(const ThemePickerGrid()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'selecting a theme does not shift inner content (border width stays constant)',
      (tester) async {
    await tester.pumpWidget(harness(const ThemePickerGrid()));
    await tester.pumpAndSettle();

    // Coffee is the default-selected preset. Midnight starts unselected with
    // a 1-px border — selecting it switches the border to 2 px, which shifts
    // inner content (the label Text) up/left by 1 px in the current
    // implementation. The fix: always use width 2, only change the color.
    final midnightLabel = find.text('🌙 Midnight');
    expect(midnightLabel, findsOneWidget);

    final topLeftBefore = tester.getTopLeft(midnightLabel);

    await tester.tap(midnightLabel);
    await tester.pumpAndSettle();

    final topLeftAfter = tester.getTopLeft(midnightLabel);

    expect(
      topLeftAfter,
      topLeftBefore,
      reason:
          'Selecting a theme must not shift inner content. Toggling the '
          'border from 1 px to 2 px causes a visible 1-px jump.',
    );
  });

  testWidgets('theme swatch name text is centered + ellipsized',
      (tester) async {
    await tester.pumpWidget(harness(const ThemePickerGrid()));
    await tester.pumpAndSettle();

    final vaporText = find.text('🌆 Vaporwave');
    expect(vaporText, findsOneWidget);

    final textWidget = tester.widget<Text>(vaporText);
    expect(textWidget.textAlign, TextAlign.center);
    expect(textWidget.overflow, TextOverflow.ellipsis);
    expect(textWidget.maxLines, 1);
  });
}
