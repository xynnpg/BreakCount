import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/theme_preset.dart';

/// Widget-level access to the currently active persona tint.
///
/// Prefer `context.personaTint` over hard-coded `AppColors.primary` in places
/// that should track the active persona (progress rings, radar sweeps, nav
/// indicators, active chips, confetti).
///
/// `Theme.of(context).colorScheme.primary` now resolves to the same value —
/// this extension is just a shorter alias for expressive widget code.
extension PersonaThemeExt on BuildContext {
  Color get personaTint => AppThemeController.personaTint;

  /// Listen-style access when you need to rebuild on tint changes without
  /// wrapping manually in a ValueListenableBuilder. Returns the live notifier.
  ValueListenable<Color> get personaTintListenable =>
      AppThemeController.personaTintNotifier;
}
