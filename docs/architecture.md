# Architecture Overview

## Project Structure

```
lib/
├── app/                    # App-level config
│   ├── constants.dart      # Colors, spacing, StorageKeys
│   ├── routes.dart         # Named route definitions
│   ├── theme.dart          # MaterialApp theme builder
│   ├── theme_preset.dart   # ThemePreset model + AppThemeController
│   └── persona_theme_ext.dart  # BuildContext extension for persona tint
├── screens/                # Full-page UI (tabs, settings, review, etc.)
├── widgets/                # Reusable UI components
├── services/               # Business logic, platform channels, storage
├── data/                   # Static data (achievements, personas, school data)
├── models/                 # Data models (Schedule, Subject, Exam, etc.)
├── utils/                  # Helpers (debug_log)
└── main.dart               # Entry point, initialization, BreakCountApp widget
```

## State Management

BreakCount uses a lightweight approach — no external state management package:

- **`ValueNotifier<T>`** for reactive state (theme, persona tint, streak)
- **`StorageService`** (SharedPreferences wrapper) for persistence
- **`setState()`** in StatefulWidgets for local UI state
- **Listeners** wired in `main.dart` for cross-cutting concerns

## Data Flow

```
User action → Service method → StorageService.save() → ValueNotifier.value = x
                                                              ↓
                                                    Listeners fire
                                                              ↓
                                              Widget rebuilds / side effects
                                              (e.g., WidgetService.update())
```

## Initialization Order (main.dart)

1. `WidgetsFlutterBinding.ensureInitialized()`
2. Firebase init (Core, Crashlytics, Analytics)
3. `StorageService.init()` — loads SharedPreferences
4. `AppThemeController.init()` — restores saved theme
5. `AchievementService.init()` — loads unlock state
6. `StreakService.init()` + `recordOpen()` — daily streak
7. `PersonaService.init()` — restores active persona
8. Cross-cutting listeners wired (achievement→widget, persona→widget, theme→widget, streak→achievement)
9. Notifications, FCM, widget update (fire-and-forget)
10. `runApp(BreakCountApp(...))`

## Key Patterns

- **Fire-and-forget:** Non-critical operations (widget updates, analytics, auto-backup) never block startup
- **Graceful degradation:** Every service wraps platform calls in try/catch; failures are logged, never propagated
- **Additive architecture:** New features (themes, personas, achievements) plug into existing notifier/listener infrastructure without rewrites
