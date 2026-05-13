import 'package:flutter/material.dart';

import 'constants.dart';
import 'theme_style.dart';
import '../services/storage_service.dart';

/// A full theme palette. The app's active colors (`AppColors.*`) are the
/// "Coffee" preset's values — additional presets override specific tokens at
/// MaterialApp.theme build time via [AppTheme.build] + [ThemePreset].
@immutable
class ThemePreset {
  final String id;
  final String name;
  final String emoji;

  /// True for dark-mode themes. Affects status-bar icon colors and a few
  /// on-surface defaults in AppTheme.build.
  final bool dark;

  // Canvas / scaffold background
  final Color bgDeep;

  /// Alternate (slightly elevated) background. Rarely used directly — kept for
  /// legacy call sites that referenced it.
  final Color bgDark;

  /// Surface / card background (equivalent to AppColors.surface in light mode).
  final Color bgSurface;

  /// Primary accent color (used when the active persona tint hasn't overridden
  /// it and for static primary-colored UI like the coffee icon on the About
  /// card).
  final Color primary;

  /// Gradient colors — used by widgets that draw decorative backgrounds.
  final Color gradA;
  final Color gradB;

  /// Border color for cards and divider lines.
  final Color surfaceBorder;

  /// Primary text color override. When [null] AppColors.textPrimary is used.
  final Color? textPrimary;

