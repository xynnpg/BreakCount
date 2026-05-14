# Achievements and XP System

## Overview

100+ achievements across 8 categories, with an XP/level system and daily quests. For the full achievement list with unlock conditions, see [ACHIEVEMENTS.md](../ACHIEVEMENTS.md).

## Achievement Model

```dart
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int xp;              // XP granted on unlock
  final bool secret;         // Hidden until unlocked
}
```

## Categories

`schoolProgress`, `mondayClub`, `examsSchedule`, `breakMilestones`, `powerUser`, `streaks`, `themes`, `personas`

## Rarities and XP

| Rarity | XP | Color |
|--------|-----|-------|
| Bronze | 25 | Brown |
| Silver | 75 | Grey |
| Gold | 200 | Gold |
| Platinum | 500 | Purple |
| Secret | 750 | Rainbow |

## XP and Level System (XpService)

Thresholds: L1=0, L2=200, L3=600, L4=1500, L5=3500, L6=7000, L7=12000, L8=20000, L9=35000, L10=60000

| Level | Rank |
|-------|------|
| 1 | Newcomer |
| 2 | Rookie |
| 3 | Survivor |
| 4 | Veteran |
| 5 | Master |
| 6 | Legend |
| 7 | Mythic |
| 8 | Ascendant |
| 9 | Transcendent |
| 10+ | Eternal |

## Daily Quests (QuestService)

- 3 quests per day, deterministically seeded by date + install ID (so everyone gets the same quests on the same day)
- Around 20 quest templates (e.g., `open_schedule_tab`, `tap_countdown_5x`, `change_persona`)
- Completing a quest grants XP; some high-tier quests also unlock themes or personas
- Reset at local midnight

## Milestone Helpers

`AchievementService` exposes helpers that other services call when something happens:

- `onStreakMilestone(int days)` — called by StreakService on each new streak day
- `onThemeUnlocked(String id)` — called by UnlockService when a theme unlocks
- `onPersonaUnlocked(String id)` — called by PersonaService when a persona unlocks
- `onStudySessionLogged({totalSessions, sessionMinutes, weeklyMinutesAfterThis, totalMinutesEver, sessionsForCurrentSubject})` — called by StudyLogService after each logged session; drives the study achievement ladders
- `onNotificationToggled(String kind)` — called by SettingsScreen when the user enables notifications (`kind`: `'general'` or `'break'`)
- `onWidgetTapped()` — called by `backgroundWidgetCallback` when the user taps the home screen widget
- `onAchievementCountChanged()` — self-referential; called by the unlock listener in `main.dart` to advance the hunter ladder

## Adding Achievements

1. Add an entry to `lib/data/achievements_data.dart` with a unique `id`, category, rarity, and XP value
2. Add the unlock trigger in the appropriate service helper above
3. Run `test/achievements_data_test.dart` to verify there are no duplicate IDs
