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

## Unlockable Personas (26 more)

Unlock conditions are registered in `UnlockService`. Mix of streak milestones and achievement triggers.

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