  /// Opacity used by glassmorphic cards.
  final double cardOpacity;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.emoji,
    required this.bgDeep,
    required this.bgDark,
    required this.bgSurface,
    required this.primary,
    required this.gradA,
    required this.gradB,
    required this.surfaceBorder,
    this.textPrimary,
    this.dark = false,
    this.cardOpacity = 1.0,
  });

  ThemeStyle get style {
    switch (id) {
      case 'neon':
        return ThemeStyle.neon;
      case 'amoled':
        return ThemeStyle.amoled;
      case 'zen':
      case 'mono':
        return ThemeStyle.clean;
      case 'midnight':
        return ThemeStyle.dark;
      case 'forest':
      case 'aurora':
        return ThemeStyle.nature;
      case 'cosmic':
      case 'vapor':
        return ThemeStyle.cosmic;
      case 'mint':
      case 'sakura':
      case 'ocean':
      case 'sunset':
      case 'lavender':
        return ThemeStyle.pastel;
      default:
        return ThemeStyle.warm;
    }
  }

  // ── Default presets (always unlocked) ────────────────────────────────────

  /// Warm coffee — the current default palette.
  static const ThemePreset coffee = ThemePreset(
    id: 'coffee',
    name: 'Coffee',
    emoji: '☕',
    bgDeep: Color(0xFFFDFAF7),
    bgDark: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFFDF6F0),
    primary: Color(0xFF6F4E37),
    gradA: Color(0xFFFDFAF7),
    gradB: Color(0xFFFDFAF7),
    surfaceBorder: Color(0xFFE8D5C4),
  );

  /// True dark theme with a soft indigo accent.
  static const ThemePreset midnight = ThemePreset(
    id: 'midnight',
    name: 'Midnight',
    emoji: '🌙',
    bgDeep: Color(0xFF0F1420),
    bgDark: Color(0xFF1A1F2E),
    bgSurface: Color(0xFF1A1F2E),
    primary: Color(0xFF7C8EF0),
    gradA: Color(0xFF0F1420),
    gradB: Color(0xFF1A1F2E),
    surfaceBorder: Color(0xFF2A3040),
    textPrimary: Color(0xFFEDEFF5),
    dark: true,
  );

  /// Fresh mint green.
  static const ThemePreset mint = ThemePreset(
    id: 'mint',
    name: 'Mint',
    emoji: '🌿',
    bgDeep: Color(0xFFF0FBF4),
    bgDark: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFE8F5EB),
    primary: Color(0xFF2E9A69),
    gradA: Color(0xFFF0FBF4),
    gradB: Color(0xFFE8F5EB),
    surfaceBorder: Color(0xFFC1ECD4),
  );

  /// Pink sakura.
  static const ThemePreset sakura = ThemePreset(
    id: 'sakura',
    name: 'Sakura',
    emoji: '🌸',
    bgDeep: Color(0xFFFFF4F7),
    bgDark: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFFFEBF0),
    primary: Color(0xFFD46A90),
    gradA: Color(0xFFFFF4F7),
    gradB: Color(0xFFFFEBF0),
    surfaceBorder: Color(0xFFE8A3B8),
  );

  /// Ocean blue.
  static const ThemePreset ocean = ThemePreset(
    id: 'ocean',
    name: 'Ocean',
    emoji: '🌊',
    bgDeep: Color(0xFFEEF6FB),
    bgDark: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFDEECF5),
    primary: Color(0xFF2F7FB8),
    gradA: Color(0xFFEEF6FB),
    gradB: Color(0xFFDEECF5),
    surfaceBorder: Color(0xFFB6D5E8),
  );

  /// Warm sunset.
  static const ThemePreset sunset = ThemePreset(
    id: 'sunset',
    name: 'Sunset',
    emoji: '🌇',
    bgDeep: Color(0xFFFFF6EE),
    bgDark: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFFEEAD7),
    primary: Color(0xFFE07B3A),
    gradA: Color(0xFFFFF6EE),
    gradB: Color(0xFFFEEAD7),
    surfaceBorder: Color(0xFFF4C69E),
  );

  // ── Unlockable presets ───────────────────────────────────────────────────

  static const ThemePreset lavender = ThemePreset(
    id: 'lavender',
    name: 'Lavender',
    emoji: '💜',
    bgDeep: Color(0xFFF7F3FF),
    bgDark: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFEEE6FF),
    primary: Color(0xFF7C5CD1),
    gradA: Color(0xFFF7F3FF),
    gradB: Color(0xFFEEE6FF),
    surfaceBorder: Color(0xFFD6C6F2),
  );

  static const ThemePreset forest = ThemePreset(
    id: 'forest',
    name: 'Forest',
    emoji: '🌲',
    bgDeep: Color(0xFF1B2620),
    bgDark: Color(0xFF243430),
    bgSurface: Color(0xFF243430),
    primary: Color(0xFF5FBF8E),
    gradA: Color(0xFF1B2620),
    gradB: Color(0xFF243430),
    surfaceBorder: Color(0xFF2E443D),
    textPrimary: Color(0xFFE4F0E8),
    dark: true,
  );

  static const ThemePreset aurora = ThemePreset(
    id: 'aurora',
    name: 'Aurora',
    emoji: '🌌',
    bgDeep: Color(0xFF0E1A2A),
    bgDark: Color(0xFF172438),
    bgSurface: Color(0xFF172438),
    primary: Color(0xFF56D3B5),
    gradA: Color(0xFF0E1A2A),
    gradB: Color(0xFF2A1E3A),
    surfaceBorder: Color(0xFF283346),
    textPrimary: Color(0xFFE3F1F3),
    dark: true,
  );

  static const ThemePreset cosmic = ThemePreset(
    id: 'cosmic',
    name: 'Cosmic',
    emoji: '🪐',
    bgDeep: Color(0xFF14102A),
    bgDark: Color(0xFF201842),
    bgSurface: Color(0xFF201842),
    primary: Color(0xFFB388FF),
    gradA: Color(0xFF14102A),
    gradB: Color(0xFF2A1E4A),
    surfaceBorder: Color(0xFF2C2452),
    textPrimary: Color(0xFFE9E4FF),
    dark: true,
  );

  static const ThemePreset amoled = ThemePreset(
    id: 'amoled',
    name: 'AMOLED',
    emoji: '⚫',
    bgDeep: Color(0xFF000000),
    bgDark: Color(0xFF0A0A0A),
    bgSurface: Color(0xFF0A0A0A),
    primary: Color(0xFFFFFFFF),
    gradA: Color(0xFF000000),
    gradB: Color(0xFF000000),
    surfaceBorder: Color(0xFF1F1F1F),
    textPrimary: Color(0xFFEDEDED),
    dark: true,
  );

  static const ThemePreset zen = ThemePreset(
    id: 'zen',
    name: 'Zen',
    emoji: '🧘',
    bgDeep: Color(0xFFF6F2E8),
    bgDark: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFEFE9D9),
    primary: Color(0xFF7A6B4E),
    gradA: Color(0xFFF6F2E8),
    gradB: Color(0xFFEFE9D9),
    surfaceBorder: Color(0xFFD8CFBA),
  );

  static const ThemePreset mono = ThemePreset(
    id: 'mono',
    name: 'Mono',
    emoji: '◻️',
    bgDeep: Color(0xFFFAFAFA),
    bgDark: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFF2F2F2),
    primary: Color(0xFF111111),
    gradA: Color(0xFFFAFAFA),
    gradB: Color(0xFFF2F2F2),
    surfaceBorder: Color(0xFFDCDCDC),
  );

  static const ThemePreset neon = ThemePreset(
    id: 'neon',
    name: 'Neon',
    emoji: '💚',
    bgDeep: Color(0xFF0A0E14),
    bgDark: Color(0xFF11161F),
    bgSurface: Color(0xFF11161F),
    primary: Color(0xFF32FFAB),
    gradA: Color(0xFF0A0E14),
    gradB: Color(0xFF11161F),
    surfaceBorder: Color(0xFF1F2633),
    textPrimary: Color(0xFFDEF6E6),
    dark: true,
  );

  static const ThemePreset paper = ThemePreset(
    id: 'paper',
    name: 'Paper',
    emoji: '📜',
    bgDeep: Color(0xFFFBF8F1),
    bgDark: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFF5EFE2),
    primary: Color(0xFF5C4A35),
    gradA: Color(0xFFFBF8F1),
    gradB: Color(0xFFF5EFE2),
    surfaceBorder: Color(0xFFE4D9C0),
  );

  static const ThemePreset vapor = ThemePreset(
    id: 'vapor',
    name: 'Vaporwave',
    emoji: '🌆',
    bgDeep: Color(0xFF1A1030),
    bgDark: Color(0xFF261A47),
    bgSurface: Color(0xFF261A47),
    primary: Color(0xFFFF77C6),
    gradA: Color(0xFF1A1030),
    gradB: Color(0xFF4A1F52),
    surfaceBorder: Color(0xFF3B2763),
    textPrimary: Color(0xFFFAE3FF),
    dark: true,
  );

  static const ThemePreset solarized = ThemePreset(
    id: 'solarized',
    name: 'Solarized',
    emoji: '☀️',
    bgDeep: Color(0xFFFDF6E3),
    bgDark: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFEEE8D5),
    primary: Color(0xFFCB4B16),
    gradA: Color(0xFFFDF6E3),
    gradB: Color(0xFFEEE8D5),
    surfaceBorder: Color(0xFFD6CFB2),
  );

  // ── Registry ──────────────────────────────────────────────────────────────

  /// All presets, ordered for display. Default presets first, unlockables
  /// after.
  static const List<ThemePreset> all = [
    coffee,
    midnight,
    mint,
    sakura,
    ocean,
    sunset,
    lavender,
    forest,
    aurora,
    cosmic,
    amoled,
    zen,
    mono,
    neon,
    paper,
    vapor,
    solarized,
  ];

  /// Default-unlocked preset ids (free at install time).
  static const Set<String> defaultUnlockedIds = {
    'coffee',
    'midnight',
    'mint',
    'sakura',
    'ocean',
    'sunset',
  };

  /// Alias kept for backward compatibility — pointed to the single preset
  /// when multi-theme was disabled.
  static const ThemePreset light = coffee;

  /// Lookup by id. Falls back to [coffee] on unknown ids.
  static ThemePreset fromId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return coffee;
  }
}

