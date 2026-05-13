import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:breakcount/app/constants.dart';
import 'package:breakcount/services/live_activity_service.dart';
import 'package:breakcount/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.breakcount/live_activity');
  final log = <MethodCall>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      log.add(call);
      switch (call.method) {
        case 'isAvailable':
          return true;
        case 'start':
          return true;
        case 'stop':
          return true;
        case 'isRunning':
          return false;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('start() invokes platform method and persists state', () async {
    final ok = await LiveActivityService.start();
    expect(ok, true);
    expect(log.last.method, 'start');
    expect(StorageService.getBool(StorageKeys.liveActivityEnabled), true);
  });

  test('stop() invokes platform method and clears state', () async {
    await LiveActivityService.start();
    await LiveActivityService.stop();
    expect(log.last.method, 'stop');
    expect(StorageService.getBool(StorageKeys.liveActivityEnabled), false);
  });

  test('isAvailable() returns platform response', () async {
    final available = await LiveActivityService.isAvailable();
    expect(available, true);
    expect(log.last.method, 'isAvailable');
  });
}
