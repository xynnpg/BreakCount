<div align="center">

<img src="pics/logo.png" alt="BreakCount Logo" width="120" height="120" />

# BreakCount

### The student app that counts down to your next school break — so you don't have to.

[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://breakcount.tech)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg?style=for-the-badge)](LICENSE)

**[🌐 breakcount.tech](https://breakcount.tech)** · **v2.1.0**

</div>

---

## What is BreakCount?

BreakCount started as a simple "how many days until break?" app and grew into a full student toolkit. It handles your schedule, tracks your exams, backs up your data to Google Drive, and even reads a printed timetable photo with AI — all without an account or subscription.

It's built by a student, for students. No ads, no tracking, no nonsense.

---

## Features

### 📅 Countdown
The main screen shows a big countdown to your next school break. Tap the number to cycle through **days → hours → minutes → seconds → milliseconds**. A school year progress ring shows exactly where you are in the year, and a timeline lists every upcoming break.

Two header icons at the top open dedicated full-view screens:
- **✨ Vibe** — persona gallery, mood calendar, nearby beacon, recap history
- **🏆 Achievements** — XP/level header, daily quests, rarity-sorted gallery

When a break starts, a **break-reveal animation** plays: confetti burst + persona-flavored full-screen message.

### 🎨 Themes (10+)
6 default themes always available: **Coffee** ☕, **Midnight** 🌙, **Mint** 🌿, **Sakura** 🌸, **Ocean** 🌊, **Sunset** 🌇.

11 more unlock via daily streak milestones and achievement triggers: Lavender, Forest, Aurora, Cosmic, AMOLED, Zen, Mono, Neon, Paper, Vapor, Solarized. Streak gates range from 7 to 365 consecutive days.

Home-screen widgets automatically follow the active theme colors.

### 🎭 30 Personas
Pick a persona and the whole app follows — copy, colors, confetti, widgets. Each persona has unique text for every countdown range, break reveals, and weekly recaps.

**Base (always unlocked):** Hype 🔥, Chill 😎, Dramatic 🎭, Sarcastic 🙃

**Unlockable (22 more):** Ghost 👻, Sage 🧙, Menace 😈, Zen 🧘, Nerd 🤓, Tired 🥱, Ice 🧊, Gremlin 😈, Philosopher 🧐, Goblin 👺, Cloud ☁️, Volcano 🌋, Sloth 🦥, Storm ⛈️, Sprout 🌱, Moon 🌙, Star ⭐, Phoenix 🦅, Sunflower 🌻, Jester 🃏, Monk ☸️, Rebel 🤘, Hacker 💻, Chef 👨‍🍳, Pirate 🏴‍☠️, Robot 🤖

Unlock via streak milestones and achievement triggers.

### 🏆 Achievements & XP (100+)
100+ achievements across 8 categories: **School Progress**, **Monday Club**, **Exams & Schedule**, **Break Milestones**, **Power User**, **Streaks**, **Themes**, **Personas**.

Rarities: Bronze (25 XP) → Silver (75 XP) → Gold (200 XP) → Platinum (500 XP) → Secret (750 XP).

**XP/Level system** with 10 ranks: Newcomer → Rookie → Survivor → Veteran → Master → Legend → Mythic → Ascendant → Transcendent → Eternal.

**Daily quests:** 3 bite-size tasks refresh at midnight, granting XP on completion.

**Gallery features:** rarity-sorted grid, filter chips (All / Unlocked / Locked / Secret / per-category), search, detail sheets with progress bars, animated rarity shine on unlocked cards.

**Social:** shareable achievement cards (1080×1920 PNG), peer achievement compare over Nearby Connections.

### 🗓️ Weekly Schedule
Full Monday–Friday timetable grid with color-coding, room info, and A/B week rotation. Shows current/next class on the home screen. Each subject is auto-tagged with an importance level based on your country and school profile.

### 📝 Exams & Tests Tracker
Add exams with subject, date, type (quiz, midterm, final, presentation), and optional notes. Set reminders at various intervals. Past exams auto-hide. Export any exam to your phone's calendar.

### 🤖 AI Timetable Scan + Offline OCR
Point your camera at a printed timetable and BreakCount parses it automatically.

**Offline first:** ML Kit text recognition tries to parse locally before calling any API. If confident (≥20 entries, ≥60% confidence), it skips the cloud call entirely — saving your quota and working without internet.

**Cloud providers (fallback):**
- **Groq Llama 4** — free key from [console.groq.com](https://console.groq.com)
- **No key?** Built-in proxy gives **5 free scans/day** with zero setup

Full review screen lets you edit or swipe-delete entries before saving.

### 📊 Stats Deep-Dive
Four chart sections powered by `fl_chart`:
- **Weekly hours** — bar chart of scheduled hours per subject, with logged study sessions overlaid
- **Subject distribution** — pie chart from your timetable
- **Mood distribution** — 7d/30d toggle from mood history
- **Unlock pace** — line chart of achievement unlocks over 60 days

**Study log:** tap the FAB to log "I studied X minutes of [subject]". Logged sessions overlay on the weekly hours chart and tick study-related achievements. All-time totals (minutes, sessions) are tracked and exposed to the achievement ladder.

### 📱 Lock-Screen Countdown (Android 14+)
Optional persistent notification showing your break countdown directly on the lock screen. Uses a Chronometer widget for battery-efficient live ticking. Toggle in Settings → Notifications.

### ✨ The Vibe System
Your persona shows as a **Vibe card** on the countdown screen with a live mood emoji (💀 → 🤩 based on break proximity, with Friday/Monday adjustments).

- **Long-press** the Vibe card → Vibe Beacon radar (groups nearby students by persona)
- **Share your Vibe Card** → 1080×1920 PNG with persona, rank, mood streak, top achievements
- **Weekly Vibe Recap** → Sunday 19:00 persona-tuned one-liner (AI-generated if Groq key set)

### 📳 Shake to Share
Shake your phone near a classmate's and BreakCount opens a share sheet to exchange schedules over Bluetooth — no Wi-Fi, no QR codes, no accounts.

### 🏠 Home Screen Widgets
Four sizes (2×1, 2×2, 4×1, 4×2) showing countdown, break name, progress, and current class. **Theme-aware:** background and text colors follow your active theme and persona tint.

### ☁️ Google Drive Backup
Sign in with Google to back up everything to your Drive's private app data folder. Invisible to other Drive files. Restore anytime with one tap. Supports auto-backup (daily/weekly/monthly).

### 🔔 Reminders & Notifications
Local exam reminders + break start/end alerts. Firebase push for app announcements. Achievement unlock notifications.

### 📋 In-App Changelog
Tap the version badge at the bottom of Settings to open a full-screen changelog viewer. Renders `CHANGELOG.md` with a minimal theme-aware formatter — no extra dependencies.

---

## Supported Countries

School year data is bundled locally — 33+ countries available offline, no internet needed.

Australia · Austria · Belgium · Brazil · Canada · Croatia · Czech Republic · Denmark · Estonia · Finland · France · Germany · Greece · Hungary · Ireland · Italy · Japan · Latvia · Lithuania · Luxembourg · Mexico · Netherlands · Norway · Poland · Portugal · Romania · Slovakia · Slovenia · Spain · Sweden · Switzerland · Turkey · United Kingdom · United States

> Don't see your country? The [OpenHolidays API](https://openholidaysapi.org) covers 30+ additional countries and kicks in automatically as a fallback.

---

## Getting Started

### Download

Available on **[Google Play](https://breakcount.tech)** and as a direct APK at **[breakcount.tech](https://breakcount.tech)**.

> BreakCount is **Android only** (5.0+).

### Build from Source

**Requirements:**
- Flutter 3.x SDK (Dart 3.10+)
- Android SDK 21+ (Android 5.0 or newer)

```bash
git clone https://github.com/your-username/breakcount.git
cd breakcount
flutter pub get
flutter run
```

```bash
# Release APK
flutter build apk --release

# Release AAB (for Play Store)
flutter build appbundle --release
```

---

## Tutorial

### First Launch
1. Intro carousel → pick country → pick school profile → fetch data → optional Google sign-in → grant permissions → countdown live

### Schedule Setup
**Manual:** Schedule tab → + → add subject → assign time slots
**AI Scan:** Schedule tab → camera icon → photo of timetable → review → confirm

### Exams
Exams tab → + → fill subject/date/type → set reminder → done

### Shake to Share
Both phones: BreakCount open + Bluetooth on → shake simultaneously → share/import

### Widgets
Long-press home screen → Widgets → BreakCount → pick size → drag

### Backup
Settings → Backup & Restore → sign in → Back Up Now / Restore

### Themes
Settings → Theme → tap any unlocked swatch (locked ones show streak requirement)

---

## Privacy

No accounts required. No servers storing your data.

| Data | Where it lives |
|------|---------------|
| Schedule, exams, reminders | Your device (local storage) |
| API keys | Your device only |
| School year data | Bundled in the app + optional API fetch |
| Backup | Your own Google Drive (private app folder) |
| Analytics | Anonymous events via Firebase Analytics |
| Crashes | Firebase Crashlytics (no personal data) |

[Privacy Policy](https://breakcount.tech/privacy.html) · [help@breakcount.tech](mailto:help@breakcount.tech)

---

## Permissions

| Permission | Why |
|-----------|-----|
| Camera | AI timetable photo scan |
| Photo library | Picking an existing timetable image |
| Notifications | Exam/break reminders, achievement unlocks, lock-screen countdown |
| Bluetooth + Location | Shake-to-share, nearby students |
| Foreground Service | Lock-screen countdown (Android 14+) |

All permissions are optional — the app works without them, just with those features disabled.

---

## Tech Stack

Built with Flutter. Key pieces:

- **AI:** Groq Llama 4 + Cloudflare Worker proxy + ML Kit offline OCR
- **Charts:** `fl_chart` (weekly hours, subject pie, mood, unlock pace)
- **P2P:** Android Nearby Connections (Bluetooth)
- **Backup:** Google Drive API v3 (appDataFolder scope)
- **Push:** Firebase Cloud Messaging + local notifications
- **Crash reporting:** Firebase Crashlytics
- **Home screen widgets:** Native Android `AppWidgetProvider` + `home_widget`
- **Lock-screen:** Foreground service with `Chronometer` notification
- **Shake detection:** `sensors_plus` accelerometer (20 m/s² threshold)
- **Storage:** SharedPreferences via a typed service wrapper
- **Version:** `package_info_plus` for dynamic About card

---

## Documentation

Detailed architecture and system documentation lives in [`docs/`](docs/README.md):

- [Architecture Overview](docs/architecture.md)
- [Services Reference](docs/services.md)
- [Theme System](docs/themes.md)
- [Achievements & XP](docs/achievements.md)
- [Personas](docs/personas.md)
- [Home Screen Widgets](docs/widgets.md)
- [AI Scan & OCR](docs/ai-scan.md)
- [Lock-Screen Live Activity](docs/live-activity.md)
- [Nearby / Mesh](docs/nearby.md)

---

## Support the Project

If BreakCount saves you from showing up unprepared to an exam, consider [buying me a coffee ☕](https://buymeacoffee.com/xynnpg).

---

<div align="center">

Made for students, by a student.

**[breakcount.tech](https://breakcount.tech)** · [help@breakcount.tech](mailto:help@breakcount.tech)

</div>
