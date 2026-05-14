# Theme System

## Overview

BreakCount has 17 theme presets. 6 are always available; 11 unlock through daily streak milestones or achievement triggers. Unlocks are permanent — breaking a streak doesn't re-lock themes you've already earned.

## ThemePreset Model

```dart
class ThemePreset {
  final String id;
  final String name;
  final String emoji;
  final bool dark;
  final Color bgDeep;       // Scaffold background
  final Color bgDark;       // Elevated background
  final Color bgSurface;    // Card/surface background
  final Color primary;      // Primary accent
  final Color gradA, gradB; // Decorative gradient
  final Color surfaceBorder;
  final Color? textPrimary; // Override (null = default)
  final double cardOpacity;
}
```

## Default Presets (Always Unlocked)

| ID | Name | Style |
|----|------|-------|
| `coffee` | Coffee | Warm brown on cream |
| `midnight` | Midnight | Dark with indigo accent |
| `mint` | Mint | Fresh green |
| `sakura` | Sakura | Pink blossom |
| `ocean` | Ocean | Blue |
| `sunset` | Sunset | Warm orange |

## Unlockable Presets

| ID | Unlock Condition |
|----|-----------------|
| `lavender` | 7-day streak |
| `forest` | 14-day streak |
| `aurora` | 30-day streak |
| `paper` | 50-day streak |
| `cosmic` | 75-day streak |
| `neon` | 100-day streak |
| `amoled` | 150-day streak |
| `vapor` | 200-day streak |
| `solarized` | 365-day streak |
| `zen` | Achievement: All Four Seasons |
| `mono` | Achievement: Completionist (50 achievements) |

## AppThemeController

Global singleton managing the active theme:

- `AppThemeController.notifier` — `ValueNotifier<ThemePreset>`, the UI listens to this
- `AppThemeController.personaTintNotifier` — persona accent color overlay
- `AppThemeController.init(savedId)` — restores from storage on startup
- `AppThemeController.setTheme(preset)` — switches and persists the new theme

## Permanent Unlock Persistence

Theme unlocks are stored in `unlocked_themes_v1` (a JSON array in SharedPreferences), separately from the current streak. This means:

- Breaking a streak does not re-lock themes you've already earned
- Unlocks survive backup restores — `unlocked_themes_v1` is included in the Google Drive backup payload
- On startup, `UnlockService.init()` calls `_backfillFromLongestStreak()`, which retroactively grants any streak-gated themes the user already earned based on their longest-ever streak, even if they're not yet in the persistent set

`UnlockService.recordThemeUnlock(id)` is called automatically from `main.dart` whenever `StreakService.recordOpen()` resolves with a new milestone streak.

## Widget Integration

When the theme changes, a listener in `main.dart` calls `WidgetService.update()`, which writes hex color strings to HomeWidget SharedPreferences. The Android `BreakCountWidgetProvider` reads these and applies them via `RemoteViews.setInt(...)`.

## Adding a New Theme

1. Add a `static const ThemePreset` in `theme_preset.dart`
2. Add it to the `all` list
3. Add an `UnlockRequirement` entry in `unlock_service.dart`
4. The theme picker and widget system pick it up automatically — no other changes needed
