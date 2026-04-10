import 'dart:async';
import 'dart:convert';
import '../data/achievements_data.dart';
import '../models/school_year.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

/// Persisted achievement record.
class AchievementUnlock {
  final String id;
  final DateTime unlockedAt;
  const AchievementUnlock({required this.id, required this.unlockedAt});

  Map<String, dynamic> toJson() =>
      {'id': id, 'at': unlockedAt.toIso8601String()};

  factory AchievementUnlock.fromJson(Map<String, dynamic> j) =>
      AchievementUnlock(
          id: j['id'] as String,
          unlockedAt: DateTime.parse(j['at'] as String));
}

/// Manages unlocking, persisting and querying achievements.
class AchievementService {
  static const String _key = 'achievements_v1';
  static const String _countsKey = 'achievement_counts_v1';
  static const String _installKey = 'install_date_v1';
  static const String _appOpenCountKey = 'app_open_count_v1';

  // In-memory cache
  static List<AchievementUnlock> _unlocked = [];
  static Map<String, int> _counts = {};
  static bool _loaded = false;

  static void init() {
    if (_loaded) return;
    _loaded = true;
    _loadFromStorage();
    _recordInstallDate();
  }

  static void _loadFromStorage() {
    final raw = StorageService.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _unlocked = list
            .map((e) => AchievementUnlock.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _unlocked = [];
      }
    }
    final countsRaw = StorageService.getString(_countsKey);
    if (countsRaw != null) {
      try {
        final map = jsonDecode(countsRaw) as Map<String, dynamic>;
        _counts = map.map((k, v) => MapEntry(k, v as int));
      } catch (_) {
        _counts = {};
      }
    }
  }

  static void _recordInstallDate() {
    if (StorageService.getString(_installKey) == null) {
      StorageService.saveString(_installKey, DateTime.now().toIso8601String());
    }
  }

  static Future<void> _save() async {
    await StorageService.saveString(
        _key, jsonEncode(_unlocked.map((u) => u.toJson()).toList()));
    await StorageService.saveString(_countsKey, jsonEncode(_counts));
  }

  /// Returns true if the achievement with [id] is already unlocked.
  static bool isUnlocked(String id) => _unlocked.any((u) => u.id == id);

  /// Returns the unlock record for [id], or null.
  static AchievementUnlock? getUnlock(String id) {
    try {
      return _unlocked.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// All unlock records.
  static List<AchievementUnlock> get allUnlocks => List.unmodifiable(_unlocked);

  /// Current count for a count-based achievement.
  static int getCount(String id) => _counts[id] ?? 0;

  /// Unlocks [id] if not already unlocked. Returns true if newly unlocked.
  static Future<bool> unlock(String id) async {
    if (isUnlocked(id)) return false;
    _unlocked.add(AchievementUnlock(id: id, unlockedAt: DateTime.now()));
    await _save();
    try {
      final ach = kAchievements.firstWhere((a) => a.id == id);
      unawaited(NotificationService.showAchievementUnlocked(
          ach.name, ach.rarity.label));
    } catch (_) {}
    return true;
  }

  /// Increments counter for [id] and unlocks when [goal] is reached.
  /// Returns true if this increment triggered an unlock.
  static Future<bool> increment(String id, {required int goal}) async {
    final prev = _counts[id] ?? 0;
    _counts[id] = prev + 1;
    await _save();
    if (_counts[id]! >= goal && !isUnlocked(id)) {
      return unlock(id);
    }
    return false;
  }

  /// Record an app open and check power-user achievements.
  static Future<List<String>> recordAppOpen() async {
    final openCount = (_counts[_appOpenCountKey] ?? 0) + 1;
    _counts[_appOpenCountKey] = openCount;
    await _save();

    final List<String> newlyUnlocked = [];
    final hour = DateTime.now().hour;

    // Night Owl: opened between 1am–4am
    if (hour >= 1 && hour < 4 && !isUnlocked('night_owl')) {
      if (await unlock('night_owl')) newlyUnlocked.add('night_owl');
    }
    // Speed Run: opened 10+ times in one day
    final todayKey = 'opens_${DateTime.now().toIso8601String().substring(0, 10)}';
    final todayCount = (_counts[todayKey] ?? 0) + 1;
    _counts[todayKey] = todayCount;
    if (todayCount >= 10 && !isUnlocked('speed_run')) {
      if (await unlock('speed_run')) newlyUnlocked.add('speed_run');
    }
    // Old Guard: installed 6+ months ago
    final installRaw = StorageService.getString(_installKey);
    if (installRaw != null) {
      final installDate = DateTime.tryParse(installRaw);
      if (installDate != null &&
          DateTime.now().difference(installDate).inDays >= 183 &&
          !isUnlocked('old_guard')) {
        if (await unlock('old_guard')) newlyUnlocked.add('old_guard');
      }
    }
    await _save();
    return newlyUnlocked;
  }

  /// Check school-year-based achievements given current [schoolYear].
  static Future<List<String>> checkSchoolProgress(SchoolYear schoolYear) async {
    final List<String> newlyUnlocked = [];
    final progress = schoolYear.yearProgress;
    final now = DateTime.now();
    final schoolStarted = now.isAfter(schoolYear.startDate);

    if (schoolStarted && !isUnlocked('first_day')) {
      if (await unlock('first_day')) newlyUnlocked.add('first_day');
    }
    if (progress >= 0.5 && !isUnlocked('halfway')) {
      if (await unlock('halfway')) newlyUnlocked.add('halfway');
    }
    if (progress >= 0.75 && !isUnlocked('three_quarters')) {
      if (await unlock('three_quarters')) newlyUnlocked.add('three_quarters');
    }
    if (progress >= 1.0 && !isUnlocked('year_legend')) {
      if (await unlock('year_legend')) newlyUnlocked.add('year_legend');
    }

    // Summer Starts Now
    final summer = schoolYear.breaks
        .where((b) => b.name.toLowerCase().contains('summer'))
        .toList();
    if (summer.isNotEmpty) {
      final summerStart = summer.first.startDate;
      final onSummerDay = now.year == summerStart.year &&
          now.month == summerStart.month &&
          now.day == summerStart.day;
      if (onSummerDay && !isUnlocked('summer_now')) {
        if (await unlock('summer_now')) newlyUnlocked.add('summer_now');
      }
    }

    // Monday club
    final onABreak = schoolYear.breaks.any(
      (b) => !now.isBefore(b.startDate) && !now.isAfter(b.endDate),
    );
    final isMondaySchoolDay =
        now.weekday == DateTime.monday && schoolStarted && !onABreak;
    if (isMondaySchoolDay) {
      final prevCount = _counts['monday_count'] ?? 0;
      // Only count once per Monday
      final lastMondayKey = 'last_monday';
      final lastStr = StorageService.getString(lastMondayKey);
      final lastMonday = lastStr != null ? DateTime.tryParse(lastStr) : null;
      final isNewMonday = lastMonday == null ||
          now.difference(lastMonday).inDays >= 7;
      if (isNewMonday) {
        await StorageService.saveString(lastMondayKey, now.toIso8601String());
        _counts['monday_count'] = prevCount + 1;
        await _save();
        final count = _counts['monday_count']!;

        if (count == 1 && !isUnlocked('first_monday')) {
          if (await unlock('first_monday')) newlyUnlocked.add('first_monday');
        }
        if (count >= 10 && !isUnlocked('10_mondays')) {
          if (await unlock('10_mondays')) newlyUnlocked.add('10_mondays');
        }
        if (count >= 25 && !isUnlocked('25_mondays')) {
          if (await unlock('25_mondays')) newlyUnlocked.add('25_mondays');
        }
        if (count >= 50 && !isUnlocked('50_mondays')) {
          if (await unlock('50_mondays')) newlyUnlocked.add('50_mondays');
        }
      }
    }

    // Break milestones
    final pastBreaks = schoolYear.breaks.where((b) => b.isPast).length;
    if (pastBreaks >= 1 && !isUnlocked('first_break')) {
      if (await unlock('first_break')) newlyUnlocked.add('first_break');
    }
    if (pastBreaks >= 4 && !isUnlocked('break_collector')) {
      if (await unlock('break_collector')) newlyUnlocked.add('break_collector');
    }

    // Vacation Speed Run: open on first day of summer break
    if (summer.isNotEmpty) {
      final s = summer.first;
      final onFirstDay = now.year == s.startDate.year &&
          now.month == s.startDate.month &&
          now.day == s.startDate.day;
      if (onFirstDay && !isUnlocked('vacation_speed_run')) {
        if (await unlock('vacation_speed_run')) {
          newlyUnlocked.add('vacation_speed_run');
        }
      }
    }

    return newlyUnlocked;
  }

  /// Call when an exam is added.
  static Future<List<String>> onExamAdded({required int totalExams}) async {
    final List<String> newlyUnlocked = [];
    if (!isUnlocked('first_exam')) {
      if (await unlock('first_exam')) newlyUnlocked.add('first_exam');
    }
    if (totalExams >= 5 && !isUnlocked('exam_veteran')) {
      if (await unlock('exam_veteran')) newlyUnlocked.add('exam_veteran');
    }
    if (totalExams >= 20 && !isUnlocked('exam_master')) {
      if (await unlock('exam_master')) newlyUnlocked.add('exam_master');
    }
    // All-Nighter: exam added between 11pm–4am
    final hour = DateTime.now().hour;
    if ((hour >= 23 || hour < 4) && !isUnlocked('all_nighter')) {
      if (await unlock('all_nighter')) newlyUnlocked.add('all_nighter');
    }
    return newlyUnlocked;
  }

  /// Call when AI scan is used.
  static Future<bool> onAiScan() => unlock('ai_wizard');

  /// Call when shake-to-share is triggered.
  static Future<bool> onShake() async {
    const id = 'shake_master';
    const goal = 3;
    final prev = _counts[id] ?? 0;
    _counts[id] = prev + 1;
    await _save();
    if (_counts[id]! >= goal && !isUnlocked(id)) {
      return unlock(id);
    }
    return false;
  }

  /// Call when schedule has at least one full week set.
  static Future<bool> onScheduleFullWeek() => unlock('fully_loaded');

  /// Call when an early class (before 8am) is found in schedule.
  static Future<bool> onEarlyClass() => unlock('early_bird');

  /// Returns rank label based on unlock count.
  static String getRank() {
    final count = _unlocked.length;
    if (count >= 20) return 'Legend';
    if (count >= 14) return 'Master';
    if (count >= 8) return 'Veteran';
    if (count >= 4) return 'Survivor';
    if (count >= 1) return 'Rookie';
    return 'Newcomer';
  }
}
