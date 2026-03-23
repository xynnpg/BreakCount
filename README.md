# BreakCount

A Flutter app for students to track school year progress, manage their weekly timetable, and stay on top of exams — with a dark glassmorphic design.

## Features

- **Countdown** — Live school year progress ring and days-until-next-break counter, supporting alternating A/B weeks
- **Schedule** — Weekly timetable grid with subject color coding and room info
- **Exams** — Upcoming tests and exams tracker with reminders
- **AI Timetable Scan** — Point your camera at a printed timetable; Gemini or Groq parses it into your schedule automatically
- **Shake to Share** — Shake your phone near a classmate's to exchange schedules over Bluetooth (P2P, no internet needed)
- **11 countries** — School year data bundled for Romania, France, Germany, Italy, Japan, Canada, Mexico, Poland, Turkey, UK, and USA (2025–2026)
- **Themes** — Multiple color presets with a warm coffee-brown default

## Screenshots

_Coming soon_

## Getting Started

**Requirements:** Flutter 3.x, Android SDK 21+ or iOS 13+

```bash
git clone https://github.com/your-username/breakcount.git
cd breakcount
flutter pub get
flutter run
```

## API Keys (optional)

The AI timetable scan feature is opt-in. No keys are bundled or hardcoded — you supply your own in **Settings → AI Scan**.

| Provider | Where to get a key |
|----------|--------------------|
| Google Gemini | [aistudio.google.com](https://aistudio.google.com) |
| Groq | [console.groq.com](https://console.groq.com) |

Keys are stored on-device only (SharedPreferences). They are never sent to any server other than the respective AI provider.

## Platform Support

| Platform | Status |
|----------|--------|
| Android | ✅ |
| iOS | ✅ |
| Web / Desktop | Not supported |

## License

