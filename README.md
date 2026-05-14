<div align="center">

<img src="pics/logo.png" alt="BreakCount Logo" width="120" height="120" />

# BreakCount

### a student app that counts down to your next break — and somehow became a lot more than that.

[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://breakcount.tech)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg?style=for-the-badge)](LICENSE)

**[breakcount.tech](https://breakcount.tech)** · **v2.1.1**

</div>

---

## why does this exist?

i was sitting in class one day and genuinely could not remember how many days were left until break. i checked my phone, couldn't find a quick answer, and thought — someone should just make an app that shows the number. so i did.

then i added a schedule because i kept forgetting what class was next. then exams because i kept forgetting those too. then themes, personas, achievements, AI timetable scanning, home screen widgets, and a lock-screen countdown. at some point it became a real app.

no account. no subscription. no ads. just open it and see how long you have to survive.

---

## what's inside

### the countdown

the main screen is just a big number — days until your next break. tap it to switch to hours, minutes, seconds, or milliseconds if you're feeling dramatic. a progress ring wraps around it showing where you are in the school year, and below that is a full timeline of every break coming up.

two icons at the top open the two big side screens:
- **Vibe** — your persona card, mood calendar, nearby students, weekly recap history
- **Achievements** — XP bar, daily quests, the full achievement gallery

when a break actually starts, the app does a whole thing — confetti, full-screen message in your persona's voice. it's genuinely satisfying.

### themes

6 themes are available from day one: Coffee, Midnight, Mint, Sakura, Ocean, Sunset.

11 more unlock as your streak grows: Lavender, Forest, Aurora, Cosmic, AMOLED, Zen, Mono, Neon, Paper, Vapor, Solarized. the streak gates go from 7 days up to 365, so some of them take real dedication. home screen widgets automatically pick up your active theme — no extra setup needed.

### personas

there are 30 personas. pick one and the whole app shifts personality — the text, the colors, the confetti style, even what the widget says. every persona has its own lines for every countdown range, break reveals, and weekly recaps. it's not just a color swap, the whole voice changes.

**always unlocked:** Hype, Chill, Dramatic, Sarcastic

**unlock through streaks and achievements:** Ghost, Sage, Menace, Zen, Nerd, Tired, Ice, Gremlin, Philosopher, Goblin, Cloud, Volcano, Sloth, Storm, Sprout, Moon, Star, Phoenix, Sunflower, Jester, Monk, Rebel, Hacker, Chef, Pirate, Robot

### achievements and XP

100+ achievements across 8 categories: School Progress, Monday Club, Exams & Schedule, Break Milestones, Power User, Streaks, Themes, Personas.

four rarities: Bronze (25 XP), Silver (75 XP), Gold (200 XP), Platinum (500 XP). there are also Secret achievements worth 750 XP each — you have to figure those out yourself.

10 XP levels: Newcomer, Rookie, Survivor, Veteran, Master, Legend, Mythic, Ascendant, Transcendent, Eternal.

3 daily quests refresh at midnight. the gallery has filter chips, search, detail sheets with progress bars, and a shine animation on unlocked cards. you can export achievement cards as 1080x1920 PNGs or compare your collection with a nearby friend over Bluetooth.

### schedule

full Monday–Friday timetable with color-coded subjects, room numbers, and A/B week rotation. your current class and next class show up right on the home screen. subjects get auto-tagged with an importance level based on your country and school type.

### exams

add an exam with subject, date, type (quiz, midterm, final, presentation), and notes. set a reminder. past exams disappear on their own. export to your phone's calendar if you want it there too.

### AI timetable scan

take a photo of your printed timetable and the app tries to read it. it runs ML Kit offline first — if it gets 20+ entries at 60%+ confidence, it never touches the internet. if it's not confident enough, it falls back to Groq Llama 4.

- **have a Groq key?** add it in settings, free from [console.groq.com](https://console.groq.com)
- **no key?** the built-in proxy gives you 5 free scans a day, no setup needed

after scanning you get a review screen to fix anything before it saves.

### stats

four charts: weekly hours per subject (bar), subject distribution (pie), mood over 7 or 30 days, and achievement unlock pace over 60 days. tap the FAB to log a study session — it overlays on the weekly chart and counts toward study achievements.

### lock-screen countdown (Android 14+)

a persistent notification that ticks down live on your lock screen. uses a Chronometer so it doesn't drain your battery. turn it on in Settings > Notifications.

### vibe

your persona shows as a card on the home screen with a live mood based on how close break is. Friday and Monday get their own adjustments because those days hit different.

- long-press the card to open the Vibe Beacon — a radar that shows nearby students grouped by persona
- share your Vibe Card as a 1080x1920 PNG
- every Sunday at 19:00 you get a Weekly Vibe Recap — a one-liner in your persona's voice, AI-generated if you have a Groq key

### shake to share

both phones need BreakCount open and Bluetooth on. shake at the same time and a share sheet opens to swap schedules. no Wi-Fi, no QR codes, no accounts.

### home screen widgets

four sizes: 2x1, 2x2, 4x1, 4x2. shows countdown, break name, progress, and current class. colors follow your theme automatically.

### Google Drive backup

sign in with Google and your data backs up to your Drive's private app folder — invisible to everything else in your Drive. restore with one tap. auto-backup runs daily, weekly, or monthly, your choice.

### notifications

exam reminders, break start/end alerts, achievement unlocks, and Firebase push for announcements.

### in-app changelog

tap the version number at the bottom of Settings to read the full changelog. renders CHANGELOG.md with a theme-aware formatter.

---

## countries

school year data is bundled in the app — 33+ countries, works offline.

Australia, Austria, Belgium, Brazil, Canada, Croatia, Czech Republic, Denmark, Estonia, Finland, France, Germany, Greece, Hungary, Ireland, Italy, Japan, Latvia, Lithuania, Luxembourg, Mexico, Netherlands, Norway, Poland, Portugal, Romania, Slovakia, Slovenia, Spain, Sweden, Switzerland, Turkey, United Kingdom, United States

not on the list? the [OpenHolidays API](https://openholidaysapi.org) covers 30+ more and kicks in automatically.

---

## getting started

### download

[Google Play](https://breakcount.tech) or direct APK at [breakcount.tech](https://breakcount.tech). Android only (5.0+).

### build it yourself

you need Flutter 3.x (Dart 3.10+) and Android SDK 21+.

```bash
git clone https://github.com/your-username/breakcount.git
cd breakcount
flutter pub get
flutter run
```

```bash
# release APK
flutter build apk --release

# Play Store bundle
flutter build appbundle --release
```

---

## how to use it

**first launch:** intro carousel → pick country → pick school profile → fetch data → optional Google sign-in → grant permissions → you're live.

**schedule:** Schedule tab → + → add subject → assign time slots. or use the camera icon to scan a photo.

**exams:** Exams tab → + → fill it in → set a reminder → done.

**shake to share:** both phones open, Bluetooth on, shake at the same time.

**widgets:** long-press home screen → Widgets → BreakCount → pick a size.

**backup:** Settings → Backup & Restore → sign in → Back Up Now.

**themes:** Settings → Theme → tap a swatch. locked ones show what you need to unlock them.

---

## privacy

no accounts, no servers holding your data.

| data | where it lives |
|------|----------------|
| schedule, exams, reminders | your device |
| API keys | your device only |
| school year data | bundled in the app |
| backup | your own Google Drive (private folder) |
| analytics | anonymous events via Firebase |
| crashes | Firebase Crashlytics, no personal data |

[Privacy Policy](https://breakcount.tech/privacy.html) · [help@breakcount.tech](mailto:help@breakcount.tech)

---

## permissions

| permission | why |
|------------|-----|
| Camera | timetable scan |
| Photo library | picking an existing timetable image |
| Notifications | reminders, achievement unlocks, lock-screen countdown |
| Bluetooth + Location | shake-to-share, nearby students |
| Foreground Service | lock-screen countdown (Android 14+) |

all optional. the app works fine without any of them, those features just won't be available.

---

## tech stack

Flutter app with:

- AI: Groq Llama 4 + Cloudflare Worker proxy + ML Kit offline OCR
- Charts: fl_chart
- P2P: Android Nearby Connections
- Backup: Google Drive API v3 (appDataFolder)
- Push: Firebase Cloud Messaging + local notifications
- Crash reporting: Firebase Crashlytics
- Widgets: native Android AppWidgetProvider + home_widget
- Lock-screen: foreground service with Chronometer
- Shake: sensors_plus at 20 m/s² threshold
- Storage: SharedPreferences via typed service wrapper

---

## docs

full architecture and technical docs are in [docs/](docs/README.md):

- [Architecture](docs/architecture.md)
- [Services](docs/services.md)
- [Themes](docs/themes.md)
- [Achievements & XP](docs/achievements.md)
- [Personas](docs/personas.md)
- [Widgets](docs/widgets.md)
- [AI Scan & OCR](docs/ai-scan.md)
- [Lock-Screen](docs/live-activity.md)
- [Nearby / Mesh](docs/nearby.md)

---

## support

if BreakCount saved you from showing up to an exam you forgot about, consider [buying me a coffee](https://buymeacoffee.com/xynnpg).

---

<div align="center">

made for students, by a student.

**[breakcount.tech](https://breakcount.tech)** · [help@breakcount.tech](mailto:help@breakcount.tech)

</div>
