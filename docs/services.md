# Services Reference

All services live in `lib/services/`. They are static-method classes (no instantiation needed) unless noted.

## Core Services

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `StorageService` | SharedPreferences wrapper | `init()`, `getString()`, `saveBool()`, `saveString()` |
| `SchoolDataService` | Fetches/caches school year data | `fetch(country)`, `getCached()`, `lastUpdated()` |
| `ScheduleService` | CRUD for weekly timetable | `getSchedule()`, `getSubjects()`, `saveEntry()`, `clearAll()` |
| `ExamService` | CRUD for exams | `getExams()`, `addExam()`, `deleteExam()` |
| `ReminderService` | Exam/break reminders | `getUpcomingReminders()`, `addReminder()` |

## Feature Services

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `AchievementService` | Unlock tracking, milestone helpers | `init()`, `unlock(id)`, `allUnlocks`, `onStreakMilestone()`, `onThemeUnlocked()`, `onPersonaUnlocked()` |
| `XpService` | XP sum, level, progress | `totalXp()`, `level()`, `progress()`, `rankTitle()` |
| `QuestService` | Daily quests (3/day) | `todayQuests()`, `incrementProgress()`, `claimReward()` |
| `StreakService` | Daily check-in streak | `init()`, `recordOpen()`, `currentStreak`, `longestStreak` |
| `UnlockService` | Theme/persona gating | `isThemeUnlocked(id)`, `isPersonaUnlocked(id)`, `requirements` |
| `PersonaService` | Active persona management | `instance.init()`, `currentNotifier`, `setPersona(id)` |
| `MoodService` | Mood tracking + streaks | `currentStreak(kind)`, `recordMood()` |
| `StudyLogService` | Manual study session log | `logSession()`, `weeklyBreakdown()`, `all()` |

## Platform Services

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `WidgetService` | Pushes data to Android widgets | `update()` |
| `LiveActivityService` | Lock-screen countdown control | `start()`, `stop()`, `isAvailable()`, `isRunning()` |
| `NotificationService` | Local notifications | `init()`, `show()`, `requestPermissions()` |
| `BreakNotificationService` | Break start/end alerts | `init()`, `scheduleBreakNotifications(sy)` |
| `FcmService` | Firebase Cloud Messaging | `init()` |
| `BackupService` | Google Drive backup/restore | `backup()`, `restore()`, `isSignedIn()` |
| `ShakeService` | Accelerometer shake detection | `startListening()`, `onShake` callback |
| `MeshService` | Nearby Connections P2P | `startDiscovery()`, `sendPayload()`, `onPeerFound` |

## AI Services

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `AiScheduleService` | Timetable photo → entries | `parseImage(file, apiKey)` |
| `OcrTimetableParser` | Offline ML Kit pre-pass | `parse(file)`, `parseRecognized(text)` |
| `RecapAiService` | Weekly persona recap generation | `generateRecap()` |

## Utility Services

| Service | Purpose |
|---------|---------|
| `AnalyticsService` | Firebase Analytics event logging |
| `CalendarService` | Export exams to device calendar |
| `CalculatorService` | Break/year calculations |
| `SubjectImportanceService` | Country-aware subject tagging |
