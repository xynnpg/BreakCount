import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/school_year.dart';
import '../app/constants.dart';
import '../data/local_school_data.dart';
import 'storage_service.dart';

class SchoolDataService {
  static const String _baseOpenHolidays = 'https://openholidaysapi.org';
  static const String _validFrom = '2025-08-01';
  static const String _validTo = '2026-07-31';

  /// Fetches data for [country], caches it, and returns the result.
  /// Priority: 1) Local bundled data  2) OpenHolidays API.
  static Future<SchoolYear?> fetchAndCache(String country) async {
    try {
      SchoolYear? result;

      // 1. Try local bundled data first (verified, offline-friendly)
      result = LocalSchoolData.forCountry(country);

      // 2. Fall back to OpenHolidays API for countries not bundled locally
      result ??= await _fetchFromOpenHolidays(country);

      if (result != null) {
        await StorageService.saveString(
            StorageKeys.schoolYear, result.toJsonString());
        await StorageService.saveString(
            StorageKeys.lastUpdated, DateTime.now().toIso8601String());
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Returns cached school year data, or null if nothing is cached.
  static SchoolYear? getCached() {
    try {
      final raw = StorageService.getString(StorageKeys.schoolYear);
      if (raw == null) return null;
      return SchoolYear.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  static DateTime? lastUpdated() {
    try {
      final raw = StorageService.getString(StorageKeys.lastUpdated);
      if (raw == null) return null;
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────

  static Future<SchoolYear?> _fetchFromOpenHolidays(String country) async {
    try {
      final iso = countryIso(country);
      final schoolHolidaysUrl = Uri.parse(
        '$_baseOpenHolidays/SchoolHolidays?countryIsoCode=$iso'
        '&validFrom=$_validFrom&validTo=$_validTo',
      );
      final response = await http
          .get(schoolHolidaysUrl, headers: {'accept': 'text/json'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as List;
      return _normalizeOpenHolidaysData(data, country);
    } catch (_) {
      return null;
    }
  }

  static SchoolYear _normalizeOpenHolidaysData(
      List data, String country) {
    final breaks = <SchoolBreak>[];
    int idx = 0;

    for (final item in data) {
      final map = item as Map<String, dynamic>;
      final start = _parseDate(map['startDate']);
      final end = _parseDate(map['endDate']);
      if (start == null || end == null) continue;

      // Extract English name or first available
      String name = 'Break ${idx + 1}';
      final names = map['name'] as List? ?? [];
      if (names.isNotEmpty) {
        final en = names.firstWhere(
          (n) => (n as Map)['language'] == 'EN',
          orElse: () => names.first,
        );
        name = (en as Map)['text'] as String? ?? name;
      }

      breaks.add(SchoolBreak(
        id: 'break_$idx',
        name: name,
        startDate: start,
        endDate: end,
      ));
      idx++;
    }

    breaks.sort((a, b) => a.startDate.compareTo(b.startDate));

    final yearStart = breaks.isNotEmpty
        ? DateTime(breaks.first.startDate.year, 8, 1)
        : DateTime(2025, 9, 1);
    final yearEnd = breaks.isNotEmpty
        ? DateTime(breaks.last.endDate.year, 7, 31)
        : DateTime(2026, 6, 30);

    final mid = yearStart
        .add(Duration(days: yearEnd.difference(yearStart).inDays ~/ 2));
    final semesters = [
      Semester(
          id: 'semester_0',
          name: 'Semester 1',
          startDate: yearStart,
          endDate: mid),
      Semester(
          id: 'semester_1',
          name: 'Semester 2',
          startDate: mid.add(const Duration(days: 1)),
          endDate: yearEnd),
    ];

    return SchoolYear(
      country: country,
      academicYear:
          '${yearStart.year}-${yearEnd.year}',
      startDate: yearStart,
      endDate: yearEnd,
      semesters: semesters,
      breaks: breaks,
      cachedAt: DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      final s = value.toString().substring(0, 10); // "YYYY-MM-DD"
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }
}
