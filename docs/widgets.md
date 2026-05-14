# Home Screen Widgets

## Overview

Four widget sizes (2x1, 2x2, 4x1, 4x2) powered by native Android `AppWidgetProvider` and the `home_widget` Flutter package. Colors follow the active theme and persona tint automatically.

## Architecture

```
Flutter (WidgetService.update())
    |
    | writes key-value pairs
    v
HomeWidget SharedPreferences
    |
    | read by
    v
Android BreakCountWidgetProvider (Kotlin)
    |
    v
RemoteViews → AppWidgetManager.updateAppWidget()
```

## Data Payload

`WidgetService.update()` writes these keys to HomeWidget SharedPreferences:

| Key | Type | Description |
|-----|------|-------------|
| `days_until_break` | int | Days to next break (-1 if none) |
| `next_break_name` | String | Break name |
| `year_progress` | int | 0–100 |
| `days_until_summer` | int | Days to year end |
| `is_on_break` | bool | Currently on break |
| `vibe_emoji` | String | Persona emoji |
| `vibe_copy` | String | Mood-aware one-liner from persona copy |
| `current_class` | String? | Active class name |
| `next_class` | String? | Next class name |
| `theme_bg_hex` | String | Theme background (#RRGGBB) |
| `theme_surface_hex` | String | Card surface color |
| `theme_primary_hex` | String | Primary accent |
| `theme_border_hex` | String | Border color |
| `theme_dark` | bool | Dark mode flag |
| `persona_tint_hex` | String | Persona accent color |

## Theme Application (Kotlin)

`BreakCountWidgetProvider.kt` reads theme colors and applies them:

- `widget_root` background → `theme_surface_hex`
- `tv_days`, `tv_break_label` text → `theme_primary_hex`
- `tv_progress` text → `persona_tint_hex`
- Secondary text → primary at 60% alpha

## Layout Files

- `res/layout/breakcount_widget_2x1.xml` — horizontal pill
- `res/layout/breakcount_widget_2x2.xml` — square card with progress ring
- `res/layout/breakcount_widget_4x1.xml` — wide bar (also used by 4x2)

All layouts have `android:id="@+id/widget_root"` on the root `LinearLayout` for programmatic background coloring.

## Update Triggers

`WidgetService.update()` is called in these situations:

- On app startup (fire-and-forget)
- When the theme changes (`AppThemeController.notifier` listener)
- When the persona changes (`PersonaService.currentNotifier` listener)
- When an achievement unlocks (`AchievementService` unlock listener)
- On background widget interaction (`backgroundWidgetCallback`)
