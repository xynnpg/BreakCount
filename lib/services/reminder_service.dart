import '../models/reminder.dart';
import '../app/constants.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class ReminderService {
  static List<Reminder> getReminders() {
    try {
      final list = StorageService.getJsonList(StorageKeys.reminders);
      if (list == null) return [];
      return list
          .map((j) => Reminder.fromJson(j))
          .toList()
        ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    } catch (_) {
      return [];
    }
  }

  static List<Reminder> getUpcomingReminders() {
    return getReminders().where((r) => r.isUpcoming).toList();
  }

  static Future<void> addReminder(Reminder reminder) async {
    final reminders = getReminders();
    reminders.add(reminder);
    await _save(reminders);
    await NotificationService.scheduleReminder(reminder);
  }

  static Future<void> updateReminder(Reminder reminder) async {
    final reminders =
        getReminders().map((r) => r.id == reminder.id ? reminder : r).toList();
    await _save(reminders);
    await NotificationService.cancelReminder(reminder.id);
    if (!reminder.isCompleted && reminder.isUpcoming) {
      await NotificationService.scheduleReminder(reminder);
    }
  }

  static Future<void> deleteReminder(String id) async {
    final reminders = getReminders().where((r) => r.id != id).toList();
    await _save(reminders);
    await NotificationService.cancelReminder(id);
  }

  static Future<void> markCompleted(String id) async {
    final reminders = getReminders()
        .map((r) => r.id == id ? r.copyWith(isCompleted: true) : r)
        .toList();
    await _save(reminders);
    await NotificationService.cancelReminder(id);
  }

  static Future<void> clearAll() async {
    await StorageService.delete(StorageKeys.reminders);
    await NotificationService.cancelAll();
  }

  static Future<void> _save(List<Reminder> reminders) async {
    await StorageService.saveJsonList(
        StorageKeys.reminders, reminders.map((r) => r.toJson()).toList());
  }
}