// ── Global theme controller ─────────────────────────────────────────────────

/// Owns the active [ThemePreset] + persona tint. UI listens to [notifier]
/// and [personaTintNotifier] to rebuild on change.
class AppThemeController {
  AppThemeController._();

  static final ValueNotifier<ThemePreset> notifier =
      ValueNotifier<ThemePreset>(ThemePreset.coffee);

  /// Current persona tint — wired up by PersonaService after init.
  static final ValueNotifier<Color> personaTintNotifier =
      ValueNotifier<Color>(AppColors.primary);

  static ThemePreset get current => notifier.value;

  static Color get personaTint => personaTintNotifier.value;

  /// Restores the user's last-selected theme (falls back to coffee).
  static void init(String? savedId) {
    if (savedId == null) {
      notifier.value = ThemePreset.coffee;
      return;
    }
    notifier.value = ThemePreset.fromId(savedId);
  }

  /// Switches the active theme and persists the selection. No-op if already
  /// active.
  static Future<void> setTheme(ThemePreset preset) async {
    if (notifier.value.id == preset.id) return;
    notifier.value = preset;
    await StorageService.saveString(StorageKeys.themeId, preset.id);
  }

  /// Convenience overload — looks up by id.
  static Future<void> setThemeId(String id) => setTheme(ThemePreset.fromId(id));

  /// Called by PersonaService whenever the current persona changes.
  static void setPersonaTint(Color tint) {
    if (personaTintNotifier.value != tint) {
      personaTintNotifier.value = tint;
    }
  }

  /// Test-only reset.
  @visibleForTesting
  static void resetForTests() {
    notifier.value = ThemePreset.coffee;
    personaTintNotifier.value = AppColors.primary;
  }
}
