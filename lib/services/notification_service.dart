import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/exam.dart';
import '../models/reminder.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ------------------------------------------------------------------ init --

  static Future<void> init() async {
    if (_initialized) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(android: android, iOS: ios);
      await _plugin.initialize(settings);

      // Create all notification channels.
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'breakcount_reminders',
            'BreakCount Reminders',
            description: 'Reminders for tests, exams, and breaks',
            importance: Importance.high,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'breakcount_exams',
            'Exam Reminders',
            description: 'Upcoming exam notifications',
            importance: Importance.high,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'breakcount_announcements',
            'Announcements',
            description: 'News and updates from BreakCount',
            importance: Importance.high,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'breakcount_achievements',
            'Achievements',
            description: 'Notifies when a new achievement is unlocked',
            importance: Importance.high,
          ),
        );
      }

      _initialized = true;

      // On Android, request battery-optimization exemption so alarms fire
      // even when the app is killed — critical on Samsung One UI.
      _requestBatteryExemption();
    } catch (e) {
      debugPrint('NotificationService.init error: $e');
    }
  }

  static Future<void> _requestBatteryExemption() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (e) {
      debugPrint('NotificationService._requestBatteryExemption error: $e');
    }
  }

  // ------------------------------------------------------------ timezone ----

  static const _tzChannel = MethodChannel('com.breakcount.app/timezone');

  static Future<void> initTimezone() async {
    try {
      tz_data.initializeTimeZones();
      final timezoneName = await _tzChannel.invokeMethod<String>('getLocalTimezone') ?? 'UTC';
      tz.setLocalLocation(tz.getLocation(timezoneName));
      if (kDebugMode) debugPrint('[NotificationService] Timezone set to $timezoneName');
    } catch (e) {
      // Fall back to UTC — notifications will still fire, just relative to UTC.
      tz.setLocalLocation(tz.getLocation('UTC'));
      debugPrint('[NotificationService] initTimezone fallback to UTC: $e');
    }
  }

  // -------------------------------------------------------- permissions ----

  static Future<bool> requestPermissions() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('requestPermissions error: $e');
    }
    return false;
  }

  // ----------------------------------------- zonedSchedule with fallback ----

  /// Tries to schedule with [alarmClock] mode (exact, no Doze delay).
  /// If the device rejects it (Android 12 without SCHEDULE_EXACT_ALARM), falls
  /// back to [inexact] so the notification still fires — no permission prompt.
  static Future<void> _zonedScheduleWithFallback(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDate,
    NotificationDetails details, {
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id, title, body, scheduledDate, details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (_) {
      // alarmClock mode failed (ExactAlarmPermissionException on Android 12).
      // USE_EXACT_ALARM in manifest auto-grants on API 33+, so this fallback
      // is only hit on API 31–32 without user-granted SCHEDULE_EXACT_ALARM.
      await _plugin.zonedSchedule(
        id, title, body, scheduledDate, details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    }
  }

  // -------------------------------------------------- exam notifications ----

  static const _examDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'breakcount_exams',
      'Exam Reminders',
      channelDescription: 'Upcoming exam notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  /// Schedules a 24-hour-before (08:00) and a 1-hour-before notification for
  /// [exam]. Silently skips any notification whose trigger time is in the past.
  static Future<void> scheduleExamNotification(Exam exam) async {
    if (!_initialized) return;
    try {
      final now = tz.TZDateTime.now(tz.local);
      final id24h = exam.id.hashCode.abs() % 500000000;
      final id1h = id24h + 500000000;

      // 24h before at 08:00 — use subtract so month/year boundaries are handled.
      final dayBefore = exam.date.subtract(const Duration(days: 1));
      final date24h = tz.TZDateTime(
        tz.local,
        dayBefore.year,
        dayBefore.month,
        dayBefore.day,
        8,
        0,
      );
      if (date24h.isAfter(now)) {
        await _zonedScheduleWithFallback(
          id24h,
          'Exam tomorrow',
          '${exam.title} \u00b7 ${exam.type.label}',
          date24h,
          _examDetails,
        );
      }

      // 1h before.
      final date1h = tz.TZDateTime.from(
        exam.date.subtract(const Duration(hours: 1)),
        tz.local,
      );
      if (date1h.isAfter(now)) {
        await _zonedScheduleWithFallback(
          id1h,
          'Exam in 1 hour',
          exam.title,
          date1h,
          _examDetails,
        );
      }
    } catch (e) {
      debugPrint('scheduleExamNotification error: $e');
    }
  }

  /// Cancels both scheduled exam notifications for [examId].
  static Future<void> cancelExamNotifications(String examId) async {
    if (!_initialized) return;
    try {
      final id24h = examId.hashCode.abs() % 500000000;
      final id1h = id24h + 500000000;
      await _plugin.cancel(id24h);
      await _plugin.cancel(id1h);
    } catch (e) {
      debugPrint('cancelExamNotifications error: $e');
    }
  }

  // ----------------------------------------------- FCM local display -------

  static const _announcementDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'breakcount_announcements',
      'Announcements',
      channelDescription: 'News and updates from BreakCount',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  /// Shows a local notification built from an FCM [RemoteMessage] received
  /// while the app is in the foreground.
  static Future<void> showFcmNotification(RemoteMessage message) async {
    if (!_initialized) return;
    try {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title'] as String? ?? 'BreakCount';
      final body = notification?.body ?? message.data['body'] as String? ?? '';
      final notifId = message.messageId?.hashCode.abs() ?? DateTime.now().millisecondsSinceEpoch % 2147483647;

      await _plugin.show(notifId, title, body, _announcementDetails);
    } catch (e) {
      debugPrint('showFcmNotification error: $e');
    }
  }

  // ---------------------------------------------------- reminder helpers ----

  static Future<void> scheduleReminder(Reminder reminder) async {
    if (!_initialized) return;
    try {
      final notifTime = reminder.notificationTime;
      if (notifTime.isBefore(DateTime.now())) return;

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'breakcount_reminders',
          'BreakCount Reminders',
          channelDescription: 'Reminders for tests, exams, and breaks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      final notifId = reminder.id.hashCode.abs() % 2147483647;

      final scheduledTime = tz.TZDateTime.from(notifTime, tz.local);
      await _zonedScheduleWithFallback(
        notifId,
        _titleFor(reminder),
        reminder.title,
        scheduledTime,
        details,
      );
    } catch (e) {
      debugPrint('scheduleReminder error: $e');
    }
  }

  /// Check and show any due reminders (call on app startup).
  static Future<void> checkDueReminders(List<Reminder> reminders) async {
    if (!_initialized) return;
    final now = DateTime.now();
    for (final reminder in reminders) {
      if (reminder.isCompleted) continue;
      final notifTime = reminder.notificationTime;
      // Show if due within the last 12 hours and not yet past the event.
      if (notifTime.isBefore(now) &&
          now.difference(notifTime).inHours < 12 &&
          reminder.eventDate.isAfter(now.subtract(const Duration(hours: 1)))) {
        await scheduleReminder(reminder);
      }
    }
  }

  static Future<void> cancelReminder(String reminderId) async {
    if (!_initialized) return;
    try {
      final notifId = reminderId.hashCode.abs() % 2147483647;
      await _plugin.cancel(notifId);
    } catch (e) {
      debugPrint('cancelReminder error: $e');
    }
  }

  static Future<void> cancelAll() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('cancelAll error: $e');
    }
  }

  /// Schedules a weekly recurring notification 10 min before a class.
  /// [dayOfWeek] is Dart's weekday (1=Mon, 7=Sun).
  static Future<void> scheduleClassNotification(
      String entryId, String subjectName, int dayOfWeek, int hour, int minute) async {
    if (!_initialized) return;
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'breakcount_reminders',
          'BreakCount Reminders',
          channelDescription: 'Reminders for tests, exams, and breaks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      );
      final notifId = (entryId.hashCode.abs() % 100000000) + 200000000;
      // Compute time 10 min before class
      int notifHour = hour;
      int notifMin = minute - 10;
      if (notifMin < 0) { notifMin += 60; notifHour -= 1; }
      if (notifHour < 0) return; // before midnight, skip

      final now = tz.TZDateTime.now(tz.local);
      // Find next occurrence of this weekday + time
      var dt = tz.TZDateTime(tz.local, now.year, now.month, now.day, notifHour, notifMin);
      // Advance until correct weekday and in future
      for (int i = 0; i < 8; i++) {
        if (dt.weekday == dayOfWeek && dt.isAfter(now)) break;
        dt = dt.add(const Duration(days: 1));
      }

      await _zonedScheduleWithFallback(
        notifId,
        subjectName,
        'Starting in 10 minutes',
        dt,
        details,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint('scheduleClassNotification error: $e');
    }
  }

  /// Cancels the weekly class notification for [entryId].
  static Future<void> cancelClassNotification(String entryId) async {
    if (!_initialized) return;
    try {
      final notifId = (entryId.hashCode.abs() % 100000000) + 200000000;
      await _plugin.cancel(notifId);
    } catch (e) {
      debugPrint('cancelClassNotification error: $e');
    }
  }

  /// Shows a notification immediately — use this to verify channels + permissions.
  static Future<String?> showInstantTestNotification() async {
    if (!_initialized) return 'NotificationService not initialized';
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'breakcount_reminders',
          'BreakCount Reminders',
          channelDescription: 'Reminders for tests, exams, and breaks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      );
      await _plugin.show(999999997, 'BreakCount Test', 'Notifications are working!', details);
      return null;
    } catch (e) {
      debugPrint('showInstantTestNotification error: $e');
      return e.toString();
    }
  }

  /// Schedules a one-off test notification [seconds] seconds from now.
  /// Returns an error string on failure, or null on success.
  static Future<String?> scheduleTestNotification(int seconds) async {
    if (!_initialized) return 'NotificationService not initialized';
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'breakcount_reminders',
          'BreakCount Reminders',
          channelDescription: 'Reminders for tests, exams, and breaks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      );
      final when = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
      await _zonedScheduleWithFallback(
        999999998,
        'BreakCount Test',
        'Notifications are working! (${seconds}s delay)',
        when,
        details,
      );
      return null;
    } catch (e) {
      debugPrint('scheduleTestNotification error: $e');
      return e.toString();
    }
  }

  // ------------------------------------------------- achievement unlock notif --

  static Future<void> showAchievementUnlocked(
      String name, String rarityLabel) async {
    if (!_initialized) return;
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'breakcount_achievements',
          'Achievements',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.show(
        700000000 + name.hashCode.abs() % 200000000,
        'Achievement Unlocked! 🏆',
        '$name — $rarityLabel',
        details,
      );
    } catch (e) {
      debugPrint('showAchievementUnlocked error: $e');
    }
  }

  static String _titleFor(Reminder reminder) {
    switch (reminder.type) {
      case ReminderType.exam:
        return 'Exam upcoming';
      case ReminderType.test:
        return 'Test reminder';
      case ReminderType.assignment:
        return 'Assignment due';
      case ReminderType.breakStarts:
        return 'Break starts soon!';
      case ReminderType.breakEnds:
        return 'Break ending soon';
      case ReminderType.custom:
        return 'BreakCount reminder';
    }
  }
}
