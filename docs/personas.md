# Personas

## Overview

30 personas, each with a unique emoji, tint color, and full copy palette. The active persona affects app-wide text, colors, confetti, widgets, and weekly recaps.

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

## Copy System (`persona_copy.dart`)

Copy is keyed by `(personaId, slot)`. Slots include:

- `countdown_far` (60+ days)
- `countdown_mid` (15–60 days)
- `countdown_close` (2–15 days)
- `countdown_imminent` (0–2 days)
- `break_reveal` (break just started)
- `recap_intro` (weekly recap opener)
- `greeting` (app open)

Each persona has entries for every slot. The widget service also uses persona copy for the vibe line.

## Base Personas (Always Unlocked)

| ID | Name | Emoji | Tint |
|----|------|-------|------|
| `hype` | Hype | 🔥 | Orange-red |
| `chill` | Chill | 😎 | Blue |
| `dramatic` | Dramatic | 🎭 | Purple |
| `sarcastic` | Sarcastic | 🙃 | Teal |

## Unlockable Personas

26 personas require a streak milestone or a specific achievement. Unlock conditions are registered in `UnlockService._personaRequirements`.

| ID | Name | Emoji | Unlock Condition |
|----|------|-------|-----------------|
| `ghost` | Ghost | 👻 | Achievement: `50_mondays` |
| `sage` | Sage | 🧙 | Achievement: `old_guard` |
| `menace` | Menace | 😈 | Achievement: `achievement_hunter_25` |
| `zen` | Zen | 🧘 | Achievement: `break_collector` |
| `nerd` | Nerd | 🤓 | 3-day streak |
| `tired` | Tired | 🥱 | 7-day streak |
| `ice` | Ice | 🧊 | 14-day streak |
| `gremlin` | Gremlin | 😈 | 21-day streak |
| `philosopher` | Philosopher | 🧐 | 30-day streak |
| `goblin` | Goblin | 👺 | 42-day streak |
| `cloud` | Cloud | ☁️ | 50-day streak |
| `volcano` | Volcano | 🌋 | 60-day streak |
| `sloth` | Sloth | 🦥 | 75-day streak |
| `storm` | Storm | ⛈️ | 90-day streak |
| `sprout` | Sprout | 🌱 | 100-day streak |
| `moon` | Moon | 🌙 | 120-day streak |
| `star` | Star | ⭐ | 150-day streak |
| `phoenix` | Phoenix | 🦅 | 200-day streak |
| `sunflower` | Sunflower | 🌻 | 250-day streak |
| `jester` | Jester | 🃏 | Achievement: `recap_regular` |
| `monk` | Monk | ☸️ | Achievement: `achievement_hunter_50` |
| `rebel` | Rebel | 🤘 | Achievement: `mood_rollercoaster` |
| `hacker` | Hacker | 💻 | Achievement: `ai_wizard` |
| `chef` | Chef | 👨‍🍳 | Achievement: `fully_loaded` |
| `pirate` | Pirate | 🏴‍☠️ | Achievement: `networker` |
| `robot` | Robot | 🤖 | Achievement: `year_legend` |

## Permanent Unlock Persistence

Persona unlocks are stored in `unlocked_personas_v1` (a JSON array in SharedPreferences) independently of the current streak. This means:

- **Unlocks survive streak resets** — breaking a streak does not re-lock earned personas
- **Unlocks survive backup restores** — `unlocked_personas_v1` is included in the Google Drive backup payload
- **Backfill on init** — `UnlockService.init()` retroactively grants any streak-gated personas the user already earned (based on `StreakService.longestStreak`) but that aren't yet in the persistent set

`UnlockService.recordPersonaUnlock(id)` is called automatically from `main.dart` whenever `StreakService.recordOpen()` resolves with a new milestone streak.

## PersonaService

- `PersonaService.instance` — singleton
- `currentNotifier` — `ValueNotifier<Persona>`, drives UI rebuilds
- `setPersona(id)` — switches active persona, updates tint notifier, persists
- `init()` — restores from storage

## Persona Tint Integration

`AppThemeController.personaTintNotifier` is updated whenever the persona changes. The `MaterialApp` rebuilds with the new tint via `persona_theme_ext.dart`'s `BuildContext` extension.

## Adding a Persona

1. Add entry to `lib/data/personas_data.dart`
2. Add copy entries for all slots in `lib/data/persona_copy.dart`
3. Add unlock condition in `lib/services/unlock_service.dart`
4. Run `test/persona_copy_test.dart` to verify all slots are covered
