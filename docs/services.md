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
| `CalculatorService` | Break/year calculations (pure, no I/O) | `nextBreak(sy)`, `countdown(target)`, `yearProgress(sy)`, `getDayStats(sy)`, `activeSchoolDaysRemaining(sy)`, `formatCountdown(duration)` |

### CalculatorService — New Methods (v2.1.0)

| Method | Returns | Description |
|--------|---------|-------------|
| `getDayStats(sy)` | `Map<String, int>` | `daysSurvived`, `daysRemaining`, `weekNumber`, `totalDays` |
| `activeSchoolDaysRemaining(sy)` | `int` | Weekdays remaining that don't fall in a break period |
| `formatCountdown(duration)` | `Map<String, int>` | Splits a `Duration` into `days`, `hours`, `minutes`, `seconds` |

## Feature Services

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `AchievementService` | Unlock tracking, milestone helpers | `init()`, `unlock(id)`, `allUnlocks`, `onStreakMilestone()`, `onThemeUnlocked()`, `onPersonaUnlocked()`, `onStudySessionLogged()`, `onNotificationToggled(kind)`, `onWidgetTapped()` |
| `XpService` | XP sum, level, progress | `totalXp()`, `level()`, `progress()`, `rankTitle()` |
| `QuestService` | Daily quests (3/day) | `todayQuests()`, `incrementProgress()`, `claimReward()` |
| `StreakService` | Daily check-in streak | `init()`, `recordOpen()`, `currentStreak`, `longestStreak` |
| `UnlockService` | Theme/persona gating + permanent unlock persistence | `init()`, `isThemeUnlocked(id)`, `isPersonaUnlocked(id)`, `recordThemeUnlock(id)`, `recordPersonaUnlock(id)`, `requirements` |
| `PersonaService` | Active persona management | `instance.init()`, `currentNotifier`, `setPersona(id)` |
| `MoodService` | Mood tracking + streaks | `currentStreak(kind)`, `recordMood()` |
| `StudyLogService` | Manual study session log | `logSession()`, `all()`, `weeklyBreakdown()`, `totalMinutes()`, `totalSessions()`, `revision` (ValueNotifier) |

### UnlockService — Permanent Unlock Persistence

Unlocks are stored in `unlocked_themes_v1` / `unlocked_personas_v1` (JSON arrays in SharedPreferences) and **survive streak resets and backup restores**.

- `init()` — loads persisted sets and calls `_backfillFromLongestStreak()` to retroactively grant any streak-gated unlocks the user already earned
- `recordThemeUnlock(id)` — permanently records a theme unlock
- `recordPersonaUnlock(id)` — permanently records a persona unlock
- Called automatically from `main.dart` after `StreakService.recordOpen()` resolves

### StudyLogService

Persists user-logged study sessions and computes aggregates for the Stats screen.

| Method | Description |
|--------|-------------|
| `logSession({subjectId, subjectName, minutes})` | Appends a session, fires achievement ladder |
| `all()` | All sessions, newest first |
| `weeklyBreakdown({anchor})` | Minutes per subject name over trailing 7 days |
| `totalMinutesInWeekOf(date)` | Total minutes in the calendar week containing `date` |
| `totalMinutes()` | All-time minutes logged |
| `totalSessions()` | All-time session count |
| `revision` | `ValueNotifier<int>` — increments on every write; Stats screen listens to this |

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
| `SubjectImportanceService` | Country-aware subject tagging |
