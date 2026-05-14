# Architecture

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

## Named Routes

| Route | Screen |
|-------|--------|
| `/welcome` | Onboarding carousel |
| `/country-selection` | Country picker |
| `/profile-selection` | School profile picker |
| `/home` | Main tabbed screen |
| `/add-subject` | Add/edit timetable subject |
| `/reminders` | Reminders list |
| `/add-reminder` | Add/edit reminder |
| `/settings` | Settings screen |
| `/stats` | Stats deep-dive |
| `/achievements` | Achievements gallery |
| `/vibe` | Vibe full-view screen |
| `/nearby-users` | Nearby students screen |
| `/persona-picker` | Persona gallery/picker |
| `/changelog` | In-app changelog viewer |

## State Management

No external state management package. The app uses a lightweight approach that's easy to follow:

- `ValueNotifier<T>` for reactive state (theme, persona tint, streak, study log revision)
- `StorageService` (SharedPreferences wrapper) for persistence
- `setState()` in StatefulWidgets for local UI state
- Listeners wired in `main.dart` for cross-cutting concerns

Key notifiers:

| Notifier | Type | Owner |
|----------|------|-------|
| `AppThemeController.notifier` | `ValueNotifier<ThemePreset>` | `theme_preset.dart` |
| `AppThemeController.personaTintNotifier` | `ValueNotifier<Color>` | `theme_preset.dart` |
| `PersonaService.instance.currentNotifier` | `ValueNotifier<Persona>` | `persona_service.dart` |
| `StreakService.currentNotifier` | `ValueNotifier<int>` | `streak_service.dart` |
| `StreakService.longestNotifier` | `ValueNotifier<int>` | `streak_service.dart` |
| `StudyLogService.revision` | `ValueNotifier<int>` | `study_log_service.dart` |

## Data Flow

```
User action → Service method → StorageService.save() → ValueNotifier.value = x
                                                              |
                                                    Listeners fire
                                                              |
                                              Widget rebuilds / side effects
                                              (e.g., WidgetService.update())
```

## Initialization Order (main.dart)

1. `WidgetsFlutterBinding.ensureInitialized()`
2. Firebase init (Core, Crashlytics, Analytics)
3. `StorageService.init()` — loads SharedPreferences
4. `AppThemeController.init()` — restores saved theme
5. `AchievementService.init()` — loads unlock state
6. `StreakService.init()` + `recordOpen()` — daily streak check-in
7. `UnlockService.init()` — loads persisted theme/persona unlocks, backfills from longest streak
8. `PersonaService.init()` — restores active persona
9. Cross-cutting listeners wired (achievement→widget, persona→widget, theme→widget, streak→achievement, streak→unlock)
10. Notifications, FCM, widget update (fire-and-forget)
11. `runApp(BreakCountApp(...))`

## Key Patterns

**Fire-and-forget:** Non-critical operations like widget updates, analytics, and auto-backup never block startup. They run in the background and failures are swallowed silently.

**Graceful degradation:** Every service wraps platform calls in try/catch. Failures are logged to Crashlytics but never propagated to the UI. The app keeps working even if a service fails.

**Additive architecture:** New features (themes, personas, achievements) plug into the existing notifier/listener infrastructure without requiring rewrites. Adding a new theme is 3 lines of code.

**Permanent unlock persistence:** `UnlockService` stores earned unlocks independently of the current streak, so they survive streak resets and backup restores. On init, it backfills any unlocks the user earned but that aren't yet in the persistent set.
