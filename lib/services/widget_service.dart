import 'package:home_widget/home_widget.dart';

import '../app/constants.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../models/school_year.dart';
import 'school_data_service.dart';
import 'schedule_service.dart';
import 'storage_service.dart';

/// Pushes current app state into Android home screen widgets.
/// All methods are fire-and-forget safe — never throws to callers.
class WidgetService {
  static const String _appGroupId = 'com.breakcount.app';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Recalculates all widget data and triggers a redraw of every provider.
  static Future<void> update() async {
    try {
      HomeWidget.setAppGroupId(_appGroupId);

      final SchoolYear? sy = SchoolDataService.getCached();

      // ── Break / year data ─────────────────────────────────────────────────
      int daysUntilBreak = -1;
      String nextBreakName = '';
      int yearProgress = 0;
      int daysUntilSummer = -1;
      bool isOnBreak = false;

      if (sy != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Year progress (0–100 int)
        yearProgress = (sy.yearProgress * 100).round().clamp(0, 100);

        // Days to summer / year end
        final summerDiff = sy.endDate.difference(today).inDays;
        daysUntilSummer = summerDiff.clamp(-1, 9999);

        // Next break
        final nb = sy.nextBreak;
        if (nb != null) {
          if (nb.isActive) {
            isOnBreak = true;
            nextBreakName = nb.name;
            daysUntilBreak = 0;
          } else {
            isOnBreak = false;
            nextBreakName = nb.name;
            daysUntilBreak = nb.startDate.difference(today).inDays;
          }
        }
      }

      // ── Schedule / class data ─────────────────────────────────────────────
      String? currentClass;
      String? currentClassTime;
      String? nextClass;
      String? nextClassTime;

      try {
        final schedule = ScheduleService.getSchedule();
        final subjects = ScheduleService.getSubjects();
        if (schedule.entries.isNotEmpty && subjects.isNotEmpty) {
          final out = <String, String?>{};
          _getCurrentAndNextClass(schedule, subjects, out);
          currentClass = out['current_class'];
          currentClassTime = out['current_class_time'];
          nextClass = out['next_class'];
          nextClassTime = out['next_class_time'];
        }
      } catch (_) {
        // schedule parse failure — leave nulls
      }

      // ── Save to HomeWidget SharedPreferences ──────────────────────────────
      await HomeWidget.saveWidgetData<int>('days_until_break', daysUntilBreak);
      await HomeWidget.saveWidgetData<String>('next_break_name', nextBreakName);
      await HomeWidget.saveWidgetData<int>('year_progress', yearProgress);
      await HomeWidget.saveWidgetData<int>('days_until_summer', daysUntilSummer);
      await HomeWidget.saveWidgetData<bool>('is_on_break', isOnBreak);
      await HomeWidget.saveWidgetData<String?>('current_class', currentClass);
      await HomeWidget.saveWidgetData<String?>('current_class_time', currentClassTime);
      await HomeWidget.saveWidgetData<String?>('next_class', nextClass);
      await HomeWidget.saveWidgetData<String?>('next_class_time', nextClassTime);

      // ── Trigger redraws ───────────────────────────────────────────────────
      await HomeWidget.updateWidget(
          androidName: 'BreakCountWidget2x1Provider');
      await HomeWidget.updateWidget(
          androidName: 'BreakCountWidget2x2Provider');
      await HomeWidget.updateWidget(
          androidName: 'BreakCountWidget4x1Provider');
      await HomeWidget.updateWidget(
          androidName: 'BreakCountWidget4x2Provider');
    } catch (_) {
      // Never propagate — widget updates are non-critical
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Resolves current week type from storage (same logic as ScheduleTab).
  static WeekType _currentWeekType() {
    try {
      final raw = StorageService.getString(StorageKeys.currentWeekType);
      if (raw == null) return WeekType.a;
      return WeekTypeExt.fromString(raw);
    } catch (_) {
      return WeekType.a;
    }
  }

  /// Finds the active class and the next upcoming class for today.
  /// Results are written into [out] using keys:
  ///   current_class, current_class_time, next_class, next_class_time
  static void _getCurrentAndNextClass(
    Schedule schedule,
    List<Subject> subjects,
    Map<String, String?> out,
  ) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1=Mon … 7=Sun
    final weekType = _currentWeekType();

    // Only weekdays have school entries
    if (todayWeekday > 5) return;

    final todayEntries = schedule.entriesForDay(todayWeekday, weekType);
    if (todayEntries.isEmpty) return;

    final nowMinutes = now.hour * 60 + now.minute;

    ScheduleEntry? current;
    ScheduleEntry? next;

    for (final entry in todayEntries) {
      final start = entry.startTime.hour * 60 + entry.startTime.minute;
      final end = entry.endTime.hour * 60 + entry.endTime.minute;

      if (start <= nowMinutes && nowMinutes < end) {
        current = entry;
      } else if (start > nowMinutes && next == null) {
        next = entry;
      }
    }

    Subject? subjectFor(String id) {
      try {
        return subjects.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }

    if (current != null) {
      final sub = subjectFor(current.subjectId);
      out['current_class'] = sub?.name;
      out['current_class_time'] =
          '${current.startTime.format24h()} – ${current.endTime.format24h()}';
    }

    if (next != null) {
      final sub = subjectFor(next.subjectId);
      out['next_class'] = sub?.name;
      out['next_class_time'] =
          '${next.startTime.format24h()} – ${next.endTime.format24h()}';
    }
  }
}
