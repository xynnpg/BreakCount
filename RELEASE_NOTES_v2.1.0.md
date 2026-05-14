# BreakCount v2.1.0 — Release Notes

**Release date:** 2026-05-12
**Version code:** 5
**Track:** Production (graduating from Early Access)

---

## What's New (Play Store short — 500 chars)

BreakCount levels up. 17 themes (6 free, 11 unlock with daily streaks), 30 unique personas with custom copy throughout the app, 100+ achievements with XP levels and daily quests, real stats charts, offline timetable OCR, lock-screen countdown on Android 14+, break-reveal confetti, shareable achievement cards, and peer achievement compare. Built by a student, for students.

---

## Full Changelog

### Themes

- 6 default themes available from day one: Coffee, Midnight, Mint, Sakura, Ocean, Sunset
- 11 unlockable themes gated by daily streak milestones (7, 14, 30, 50, 75, 100, 150, 200, 365 days) and achievement triggers
- Home screen widgets now follow the active theme and persona tint colors automatically

### Personas (30 total)

- Expanded from 8 to 30 fully-authored personas, each with unique copy for every countdown range, break reveals, and weekly recaps
- New personas: Nerd, Tired, Ice, Gremlin, Philosopher, Goblin, Cloud, Volcano, Sloth, Storm, Sprout, Moon, Star, Phoenix, Sunflower, Jester, Monk, Rebel, Hacker, Chef, Pirate, Robot
- Unlock via streak milestones and achievement triggers

### Achievements Overhaul

- Grown from 25 to 100+ achievements across 8 categories: School Progress, Monday Club, Exams & Schedule, Break Milestones, Power User, Streaks, Themes, Personas
- XP and level system with 10 ranks: Newcomer, Rookie, Survivor, Veteran, Master, Legend, Mythic, Ascendant, Transcendent, Eternal
- Daily quests: 3 tasks that refresh at midnight, granting XP on completion
- Rarity-sorted gallery with filter chips, search, and detail sheets
- Shareable achievement cards (1080x1920 PNG)
- Peer achievement compare over Nearby Connections

### Stats

- Weekly scheduled hours bar chart (from timetable)
- Subject distribution pie chart
- Mood distribution (7-day / 30-day toggle)
- Achievement unlock pace line chart
- Manual study log with FAB — tracks sessions per subject

### Offline OCR

- New offline pre-pass using ML Kit text recognition before calling Groq or any cloud provider
- Saves API quota on clear printed timetables
- Green "Parsed offline — no API call used" banner in the review screen

### Lock-Screen Countdown (Android 14+)

- Optional foreground service showing a persistent break countdown on the lock screen
- Chronometer-based live tick, refreshes every 15 minutes
- Toggle in Settings > Notifications

### UI Improvements

- Counter tab restructured: Vibe and Achievements moved to dedicated full-view screens, accessible via header icons
- Break-reveal confetti animation on first app-open after a break starts
- Dedicated Vibe screen with persona gallery, mood calendar, beacon, and recap history
- Dedicated Achievements screen with XP header, quests row, rarity grid, and detail sheets

### Technical

- Version bumped to 2.1.0+5
- Dynamic version in About card via package_info_plus
- Streak service with milestone tracking and listeners
- Unlock service for theme/persona gating with permanent persistence
- Added fl_chart, google_mlkit_text_recognition, package_info_plus dependencies

---

## Play Console Deployment Checklist

1. [ ] Build release AAB: `flutter build appbundle --release`
2. [ ] Upload AAB to Production track (versionCode 5)
3. [ ] Fill release notes (copy the "What's New" section above)
4. [ ] Close Open Testing / Early Access track
5. [ ] Verify content rating questionnaire is up to date
6. [ ] Verify Data Safety section reflects:
   - No data shared with third parties
   - Data collected: app activity (analytics), crash logs
   - Data stored on device: schedule, exams, reminders, API keys
   - Optional Google Drive backup (user-initiated)
7. [ ] Confirm target API level compliance (API 34+)
8. [ ] Submit for review

---

## Known Limitations

- Lock-screen countdown requires Android 14 (API 34+) — hidden on older devices
- Offline OCR works best on clear, grid-structured printed timetables; handwritten schedules still need the AI provider
- Peer achievement compare requires both devices to have BreakCount open and Bluetooth enabled
