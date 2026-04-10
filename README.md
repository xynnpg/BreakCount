<div align="center">

<img src="pics/logo.png" alt="BreakCount Logo" width="120" height="120" />

# BreakCount

### The student app that counts down to your next school break — so you don't have to.

[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://breakcount.tech)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg?style=for-the-badge)](LICENSE)

**[🌐 breakcount.tech](https://breakcount.tech)**

</div>

---

## What is BreakCount?

BreakCount started as a simple "how many days until break?" app and grew into a full student toolkit. It handles your schedule, tracks your exams, backs up your data to Google Drive, and even reads a printed timetable photo with AI — all without an account or subscription.

It's built by a student, for students. No ads, no tracking, no nonsense.

---

## Features

### 📅 Countdown
The main screen shows a big countdown to your next school break. Tap the number to cycle the display through **days → hours → minutes → seconds → milliseconds** — useful when a break is close enough to feel every tick. There's also a school year progress ring so you always know exactly where you are in the year. Underneath, you'll see a timeline of every upcoming break so nothing sneaks up on you.

The countdown screen also surfaces two extra sections directly below the timeline:

**Your Vibe** — a card showing your current personality and mood emoji (calculated from how far away the next break is, with a Friday afternoon boost and Monday morning dip built in). Tap it to see nearby students. See [Nearby Students](#-nearby-students) below.

**Achievements** — your rank badge, a progress bar, and the three most recently unlocked achievements. Tap "View All" for the full gallery.

### 🗓️ Weekly Schedule
A full Monday–Friday timetable grid. Add subjects with color-coding and room info, and BreakCount will show you what class you're in right now (or what's coming up next) directly on the home screen. Supports A/B week rotation for schools that alternate timetables.

Each subject is automatically tagged with an **importance level** (Low / Medium / High / Critical) based on your country and school profile. These tags are country-specific — so "Matematică" in Romania and "Mathematics" in the UK both resolve correctly — and you can override any subject's level manually.

### 📝 Exams & Tests Tracker
Add exams with a subject, date, type (quiz, midterm, final, presentation, etc.), and optional room or notes. Set a reminder — 1 day before, 2 days before, morning of, 2 hours before, or a custom time. Past exams automatically move out of your way. You can also export any exam straight to your phone's calendar.

### 🔔 Reminders & Notifications
BreakCount will remind you before exams, and also ping you the day before a break starts or ends so you're never caught off guard. Notifications work locally — no server needed — but the app can also receive announcements (new country data, app updates) via Firebase push in the background.

### 🤖 AI Timetable Scan
The fastest way to set up your schedule. Point your camera at a printed timetable and BreakCount parses the whole thing into your digital schedule automatically.

**Two AI providers supported:**
- **Groq Llama 4** — paste a key starting with `gsk_` from [console.groq.com](https://console.groq.com) (free)
- **Google Gemini** — paste a key from [aistudio.google.com](https://aistudio.google.com) (free tier)
- **No key at all?** BreakCount has a built-in fallback proxy that gives you **5 free scans per day** with zero setup

After scanning, you get a full review screen where you can edit or swipe-delete any entry before saving. Nothing gets applied without you checking it first.

### 🏆 Achievements
25 achievements across five categories: **School Progress**, **Monday Club**, **Exams & Schedule**, **Break Milestones**, and **Power User**. Rarities range from Bronze to Platinum, with a handful of hidden **Secret** achievements that show `???` until you trigger them (try opening the app at 2 AM, or adding an exam the night before).

Your rank updates as you unlock more: Newcomer → Rookie → Survivor → Veteran → Master → Legend.

Every unlock fires a **push notification** so you never miss one, even when the app is in the background.

### 🎭 Personality & Nearby Students
Pick a personality in Settings → **Widget Personality**:
- 🔥 **Hype** — "LET'S GO only 14 days!!!"
- 😎 **Chill** — "eh, 14 days"
- 🎭 **Dramatic** — "I CANNOT 14 MORE DAYS"
- 🙃 **Sarcastic** — "14 days. Cool. Fine. Whatever."

Your personality shows on your home screen widget and as a **Vibe card** on the countdown screen. The card also shows a live mood emoji — 💀 when a break is months away, 🤩 when it's basically here — with smart adjustments for Friday afternoons and Monday mornings.

Tap the Vibe card to open the **Nearby Students** screen: a live Bluetooth radar that discovers other BreakCount users around you. Each card shows their anonymous name, personality, and how many subjects/classes they have set up. Tap "Copy" to pull their schedule directly to your device.

### 📳 Shake to Share
Shake your phone near a classmate's at the same time and BreakCount opens a share sheet to exchange schedules over Bluetooth — no Wi-Fi, no QR codes, no accounts. Works between two Android phones with the app installed.

### 🏠 Home Screen Widgets
Four widget sizes (2×1, 2×2, 4×1, 4×2) that sit on your Android home screen and show your countdown, next break name, school year progress, and current or next class. They update automatically as your data changes.

### ☁️ Google Drive Backup
Sign in with Google and BreakCount backs up your entire setup — schedule, subjects, exams, reminders, settings, API keys, theme — to your Drive's private app data folder. It's invisible to your other Drive files and only BreakCount can read it. Restore anytime with one tap.

### 📊 Stats
A dedicated stats screen breaks down your school year: total breaks, days you've spent on break, days until summer, upcoming exam count, and more. Good for when you need to justify to yourself why you're still in bed.

---

## Supported Countries

School year data is bundled locally — 33+ countries available offline, no internet needed.

Australia · Austria · Belgium · Brazil · Canada · Croatia · Czech Republic · Denmark · Estonia · Finland · France · Germany · Greece · Hungary · Ireland · Italy · Japan · Latvia · Lithuania · Luxembourg · Mexico · Netherlands · Norway · Poland · Portugal · Romania · Slovakia · Slovenia · Spain · Sweden · Switzerland · Turkey · United Kingdom · United States

> Don't see your country? The [OpenHolidays API](https://openholidaysapi.org) covers 30+ additional countries and kicks in automatically as a fallback.

---

## Getting Started

### Download

Head to **[breakcount.tech](https://breakcount.tech)** to download the latest Android APK directly.

> BreakCount is **Android only** right now.

### Build from Source

**Requirements:**
- Flutter 3.x SDK
- Android SDK 21+ (Android 5.0 or newer)

```bash
git clone https://github.com/your-username/breakcount.git
cd breakcount
flutter pub get
flutter run
```

```bash
# Release APK
flutter build apk
```

---

## Tutorial

### First Launch — Onboarding

When you first open BreakCount, you'll go through a short onboarding:

1. A quick intro carousel explains the main features
2. You pick your country from a searchable grid
3. You pick your **school profile** — the curriculum or institution type that matches your school (e.g. "Liceu Teoretic" for Romania). This sets smart subject importance defaults. You can skip this and stick with the generic country defaults
4. BreakCount fetches your school year data and caches it locally
5. You optionally connect a Google account to enable backup/restore
6. You grant whichever permissions you want (notifications, Bluetooth, etc.)
7. You land on the home screen with your countdown already live

---

### Setting Up Your Schedule

**Option 1 — Manual:**
1. Go to the **Schedule** tab
2. Tap **+** to add a subject (name + color)
3. Assign it to time slots across the week
4. Add room info if you want it

**Option 2 — AI Scan (much faster):**
1. Go to **Settings → AI Features** and optionally paste a Groq or Gemini API key (or leave it blank for 5 free scans/day)
2. In the **Schedule** tab, tap the camera icon
3. Take a clear photo of your printed timetable — flat surface, good light
4. Review the result, edit anything that looks off, swipe to delete entries you don't need
5. Tap **Confirm** and your whole week is done

---

### Tracking Exams

1. Go to the **Exams** tab
2. Tap **+** and fill in the subject, date, and type
3. Set a reminder if you want one — you can pick how far in advance
4. BreakCount sorts everything by date and hides past exams automatically
5. Tap any exam to export it to your phone's calendar

---

### Shake to Share

1. Both phones need BreakCount installed and Bluetooth enabled
2. Both students shake at the same time (firm shake, ~1.5 seconds)
3. A bottom sheet pops up — tap **Share** to send or **Import** to receive
4. That's it

### Nearby Students

1. On the countdown screen, tap the **Your Vibe** card
2. BreakCount starts scanning for other students running the app nearby
3. Each discovered student card shows their name, personality, and schedule stats
4. Tap **Copy** on any card to pull their schedule to your device
5. If nobody shows up, make sure the other person also has BreakCount open — the app needs to be in the foreground on both devices

---

### Widgets

1. Long-press your home screen → **Widgets**
2. Find **BreakCount** in the list
3. Pick a size and drag it wherever you want
4. It updates on its own as your countdown changes

---

### Backup & Restore

1. Go to **Settings → Backup & Restore**
2. Sign in with Google
3. Tap **Back Up Now** — your data goes to your Drive's private app storage (not visible in Drive's file browser)
4. On a new phone: install BreakCount, sign in with the same Google account, and tap **Restore**

---

### Themes

Go to **Settings → Theme** and pick a color preset. The default is a warm coffee-brown palette. More presets are available in the theme picker.

---

## Privacy

No accounts required. No servers storing your data. The app collects minimal anonymous analytics (screen views, feature usage) via Firebase, but nothing is tied to your identity.

| Data | Where it lives |
|------|---------------|
| Schedule, exams, reminders | Your device (local storage) |
| API keys | Your device only |
| School year data | Bundled in the app + optional API fetch |
| Backup | Your own Google Drive (private app folder) |
| Analytics | Anonymous events via Firebase Analytics |
| Crashes | Firebase Crashlytics (no personal data) |

[Privacy Policy](https://breakcount.tech/privacy.html) · Questions? [help@breakcount.tech](mailto:help@breakcount.tech)

---

## Permissions

BreakCount asks for these on Android:

| Permission | Why |
|-----------|-----|
| Camera | AI timetable photo scan |
| Photo library | Picking an existing timetable image |
| Notifications | Exam and break reminders |
| Bluetooth + Location | Shake-to-share with nearby devices |

All permissions are optional — the app works without them, just with those features disabled.

---

## Platform Support

| Platform | Status |
|----------|--------|
| Android 5.0+ | ✅ Supported |
| iOS | 🚫 Not available |
| Web / Desktop | 🚫 Not supported |

---

## Tech Stack

Built with Flutter. Key pieces under the hood:

- **AI:** Google Gemini 2.0 Flash + Groq Llama 4, with a Cloudflare Worker proxy for keyless fallback
- **P2P:** Android Nearby Connections (Bluetooth)
- **Backup:** Google Drive API v3 (appDataFolder scope)
- **Push:** Firebase Cloud Messaging + local notifications
- **Crash reporting:** Firebase Crashlytics
- **Home screen widgets:** Native Android `AppWidgetProvider` + `home_widget`
- **Shake detection:** `sensors_plus` accelerometer (20 m/s² threshold)
- **Storage:** SharedPreferences via a typed service wrapper

---

## Support the Project

If BreakCount saves you from showing up unprepared to an exam, consider [buying me a coffee ☕](https://buymeacoffee.com/xynnpg).

---

<div align="center">

Made for students, by a student.

**[breakcount.tech](https://breakcount.tech)** · [help@breakcount.tech](mailto:help@breakcount.tech)

</div>
