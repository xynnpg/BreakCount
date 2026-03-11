import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences.
/// Call [StorageService.init()] once at app startup.
class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    assert(_prefs != null, 'StorageService.init() must be called first');
    return _prefs!;
  }

  // ── String ────────────────────────────────────────────────────────────────

  static Future<void> saveString(String key, String value) async {
    try {
      await _instance.setString(key, value);
    } catch (_) {}
  }

  static String? getString(String key) {
    try {
      return _instance.getString(key);
    } catch (_) {
      return null;
    }
  }

  // ── Bool ──────────────────────────────────────────────────────────────────

  static Future<void> saveBool(String key, bool value) async {
    try {
      await _instance.setBool(key, value);
    } catch (_) {}
  }

  static bool? getBool(String key) {
    try {
      return _instance.getBool(key);
    } catch (_) {
      return null;
    }
  }

  // ── Int ───────────────────────────────────────────────────────────────────

  static Future<void> saveInt(String key, int value) async {
    try {
      await _instance.setInt(key, value);
    } catch (_) {}
  }

  static int? getInt(String key) {
    try {
      return _instance.getInt(key);
    } catch (_) {
      return null;
    }
  }

  // ── JSON Object ───────────────────────────────────────────────────────────

  static Future<void> saveJson(
      String key, Map<String, dynamic> value) async {
    try {
      await _instance.setString(key, jsonEncode(value));
    } catch (_) {}
  }

  static Map<String, dynamic>? getJson(String key) {
    try {
      final raw = _instance.getString(key);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── JSON List ─────────────────────────────────────────────────────────────

  static Future<void> saveJsonList(
      String key, List<Map<String, dynamic>> value) async {
    try {
      await _instance.setString(key, jsonEncode(value));
    } catch (_) {}
  }

  static List<Map<String, dynamic>>? getJsonList(String key) {
    try {
      final raw = _instance.getString(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  // ── Housekeeping ──────────────────────────────────────────────────────────

  static Future<void> delete(String key) async {
    try {
      await _instance.remove(key);
    } catch (_) {}
  }

  static Future<void> clearAll() async {
    try {
      await _instance.clear();
    } catch (_) {}
  }

  static bool containsKey(String key) {
    try {
      return _instance.containsKey(key);
    } catch (_) {
      return false;
    }
  }
}
