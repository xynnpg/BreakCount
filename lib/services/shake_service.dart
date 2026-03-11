import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Detects shake gestures via accelerometer.
///
/// Fires [onShake] only after the threshold has been exceeded continuously
/// for [_kHoldDuration] (1.5 s) with no gap longer than [_kMaxGap] (500 ms).
class ShakeService {
  static const double _kThreshold = 20.0;
  static const Duration _kHoldDuration = Duration(milliseconds: 1500);
  static const Duration _kMaxGap = Duration(milliseconds: 500);
  static const Duration _kCooldown = Duration(seconds: 3);

  final VoidCallback onShake;
  StreamSubscription<AccelerometerEvent>? _sub;

  DateTime? _shakeStart;
  DateTime? _lastEvent;
  DateTime _lastFired = DateTime(2000);

  ShakeService({required this.onShake});

  void start() {
    _sub = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen(_onEvent, onError: (_) {});
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _shakeStart = null;
    _lastEvent = null;
  }

  void _onEvent(AccelerometerEvent e) {
    final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    final now = DateTime.now();

    if (mag > _kThreshold) {
      if (_shakeStart == null) {
        // Start tracking
        _shakeStart = now;
        _lastEvent = now;
      } else if (now.difference(_lastEvent!) <= _kMaxGap) {
        // Still shaking
        _lastEvent = now;
        if (now.difference(_shakeStart!) >= _kHoldDuration &&
            now.difference(_lastFired) > _kCooldown) {
          _lastFired = now;
          _shakeStart = null;
          _lastEvent = null;
          onShake();
        }
      } else {
        // Gap was too long — reset
        _shakeStart = now;
        _lastEvent = now;
      }
    }
  }
}
