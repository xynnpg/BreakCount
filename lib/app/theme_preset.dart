import 'package:flutter/material.dart';
import 'constants.dart';

/// Single fixed light theme preset. The multi-theme system has been removed.
class ThemePreset {
  final String id;
  final String name;

  // These fields remain so downstream code that reads them doesn't break.
  // They now point at the light-theme palette.
  final Color bgDeep;
  final Color bgDark;
  final Color bgSurface;
  final Color primary;
  final Color gradA;
  final Color gradB;
  final double cardOpacity;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.bgDeep,
    required this.bgDark,
    required this.bgSurface,
    required this.primary,
    required this.gradA,
    required this.gradB,
    this.cardOpacity = 1.0,
  });

  // The single light preset
  static const ThemePreset light = ThemePreset(
    id: 'light',
    name: 'Light',
    bgDeep: AppColors.scaffoldBg,
    bgDark: AppColors.surface,
    bgSurface: Color(0xFFFDF6F0),
    primary: AppColors.primary,
    gradA: AppColors.scaffoldBg,
    gradB: AppColors.scaffoldBg,
  );

  /// Always returns the single light preset.
  static List<ThemePreset> get all => const [light];

  static ThemePreset fromId(String id) => light;
}

// ── Global theme controller ────────────────────────────────────────────────

/// Static singleton — always returns the single light preset.
class AppThemeController {
  AppThemeController._();

  static final ValueNotifier<ThemePreset> notifier =
      ValueNotifier<ThemePreset>(ThemePreset.light);

  static ThemePreset get current => ThemePreset.light;

  static void init(String? savedId) {
    // No-op: single theme, nothing to restore.
  }

  static void setTheme(ThemePreset preset) {
    // No-op: single theme.
  }
}
