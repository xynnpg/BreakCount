# Services Reference

All services live in `lib/services/`. They're static-method classes (no instantiation needed) unless noted otherwise.

## Core Services

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `StorageService` | SharedPreferences wrapper | `init()`, `getString()`, `saveBool()`, `saveString()` |
| `SchoolDataService` | Fetches and caches school year data | `fetch(country)`, `getCached()`, `lastUpdated()` |
| `ScheduleService` | CRUD for the weekly timetable | `getSchedule()`, `getSubjects()`, `saveEntry()`, `clearAll()` |
| `ExamService` | CRUD for exams | `getExams()`, `addExam()`, `deleteExam()` |
| `ReminderService` | Exam and break reminders | `getUpcomingReminders()`, `addReminder()` |
| `CalculatorService` | Break and year calculations (pure, no I/O) | `nextBreak(sy)`, `countdown(target)`, `yearProgress(sy)`, `getDayStats(sy)`, `activeSchoolDaysRemaining(sy)`, `formatCountdown(duration)` |

### CalculatorService — Methods added in v2.1.0

| Method | Returns | Description |
|--------|---------|-------------|
| `getDayStats(sy)` | `Map<String, int>` | `daysSurvived`, `daysRemaining`, `weekNumber`, `totalDays` |
| `activeSchoolDaysRemaining(sy)` | `int` | Weekdays remaining that don't fall in a break period |
| `formatCountdown(duration)` | `Map<String, int>` | Splits a `Duration` into `days`, `hours`, `minutes`, `seconds` |

## Feature Services

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `AchievementService` | Unlock tracking and milestone helpers | `init()`, `unlock(id)`, `allUnlocks`, `onStreakMilestone()`, `onThemeUnlocked()`, `onPersonaUnlocked()`, `onStudySessionLogged()`, `onNotificationToggled(kind)`, `onWidgetTapped()` |
| `XpService` | XP sum, level, and progress | `totalXp()`, `level()`, `progress()`, `rankTitle()` |
| `QuestService` | Daily quests (3 per day) | `todayQuests()`, `incrementProgress()`, `claimReward()` |
| `StreakService` | Daily check-in streak | `init()`, `recordOpen()`, `currentStreak`, `longestStreak` |
| `UnlockService` | Theme/persona gating and permanent unlock persistence | `init()`, `isThemeUnlocked(id)`, `isPersonaUnlocked(id)`, `recordThemeUnlock(id)`, `recordPersonaUnlock(id)`, `requirements` |
| `PersonaService` | Active persona management | `instance.init()`, `currentNotifier`, `setPersona(id)` |
| `MoodService` | Mood tracking and streaks | `currentStreak(kind)`, `recordMood()` |
| `StudyLogService` | Manual study session log | `logSession()`, `all()`, `weeklyBreakdown()`, `totalMinutes()`, `totalSessions()`, `revision` (ValueNotifier) |

### UnlockService — Permanent Unlock Persistence

Unlocks are stored in `unlocked_themes_v1` and `unlocked_personas_v1` (JSON arrays in SharedPreferences) and survive both streak resets and backup restores.

- `init()` — loads persisted sets and calls `_backfillFromLongestStreak()` to retroactively grant any streak-gated unlocks the user already earned
- `recordThemeUnlock(id)` — permanently records a theme unlock
- `recordPersonaUnlock(id)` — permanently records a persona unlock
- Both are called automatically from `main.dart` after `StreakService.recordOpen()` resolves

### StudyLogService

Persists user-logged study sessions and computes aggregates for the Stats screen.

| Method | Description |
|--------|-------------|
| `logSession({subjectId, subjectName, minutes})` | Appends a session and fires the achievement ladder |
| `all()` | All sessions, newest first |
| `weeklyBreakdown({anchor})` | Minutes per subject name over the trailing 7 days |
| `totalMinutesInWeekOf(date)` | Total minutes in the calendar week containing `date` |
| `totalMinutes()` | All-time minutes logged |
| `totalSessions()` | All-time session count |
| `revision` | `ValueNotifier<int>` — increments on every write; the Stats screen listens to this |

## Platform Services

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `WidgetService` | Pushes data to Android home screen widgets | `update()` |
| `LiveActivityService` | Lock-screen countdown control | `start()`, `stop()`, `isAvailable()`, `isRunning()` |
| `NotificationService` | Local notifications | `init()`, `show()`, `requestPermissions()` |
| `BreakNotificationService` | Break start/end alerts | `init()`, `scheduleBreakNotifications(sy)` |
| `FcmService` | Firebase Cloud Messaging | `init()` |
| `BackupService` | Google Drive backup and restore | `backup()`, `restore()`, `isSignedIn()` |
| `ShakeService` | Accelerometer shake detection | `startListening()`, `onShake` callback |
| `MeshService` | Nearby Connections P2P | `startDiscovery()`, `sendPayload()`, `onPeerFound` |

## AI Services

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `AiScheduleService` | Timetable photo to schedule entries | `parseImage(file, apiKey)` |
| `OcrTimetableParser` | Offline ML Kit pre-pass | `parse(file)`, `parseRecognized(text)` |
| `RecapAiService` | Weekly persona recap generation | `generateRecap()` |

## Utility Services

| Service | Purpose |
|---------|---------|
| `AnalyticsService` | Firebase Analytics event logging |
| `CalendarService` | Export exams to the device calendar |
| `SubjectImportanceService` | Country-aware subject importance tagging |
