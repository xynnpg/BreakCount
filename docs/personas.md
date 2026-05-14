# Personas

## Overview

30 personas, each with a unique emoji, tint color, and full copy palette. The active persona affects app-wide text, colors, confetti, widgets, and weekly recaps. Switching personas is instant and persists across restarts.

## Persona Model

```dart
class Persona {
  final String id;
  final String name;
  final String emoji;
  final Color tint;          // Accent color override
  final bool isDefault;      // Always unlocked
}
```

Defined in `lib/data/personas_data.dart`.

## Copy System (persona_copy.dart)

Copy is keyed by `(personaId, slot)`. Slots:

- `countdown_far` — 60+ days to break
- `countdown_mid` — 15–60 days
- `countdown_close` — 2–15 days
- `countdown_imminent` — 0–2 days
- `break_reveal` — break just started
- `recap_intro` — weekly recap opener
- `greeting` — app open

Every persona has entries for every slot. The widget service also uses persona copy for the vibe line shown on the home screen widget.

## Base Personas (Always Unlocked)

| ID | Name | Tint |
|----|------|------|
| `hype` | Hype | Orange-red |
| `chill` | Chill | Blue |
| `dramatic` | Dramatic | Purple |
| `sarcastic` | Sarcastic | Teal |

## Unlockable Personas

26 personas require a streak milestone or a specific achievement. Unlock conditions are registered in `UnlockService._personaRequirements`.

| ID | Name | Unlock Condition |
|----|------|-----------------|
| `ghost` | Ghost | Achievement: 50 Mondays |
| `sage` | Sage | Achievement: Old Guard |
| `menace` | Menace | Achievement: Collector (25 achievements) |
| `zen` | Zen | Achievement: Break Collector |
| `nerd` | Nerd | 3-day streak |
| `tired` | Tired | 7-day streak |
| `ice` | Ice | 14-day streak |
| `gremlin` | Gremlin | 21-day streak |
| `philosopher` | Philosopher | 30-day streak |
| `goblin` | Goblin | 42-day streak |
| `cloud` | Cloud | 50-day streak |
| `volcano` | Volcano | 60-day streak |
| `sloth` | Sloth | 75-day streak |
| `storm` | Storm | 90-day streak |
| `sprout` | Sprout | 100-day streak |
| `moon` | Moon | 120-day streak |
| `star` | Star | 150-day streak |
| `phoenix` | Phoenix | 200-day streak |
| `sunflower` | Sunflower | 250-day streak |
| `jester` | Jester | Achievement: Recap Regular |
| `monk` | Monk | Achievement: Completionist (50 achievements) |
| `rebel` | Rebel | Achievement: Mood Rollercoaster |
| `hacker` | Hacker | Achievement: AI Wizard |
| `chef` | Chef | Achievement: Fully Loaded |
| `pirate` | Pirate | Achievement: Networker |
| `robot` | Robot | Achievement: Year-Round |

## Permanent Unlock Persistence

Persona unlocks are stored in `unlocked_personas_v1` (a JSON array in SharedPreferences) independently of the current streak. This means:

- Breaking a streak does not re-lock personas you've already earned
- Unlocks survive backup restores — `unlocked_personas_v1` is included in the Google Drive backup payload
- On startup, `UnlockService.init()` retroactively grants any streak-gated personas the user already earned based on their longest-ever streak

`UnlockService.recordPersonaUnlock(id)` is called automatically from `main.dart` whenever `StreakService.recordOpen()` resolves with a new milestone streak.

## PersonaService

- `PersonaService.instance` — singleton
- `currentNotifier` — `ValueNotifier<Persona>`, drives UI rebuilds across the app
- `setPersona(id)` — switches the active persona, updates the tint notifier, and persists
- `init()` — restores the saved persona from storage on startup

## Persona Tint Integration

`AppThemeController.personaTintNotifier` is updated whenever the persona changes. The `MaterialApp` rebuilds with the new tint via `persona_theme_ext.dart`'s `BuildContext` extension.

## Adding a Persona

1. Add an entry to `lib/data/personas_data.dart`
2. Add copy entries for all slots in `lib/data/persona_copy.dart`
3. Add the unlock condition in `lib/services/unlock_service.dart`
4. Run `test/persona_copy_test.dart` to verify all slots are covered
