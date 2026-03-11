import 'package:flutter/foundation.dart' show ValueNotifier;

import '../models/schedule.dart';
import '../models/subject.dart';
import '../app/constants.dart';
import 'storage_service.dart';

class ScheduleService {
  /// Notifies listeners whenever the schedule is replaced externally
  /// (e.g. P2P share). ScheduleTab listens to this to reload.
  static final scheduleRefresh = ValueNotifier<int>(0);
  static Schedule getSchedule() {
    try {
      final raw = StorageService.getString(StorageKeys.schedule);
      if (raw == null) return const Schedule.empty();
      return Schedule.fromJsonString(raw);
    } catch (_) {
      return const Schedule.empty();
    }
  }

  static List<Subject> getSubjects() {
    try {
      final list = StorageService.getJsonList(_subjectsKey);
      if (list == null) return [];
      return list.map((j) => Subject.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addEntry(ScheduleEntry entry) async {
    final schedule = getSchedule();
    final updated = schedule.copyWith(
      entries: [...schedule.entries, entry],
    );
    await StorageService.saveString(StorageKeys.schedule, updated.toJsonString());
  }

  static Future<void> updateEntry(ScheduleEntry entry) async {
    final schedule = getSchedule();
    final entries = schedule.entries.map((e) => e.id == entry.id ? entry : e).toList();
    final updated = schedule.copyWith(entries: entries);
    await StorageService.saveString(StorageKeys.schedule, updated.toJsonString());
  }

  static Future<void> deleteEntry(String id) async {
    final schedule = getSchedule();
    final entries = schedule.entries.where((e) => e.id != id).toList();
    final updated = schedule.copyWith(entries: entries);
    await StorageService.saveString(StorageKeys.schedule, updated.toJsonString());
  }

  static Future<void> setAlternatingWeeks(bool enabled) async {
    final schedule = getSchedule();
    final updated = schedule.copyWith(useAlternatingWeeks: enabled);
    await StorageService.saveString(StorageKeys.schedule, updated.toJsonString());
  }

  static Future<void> addSubject(Subject subject) async {
    final subjects = getSubjects();
    subjects.add(subject);
    await StorageService.saveJsonList(
        _subjectsKey, subjects.map((s) => s.toJson()).toList());
  }

  static Future<void> updateSubject(Subject subject) async {
    final subjects =
        getSubjects().map((s) => s.id == subject.id ? subject : s).toList();
    await StorageService.saveJsonList(
        _subjectsKey, subjects.map((s) => s.toJson()).toList());
  }

  static Future<void> deleteSubject(String id) async {
    final subjects = getSubjects().where((s) => s.id != id).toList();
    await StorageService.saveJsonList(
        _subjectsKey, subjects.map((s) => s.toJson()).toList());

    // Also remove schedule entries for this subject
    final schedule = getSchedule();
    final entries =
        schedule.entries.where((e) => e.subjectId != id).toList();
    await StorageService.saveString(
        StorageKeys.schedule, schedule.copyWith(entries: entries).toJsonString());
  }

  static Future<void> clearAll() async {
    await StorageService.delete(StorageKeys.schedule);
    await StorageService.delete(_subjectsKey);
  }

  static Subject? subjectById(String id) {
    try {
      return getSubjects().firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Overwrites both the schedule and subjects in storage atomically.
  /// Call [clearAll] first if you want a full replacement.
  static Future<void> saveFullSchedule(
    Schedule schedule,
    List<Subject> subjects,
  ) async {
    await StorageService.saveString(
      StorageKeys.schedule,
      schedule.toJsonString(),
    );
    await StorageService.saveJsonList(
      _subjectsKey,
      subjects.map((s) => s.toJson()).toList(),
    );
    scheduleRefresh.value++;
  }

  static const String _subjectsKey = 'subjects_data';
}
