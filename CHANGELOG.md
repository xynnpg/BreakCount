# Changelog

All notable changes to BreakCount are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.1.0] - 2026-05-12

### Added
- 10+ theme presets (6 default-unlocked, 11 streak/achievement-gated)
- 30 fully-authored personas with unique copy for all countdown ranges
- XP/level system (10 levels: Newcomer → Eternal)
- Daily quests (3 per day, XP rewards, midnight refresh)
- 100+ achievements across 8 categories (School Progress, Monday Club, Exams & Schedule, Break Milestones, Power User, Streaks, Themes, Personas)
- Achievement rarity gallery with filter chips, search, detail sheets
- Shareable achievement cards (1080×1920 PNG export)
- Peer achievement compare over Nearby Connections
- Stats deep-dive with `fl_chart` (weekly hours bar, subject pie, mood distribution, unlock pace line)
- Manual study log with FAB and per-subject tracking
- Offline OCR pre-pass via `google_mlkit_text_recognition`
- Lock-screen live activity countdown (Android 14+ foreground service)
- Break-reveal confetti animation on first app-open after break starts
- Dedicated Vibe full-view screen (persona gallery, mood calendar, beacon, recap history)
- Dedicated Achievements full-view screen (XP header, quests, rarity grid)
- Counter tab header icons for Vibe (✨) and Achievements (🏆) navigation
- Theme-aware home-screen widgets (background, text, accent follow app theme)
- Dynamic version in About card via `package_info_plus`
- Streak service with daily-check-in tracking and milestone listeners
- Unlock service for theme/persona gating by streak and achievement
- `docs/` folder with comprehensive architecture documentation

### Changed
- Counter tab restructured — removed bottom PersonalityCard and AchievementsSection
- Achievement rank system now XP-based (replaces simple unlock-count ranks)
- Theme system restored from single-preset stub to full multi-theme engine
- Widget provider reads theme colors and applies them programmatically
- AI scan flow tries offline OCR before calling cloud providers
- Version bumped from 2.0.2+4 to 2.1.0+5

### Fixed
- Hard-coded "v2.0.1" in About card now reads dynamically from package info
- `isOfflineOcr` flag now correctly propagated to review screen

## [2.0.2] - 2026-03-15

### Added
- Initial public release (Early Access / Open Testing)
- Break countdown with tap-to-cycle display modes
- Weekly schedule with A/B week rotation
- Exams tracker with reminders and calendar export
- AI timetable scan (Groq Llama 4 + Cloudflare Worker proxy)
- 25 achievements across 5 categories
- 8 personas (4 base + 4 unlockable)
- Shake-to-share schedule exchange
- Nearby Students discovery
- Home screen widgets (2×1, 2×2, 4×1, 4×2)
- Google Drive backup/restore
- 33+ countries with bundled school year data
- Firebase push notifications and crash reporting
