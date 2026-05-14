# Lock-Screen Live Activity

## Overview

An optional Android 14+ foreground service that shows a persistent break countdown on the lock screen. It uses a `Chronometer` widget for live ticking without draining the battery. Hidden on devices below API 34.

## Architecture

```
Flutter (LiveActivityService)
    |
    | MethodChannel 'com.breakcount/live_activity'
    v
MainActivity.kt (channel handler)
    |
    | startForegroundService / stopService
    v
BreakCountdownService.kt
    |
    | reads widget data from HomeWidget SharedPreferences
    | builds Notification with Chronometer
    v
Lock screen / notification shade
```

## Method Channel API

Channel: `com.breakcount/live_activity`

| Method | Returns | Description |
|--------|---------|-------------|
| `start` | bool | Starts the service (returns false if below API 34) |
| `stop` | bool | Stops the service |
| `isRunning` | bool | Whether the service is currently active |
| `isAvailable` | bool | Whether the device supports it (API 34+) |

## BreakCountdownService (Kotlin)

- Foreground service type: `specialUse` (countdown display)
- Notification channel: `breakcount_countdown` (IMPORTANCE_LOW)
- Notification: break name as title, "X days remaining" as content, Chronometer counting down to break start, ongoing, silent, public visibility
- Refresh: a Handler posts every 15 minutes to update the notification data
- Lifecycle: `isRunning` companion flag tracks state

## Flutter Service (LiveActivityService)

- `start()` — invokes the platform channel, persists `liveActivityEnabled = true`
- `stop()` — invokes the platform channel, persists `liveActivityEnabled = false`
- `isAvailable()` — checks platform support
- `isEnabled` — reads the persisted toggle state

## Settings Integration

Toggle lives in Settings > Notifications: "Lock-screen countdown (Android 14+)". The toggle is hidden entirely on devices where `isAvailable()` returns false.

## Permissions Required

- `FOREGROUND_SERVICE` — base permission
- `FOREGROUND_SERVICE_SPECIAL_USE` — required for specialUse type on API 34+
- `POST_NOTIFICATIONS` — required to show the notification
