# Lock-Screen Live Activity

## Overview

Android 14+ (API 34) foreground service that shows a persistent break countdown notification on the lock screen. Uses `Chronometer` for battery-efficient live ticking.

## Architecture

```
Flutter (LiveActivityService)
    ↓ MethodChannel 'com.breakcount/live_activity'
MainActivity.kt (channel handler)
    ↓ startForegroundService / stopService
BreakCountdownService.kt
    ↓ reads widget data from HomeWidget SharedPreferences
    ↓ builds Notification with Chronometer
Lock screen / notification shade
```

## Method Channel API

Channel: `com.breakcount/live_activity`

| Method | Returns | Description |
|--------|---------|-------------|
| `start` | `bool` | Starts service (false if < API 34) |
| `stop` | `bool` | Stops service |
| `isRunning` | `bool` | Service active state |
| `isAvailable` | `bool` | Device supports it (API 34+) |

## BreakCountdownService (Kotlin)

- **Foreground service type:** `specialUse` (countdown display)
- **Notification channel:** `breakcount_countdown` (IMPORTANCE_LOW)
- **Notification features:**
  - Title: break name
  - Content: "X days remaining"
  - Chronometer counting down to break start
  - Ongoing, silent, public visibility
- **Refresh:** Handler posts every 15 minutes to update notification data
- **Lifecycle:** `isRunning` companion flag tracks state

## Flutter Service (`LiveActivityService`)

- `start()` — invokes platform, persists `liveActivityEnabled = true`
- `stop()` — invokes platform, persists `liveActivityEnabled = false`
- `isAvailable()` — checks platform support
- `isEnabled` — reads persisted toggle state

## Settings Integration

Toggle in Settings → Notifications section: "Lock-screen countdown (Android 14+)". Hidden on devices where `isAvailable()` returns false.

## Permissions

- `FOREGROUND_SERVICE` — base permission
- `FOREGROUND_SERVICE_SPECIAL_USE` — required for specialUse type on API 34+
- `POST_NOTIFICATIONS` — required to show the notification
