import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/services/achievement_service.dart';
import 'package:breakcount/services/storage_service.dart';
import 'package:breakcount/services/study_log_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (call) async => null,
      )
      ..setMockMethodCallHandler(
        const MethodChannel('com.breakcount.app/timezone'),
        (call) async => 'UTC',
      );
    await StorageService.init();
    await AchievementService.resetForTests();
    AchievementService.init();
    await StudyLogService.resetForTests();
  });

  test('logSession persists and aggregates', () async {
    await StudyLogService.logSession(
      subjectId: 'math',
      subjectName: 'Math',
      minutes: 30,
    );
    await StudyLogService.logSession(
      subjectId: 'eng',
      subjectName: 'English',
      minutes: 45,
    );
    expect(StudyLogService.totalSessions(), 2);
    expect(StudyLogService.totalMinutes(), 75);
    final weekly = StudyLogService.weeklyBreakdown();
    expect(weekly['Math'], 30);
    expect(weekly['English'], 45);
  });

  test('first study log unlocks first_study', () async {
    await StudyLogService.logSession(
      subjectId: 'math',
      subjectName: 'Math',
      minutes: 30,
    );
    expect(AchievementService.isUnlocked('first_study'), isTrue);
  });

  test('180+ minute session unlocks study_marathon', () async {
    await StudyLogService.logSession(
      subjectId: 'math',
      subjectName: 'Math',
      minutes: 180,
    );
    expect(AchievementService.isUnlocked('study_marathon'), isTrue);
  });
}
