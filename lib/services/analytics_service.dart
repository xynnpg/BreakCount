import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static FirebaseAnalytics get _fa => FirebaseAnalytics.instance;

  // ── Navigation ────────────────────────────────────────────────────────────

  static Future<void> tabSwitched(int index) async {
    const names = ['countdown', 'schedule', 'exams', 'settings'];
    await _log('tab_switched', {'tab': names[index.clamp(0, 3)]});
  }

  // ── Exams ─────────────────────────────────────────────────────────────────

  static Future<void> examAdded(String type) async =>
      _log('exam_added', {'type': type});

  static Future<void> examDeleted() async => _log('exam_deleted');

  // ── AI Schedule ───────────────────────────────────────────────────────────

  static Future<void> aiScanStarted(String provider) async =>
      _log('ai_scan_started', {'provider': provider});

  static Future<void> aiScanSuccess(int entryCount) async =>
      _log('ai_scan_success', {'entry_count': entryCount});

  static Future<void> aiScanFailed(String reason) async =>
      _log('ai_scan_failed', {'reason': reason});

  // ── P2P Share ─────────────────────────────────────────────────────────────

  static Future<void> scheduleShared() async => _log('schedule_shared');

  static Future<void> scheduleReceived() async => _log('schedule_received');

  // ── Settings ──────────────────────────────────────────────────────────────

  static Future<void> themeChanged(String themeId) async =>
      _log('theme_changed', {'theme': themeId});

  static Future<void> countrySelected(String country) async =>
      _log('country_selected', {'country': country});

  // ── Internal ──────────────────────────────────────────────────────────────

  static Future<void> _log(String name,
      [Map<String, Object>? params]) async {
    try {
      // Disable analytics in debug so test events don't pollute production data.
      if (kDebugMode) {
        debugPrint('[Analytics] $name ${params ?? ''}');
        return;
      }
      await _fa.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('[Analytics] error logging $name: $e');
    }
  }
}
