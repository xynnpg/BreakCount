import 'package:flutter/services.dart';

import '../app/constants.dart';
import 'storage_service.dart';

/// Controls the Android 14+ lock-screen countdown foreground service.
class LiveActivityService {
  static const _channel = MethodChannel('com.breakcount/live_activity');

  /// Whether the device supports the live activity (Android 14+).
  static Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Whether the service is currently running.
  static Future<bool> isRunning() async {
    try {
      return await _channel.invokeMethod<bool>('isRunning') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Starts the foreground countdown service. No-op on < Android 14.
  static Future<bool> start() async {
    try {
      final ok = await _channel.invokeMethod<bool>('start') ?? false;
      if (ok) await StorageService.saveBool(StorageKeys.liveActivityEnabled, true);
      return ok;
    } catch (_) {
      return false;
    }
  }

  /// Stops the foreground countdown service.
  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (_) {}
    await StorageService.saveBool(StorageKeys.liveActivityEnabled, false);
  }

  /// Returns the persisted toggle state.
  static bool get isEnabled =>
      StorageService.getBool(StorageKeys.liveActivityEnabled) ?? false;
}
