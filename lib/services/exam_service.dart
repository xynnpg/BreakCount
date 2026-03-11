import 'dart:convert';
import '../models/exam.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../app/constants.dart';

class ExamService {
  static List<Exam> getExams() {
    final data = StorageService.getString(StorageKeys.exams);
    if (data == null || data.isEmpty) return [];
    try {
      final list = jsonDecode(data) as List;
      return list
          .map((e) => Exam.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveAll(List<Exam> exams) async {
    final data = jsonEncode(exams.map((e) => e.toJson()).toList());
    await StorageService.saveString(StorageKeys.exams, data);
  }

  static Future<void> addExam(Exam exam) async {
    final exams = getExams()..add(exam);
    await _saveAll(exams);
    await NotificationService.scheduleExamNotification(exam);
    AnalyticsService.examAdded(exam.type.name);
  }

  static Future<void> updateExam(Exam exam) async {
    final exams = getExams();
    final idx = exams.indexWhere((e) => e.id == exam.id);
    if (idx >= 0) exams[idx] = exam;
    await _saveAll(exams);
    await NotificationService.cancelExamNotifications(exam.id);
    await NotificationService.scheduleExamNotification(exam);
  }

  static Future<void> deleteExam(String id) async {
    await NotificationService.cancelExamNotifications(id);
    AnalyticsService.examDeleted();
    final exams = getExams()..removeWhere((e) => e.id == id);
    await _saveAll(exams);
  }

  /// Returns upcoming exams sorted nearest first (includes today).
  static List<Exam> getUpcoming() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    return getExams()
        .where((e) => e.date.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Returns past exams sorted most-recent first.
  static List<Exam> getPast() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    return getExams()
        .where((e) => e.date.isBefore(cutoff))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
