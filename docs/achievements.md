# Achievements & XP System

## Overview

100+ achievements across 8 categories, with an XP/level system and daily quests.

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

## Rarities & XP

| Rarity | XP | Color |
|--------|-----|-------|
| Bronze | 25 | Brown |
| Silver | 75 | Grey |
| Gold | 200 | Gold |
| Platinum | 500 | Purple |
| Secret | 750 | Rainbow |

## XP/Level System (`XpService`)

Thresholds: L1=0, L2=200, L3=600, L4=1500, L5=3500, L6=7000, L7=12000, L8=20000, L9=35000, L10=60000

| Level | Rank Title |
|-------|-----------|
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

## Daily Quests (`QuestService`)

- 3 quests per day, deterministically seeded by date + install ID
- ~20 quest templates (e.g., `open_schedule_tab`, `tap_countdown_5x`, `change_persona`)
- Completion grants XP; some high-tier quests unlock themes/personas
- Reset at local midnight

## Milestone Helpers

`AchievementService` exposes helpers that other services call:

- `onStreakMilestone(int days)` — called by StreakService
- `onThemeUnlocked(String id)` — called by UnlockService
- `onPersonaUnlocked(String id)` — called by PersonaService
- `onStudySessionLogged()` — called by StudyLogService
- `onAchievementCountChanged()` — self-referential (hunter ladder)

## Adding Achievements

1. Add entry to `lib/data/achievements_data.dart` with unique `id`, category, rarity, XP
2. Add unlock trigger in the appropriate service helper
3. Run `test/achievements_data_test.dart` to verify no duplicate IDs
