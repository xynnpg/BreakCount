# Changelog

Every notable change to BreakCount is documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [2.1.1] - 2026-05-14

A patch release. No new features — just cleaning up things that were slightly off after the 2.1.0 launch.

### Fixed
- Achievements data expanded and corrected — several achievements weren't triggering in edge cases
- Unlock service now handles streak resets and backfill more reliably
- Backup service improvements for more consistent restores
- Minor fixes in the Exams tab, Schedule entry detail, and Settings screen
- Reminder and study log services hardened against null states

---

## [2.1.0] - 2026-05-12

This was a big update. Basically rebuilt half the app.

### Added
- 17 themes — 6 always unlocked, 11 gated behind streak milestones (7 days up to 365)
- 30 personas, each with unique copy for every countdown range, break reveals, and weekly recaps
- XP and level system — 10 levels from Newcomer all the way to Eternal
- Daily quests — 3 per day, XP rewards, reset at midnight
- 100+ achievements across 8 categories: School Progress, Monday Club, Exams & Schedule, Break Milestones, Power User, Streaks, Themes, Personas
- Achievement gallery with filter chips, search, detail sheets, and a shine animation on unlocked cards
- Shareable achievement cards (1080x1920 PNG export)
- Peer achievement compare over Nearby Connections
- Stats screen with fl_chart — weekly hours bar, subject pie, mood distribution, unlock pace line
- Manual study log with FAB and per-subject tracking
- Offline OCR pre-pass via ML Kit before calling any cloud API
- Lock-screen countdown for Android 14+ (foreground service with Chronometer)
- Break-reveal confetti animation on first app-open after a break starts
- Dedicated Vibe screen — persona gallery, mood calendar, beacon, recap history
- Dedicated Achievements screen — XP header, quests row, rarity grid
- Counter tab header icons for Vibe and Achievements navigation
- Theme-aware home screen widgets — background, text, and accent follow your active theme
- Dynamic version in the About card via package_info_plus
- Streak service with daily check-in tracking and milestone listeners
- Unlock service for theme/persona gating with permanent persistence (unlocks survive streak resets)
- docs/ folder with full architecture documentation

### Changed
- Counter tab restructured — removed the bottom PersonalityCard and AchievementsSection, they live in their own screens now
- Achievement rank system is now XP-based instead of simple unlock-count ranks
- Theme system rebuilt from a single-preset stub into a full multi-theme engine
- Widget provider now reads theme colors and applies them programmatically
- AI scan flow tries offline OCR before calling cloud providers
- Version bumped from 2.0.2+4 to 2.1.0+5

### Fixed
- Hard-coded "v2.0.1" in the About card now reads dynamically from package info
- isOfflineOcr flag now correctly propagated to the review screen

---

## [2.0.2] - 2026-03-15

The first public release. Early access, rough around the edges, but it worked.

### Added
- Break countdown with tap-to-cycle display modes (days, hours, minutes, seconds, milliseconds)
- Weekly schedule with A/B week rotation
- Exams tracker with reminders and calendar export
- AI timetable scan (Groq Llama 4 + Cloudflare Worker proxy)
- 25 achievements across 5 categories
- 8 personas (4 base + 4 unlockable)
- Shake-to-share schedule exchange
- Nearby Students discovery
- Home screen widgets (2x1, 2x2, 4x1, 4x2)
- Google Drive backup and restore
- 33+ countries with bundled school year data
- Firebase push notifications and crash reporting
