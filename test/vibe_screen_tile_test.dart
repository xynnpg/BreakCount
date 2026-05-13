import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/screens/vibe_screen.dart';
import 'package:breakcount/services/achievement_service.dart';
import 'package:breakcount/services/persona_service.dart';
import 'package:breakcount/services/storage_service.dart';
import 'package:breakcount/services/streak_service.dart';

/// Layout/alignment tests for the Vibe screen's persona gallery grid.
///
/// These pin down three regressions in `_PersonaTile`:
///   (a) no RenderFlex / layout overflow exceptions on a narrow 360dp phone,
///   (b) selecting a persona must not shift its inner content by 1 px (border
///       width must stay constant — color-swap only),
///   (c) every tile in the gallery has identical rendered content-box size
///       (tagline-driven variance was removed).
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
    StreakService.resetForTests();
    await PersonaService.instance.resetForTests();
    PersonaService.instance.init();
  });

  Widget harness(Widget child) => MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(360, 800)),
          child: Scaffold(body: child),
        ),
      );

  /// Locate a persona-name Text inside the gallery GridView (not the hero
  /// card, which also shows the current persona's name).
  Finder galleryText(String name) => find.descendant(
        of: find.byType(GridView),
        matching: find.text(name),
      );

  testWidgets('vibe screen renders at 360dp without overflow',
      (tester) async {
    await tester.pumpWidget(harness(const VibeScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'selecting a persona does not shift inner content (border width stays constant)',
      (tester) async {
    await tester.pumpWidget(harness(const VibeScreen()));
    await tester.pumpAndSettle();

    // Hype is the default-selected persona. Switching to Chill flips the
    // Chill tile's border from 1 px to 2 px, which shifts its inner content
    // (the emoji/name) by 1 px in the current implementation.
    final chillLabel = galleryText('Chill');
    expect(chillLabel, findsOneWidget);

    final topLeftBefore = tester.getTopLeft(chillLabel);

    await tester.tap(chillLabel);
    await tester.pumpAndSettle();

    final topLeftAfter = tester.getTopLeft(galleryText('Chill'));

    expect(
      topLeftAfter,
      topLeftBefore,
      reason:
          'Selecting a persona must not shift inner content. Toggling the '
          'border from 1 px to 2 px causes a visible 1-px jump.',
    );
  });

  testWidgets(
      'all persona tiles have the same content-box height (no tagline variance)',
      (tester) async {
    await tester.pumpWidget(harness(const VibeScreen()));
    await tester.pumpAndSettle();

    // Compare two tiles with different tagline lengths (Hype's tagline wraps
    // to 2 lines; Chill's is much shorter). With a per-tile tagline, the
    // inner Column's rendered height differs; after removal, both Columns
    // render at identical height.
    final hypeCol = find
        .ancestor(of: galleryText('Hype'), matching: find.byType(Column))
        .first;
    final chillCol = find
        .ancestor(of: galleryText('Chill'), matching: find.byType(Column))
        .first;
    final dramaticCol = find
        .ancestor(of: galleryText('Dramatic'), matching: find.byType(Column))
        .first;

    final hypeSize = tester.getSize(hypeCol);
    final chillSize = tester.getSize(chillCol);
    final dramaticSize = tester.getSize(dramaticCol);

    expect(
      chillSize.height,
      hypeSize.height,
      reason:
          'Chill tile content column must match Hype tile content column '
          'height. Got chill=$chillSize vs hype=$hypeSize.',
    );
    expect(
      dramaticSize.height,
      hypeSize.height,
      reason:
          'Dramatic tile content column must match Hype tile content column '
          'height. Got dramatic=$dramaticSize vs hype=$hypeSize.',
    );
  });
}
