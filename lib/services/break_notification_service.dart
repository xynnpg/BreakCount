import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/school_year.dart';

/// Schedules "break starts tomorrow" and "back to school tomorrow" notifications
/// for all future breaks in the active school year.
///
/// Uses a separate [FlutterLocalNotificationsPlugin] instance but shares the
/// same native channel — this is a valid pattern per the plugin docs.
///
/// Notification ID ranges (safe, no collision with exam IDs 0–999,999,999):
///   Break start : 1,000,000,000 + (breakId.hashCode.abs() % 500,000,000)
///   Break end   : 1,500,000,000 + (breakId.hashCode.abs() % 499,999,999)
class BreakNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static const _breakDetails = NotificationDetails(
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

  static Future<void> init() async {
    if (_initialized) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
          const InitializationSettings(android: android, iOS: ios));
      _initialized = true;
    } catch (e) {
      debugPrint('BreakNotificationService.init error: $e');
    }
  }

  /// Cancels all previously scheduled break notifications, then re-schedules
  /// start and end reminders for every future break in [sy].
  static Future<void> scheduleBreakNotifications(SchoolYear sy) async {
    if (!_initialized) return;
    try {
      await _cancelAll(sy);

      final now = tz.TZDateTime.now(tz.local);

      for (final b in sy.breaks) {
        if (b.isPast) continue;

        final startId = 1000000000 + (b.id.hashCode.abs() % 500000000);
        final endId = 1500000000 + (b.id.hashCode.abs() % 499999999);

        // "Break starts tomorrow!" — 8:00 AM day before start
        final dayBeforeStart = b.startDate.subtract(const Duration(days: 1));
        final startNotifTime = tz.TZDateTime(
          tz.local,
          dayBeforeStart.year,
          dayBeforeStart.month,
          dayBeforeStart.day,
          8,
        );
        if (startNotifTime.isAfter(now)) {
          await _plugin.zonedSchedule(
            startId,
            'Break starts tomorrow!',
            b.name,
            startNotifTime,
            _breakDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }

        // "Back to school tomorrow!" — 8:00 AM day before end
        // Skip single-day breaks (startDate == endDate).
        if (b.startDate.isBefore(b.endDate)) {
          final dayBeforeEnd = b.endDate.subtract(const Duration(days: 1));
          final endNotifTime = tz.TZDateTime(
            tz.local,
            dayBeforeEnd.year,
            dayBeforeEnd.month,
            dayBeforeEnd.day,
            8,
          );
          if (endNotifTime.isAfter(now)) {
            await _plugin.zonedSchedule(
              endId,
              'Back to school tomorrow!',
              b.name,
              endNotifTime,
              _breakDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('BreakNotificationService.scheduleBreakNotifications error: $e');
    }
  }

  /// Cancels all break notifications for every break in [sy].
  static Future<void> cancelBreakNotifications(SchoolYear sy) async {
    if (!_initialized) return;
    try {
      await _cancelAll(sy);
    } catch (e) {
      debugPrint('BreakNotificationService.cancelBreakNotifications error: $e');
    }
  }

  static Future<void> _cancelAll(SchoolYear sy) async {
    for (final b in sy.breaks) {
      final startId = 1000000000 + (b.id.hashCode.abs() % 500000000);
      final endId = 1500000000 + (b.id.hashCode.abs() % 499999999);
      await _plugin.cancel(startId);
      await _plugin.cancel(endId);
    }
  }
}
