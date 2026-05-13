import 'dart:async';
import 'dart:convert';
import '../data/achievements_data.dart';
import '../models/school_year.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

/// Callback invoked after every successful unlock. Used by PersonaService
/// and WidgetService to react without a hard import cycle.
typedef UnlockListener = void Function(String id);

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
  static const String _lastDayOpenKey = 'last_day_open_iso';
  static const String _metIdsKey = 'met_anon_ids_v1';
  static const String _metPersonasKey = 'met_personas_v1';

  // In-memory cache
  static List<AchievementUnlock> _unlocked = [];
  static Map<String, int> _counts = {};
  static bool _loaded = false;

  // Broadcast stream for newly unlocked achievement ids — used across screens
  // to surface a persona-themed overlay without direct coupling.
  static final StreamController<String> _unlockCtrl =
      StreamController<String>.broadcast();
  static Stream<String> get unlockStream => _unlockCtrl.stream;

  // External listeners (e.g. PersonaService ladder checks, WidgetService push).
  static final List<UnlockListener> _listeners = [];
  static void addUnlockListener(UnlockListener listener) {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  static void removeUnlockListener(UnlockListener listener) {
    _listeners.remove(listener);
  }

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

  /// Directly sets the count for [id]. Used by XpService for bonus XP and
  /// by tests. Does not trigger an unlock — use [increment] for that.
  static Future<void> setCount(String id, int value) async {
    _counts[id] = value;
    await _save();
  }

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
    // Broadcast and notify external listeners (persona ladder, widget refresh).
    if (!_unlockCtrl.isClosed) _unlockCtrl.add(id);
    for (final l in List<UnlockListener>.from(_listeners)) {
      try {
        l(id);
      } catch (_) {}
    }
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

        // all_mondays: survived every Monday from schoolYear.startDate to endDate.
        final totalMondays =
            _countMondaysBetween(schoolYear.startDate, schoolYear.endDate);
        if (totalMondays > 0 &&
            count >= totalMondays &&
            !isUnlocked('all_mondays')) {
          if (await unlock('all_mondays')) newlyUnlocked.add('all_mondays');
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

  /// Records a single "day opened" event. Dedupes per calendar day — repeated
  /// calls within the same day are no-ops.
  ///
  /// Increments the `one_month` counter (goal 30) once per unique day and
  /// returns any newly unlocked achievement ids.
  static Future<List<String>> recordDayOpen() async {
    final today = _isoDateOnly(DateTime.now());
    final last = StorageService.getString(_lastDayOpenKey);
    if (last == today) return const [];
    await StorageService.saveString(_lastDayOpenKey, today);
    final List<String> newly = [];
    final crossed = await increment('one_month', goal: 30);
    if (crossed) newly.add('one_month');
    return newly;
  }

  /// Inspect the mood history (via [fireStreak], [deadStreak], [rollercoaster])
  /// and unlock mood-streak achievements. Returns newly unlocked ids.
  ///
  /// Values are passed in so this file does not depend on MoodService and the
  /// dependency graph stays unidirectional.
  static Future<List<String>> checkMoodAchievements({
    required int fireStreak,
    required int deadStreak,
    required bool rollercoaster,
  }) async {
    final List<String> newly = [];

    Future<void> checkCount(String id, int currentValue, int goal) async {
      _counts[id] = currentValue;
      if (currentValue >= goal && !isUnlocked(id)) {
        if (await unlock(id)) newly.add(id);
      }
    }

    await checkCount('on_fire_7', fireStreak, 7);
    await checkCount('on_fire_30', fireStreak, 30);
    await checkCount('on_fire_100', fireStreak, 100);
    if (deadStreak >= 3 && !isUnlocked('hell_week')) {
      if (await unlock('hell_week')) newly.add('hell_week');
    }
    if (rollercoaster && !isUnlocked('mood_rollercoaster')) {
      if (await unlock('mood_rollercoaster')) newly.add('mood_rollercoaster');
    }
    await _save();
    return newly;
  }

  /// Called when this device successfully sends its schedule to a peer via
  /// mesh. Drives Echo/Mentor/Teacher ladder.
  static Future<List<String>> onScheduleShared() async {
    final List<String> newly = [];
    if (!isUnlocked('echo')) {
      if (await unlock('echo')) newly.add('echo');
    }
    if (await increment('mentor', goal: 3) && !_alreadyInList(newly, 'mentor')) {
      newly.add('mentor');
    }
    if (await increment('teacher', goal: 10) &&
        !_alreadyInList(newly, 'teacher')) {
      newly.add('teacher');
    }
    return newly;
  }

  // ── v2.1.0 helpers ──────────────────────────────────────────────────────

  /// Called whenever the daily streak advances. Unlocks streak_N milestones.
  static Future<List<String>> onStreakMilestone(int days) async {
    final newly = <String>[];
    const milestones = {
      3: 'streak_3',
      7: 'streak_7',
      14: 'streak_14',
      30: 'streak_30',
      50: 'streak_50',
      75: 'streak_75',
      100: 'streak_100',
      150: 'streak_150',
      200: 'streak_200',
      365: 'streak_365',
    };
    final id = milestones[days];
    if (id != null && !isUnlocked(id)) {
      if (await unlock(id)) newly.add(id);
    }
    return newly;
  }

  /// Called when a new theme gets unlocked. Ticks the theme-collector ladder.
  static Future<List<String>> onThemeUnlocked(int totalUnlockedThemes,
      {int totalThemes = 17}) async {
    final newly = <String>[];
    Future<void> tick(String id, int goal) async {
      if (totalUnlockedThemes >= goal && !isUnlocked(id)) {
        if (await unlock(id)) newly.add(id);
      }
    }

    await tick('theme_explorer', 3);
    await tick('theme_collector', 6);
    await tick('theme_curator', 10);
    if (totalUnlockedThemes >= totalThemes && !isUnlocked('theme_master')) {
      if (await unlock('theme_master')) newly.add('theme_master');
    }
    return newly;
  }

  /// Called when a new persona gets unlocked. Ticks the persona-collector
  /// ladder.
  static Future<List<String>> onPersonaUnlocked(
      int totalUnlockedPersonas) async {
    final newly = <String>[];
    Future<void> tick(String id, int goal) async {
      if (totalUnlockedPersonas >= goal && !isUnlocked(id)) {
        if (await unlock(id)) newly.add(id);
      }
    }

    await tick('persona_five', 5);
    await tick('persona_fifteen', 15);
    await tick('persona_all', 30);
    return newly;
  }

  /// Called when a study session is logged. Advances the study ladder and
  /// fires special "marathon" / "10h week" unlocks on qualifying sessions.
  static Future<List<String>> onStudySessionLogged({
    required int totalSessions,
    required int sessionMinutes,
    int weeklyMinutesAfterThis = 0,
  }) async {
    final newly = <String>[];
    if (!isUnlocked('first_study')) {
      if (await unlock('first_study')) newly.add('first_study');
    }
    Future<void> tick(String id, int goal) async {
      if (totalSessions >= goal && !isUnlocked(id)) {
        if (await unlock(id)) newly.add(id);
      }
    }

    await tick('study_10', 10);
    await tick('study_50', 50);
    await tick('study_100', 100);
    if (sessionMinutes >= 180 && !isUnlocked('study_marathon')) {
      if (await unlock('study_marathon')) newly.add('study_marathon');
    }
    if (weeklyMinutesAfterThis >= 600 && !isUnlocked('study_week_10h')) {
      if (await unlock('study_week_10h')) newly.add('study_week_10h');
    }
    return newly;
  }

  /// Called when a daily quest is completed.
  static Future<List<String>> onQuestCompleted({
    required int totalQuestsCompleted,
    bool allThreeTodayComplete = false,
  }) async {
    final newly = <String>[];
    if (!isUnlocked('quest_first')) {
      if (await unlock('quest_first')) newly.add('quest_first');
    }
    await setCount('quest_total', totalQuestsCompleted);
    Future<void> tick(String id, int goal) async {
      if (totalQuestsCompleted >= goal && !isUnlocked(id)) {
        if (await unlock(id)) newly.add(id);
      }
    }

    await tick('quest_10', 10);
    await tick('quest_50', 50);
    if (allThreeTodayComplete && !isUnlocked('quest_triple')) {
      if (await unlock('quest_triple')) newly.add('quest_triple');
    }
    return newly;
  }

  /// Called whenever the total unlock count might have crossed a ladder step.
  static Future<List<String>> onAchievementCountChanged() async {
    final newly = <String>[];
    final total = _unlocked.length;
    Future<void> tick(String id, int goal) async {
      if (total >= goal && !isUnlocked(id)) {
        if (await unlock(id)) newly.add(id);
      }
    }

    await tick('achievement_hunter_10', 10);
    await tick('achievement_hunter_25', 25);
    await tick('achievement_hunter_50', 50);
    await tick('achievement_hunter_75', 75);
    await tick('achievement_hunter_100', 100);
    return newly;
  }

  /// Called when a break matching [season] ({autumn, winter, spring, summer})
  /// is reached.
  static Future<List<String>> onBreakReached(String season) async {
    final newly = <String>[];
    const byId = {
      'autumn': 'survived_autumn',
      'winter': 'survived_winter',
      'spring': 'survived_spring',
      'summer': 'survived_summer',
    };
    final id = byId[season.toLowerCase()];
    if (id != null && !isUnlocked(id)) {
      if (await unlock(id)) newly.add(id);
    }
    const all = [
      'survived_autumn',
      'survived_winter',
      'survived_spring',
      'survived_summer',
    ];
    if (all.every(isUnlocked) && !isUnlocked('all_seasonal_breaks')) {
      if (await unlock('all_seasonal_breaks')) {
        newly.add('all_seasonal_breaks');
      }
    }
    return newly;
  }

  /// Called once every time the break-reveal animation plays.
  static Future<List<String>> onBreakReveal() async {
    final newly = <String>[];
    final crossed = await increment('break_reveal_10', goal: 10);
    if (crossed) newly.add('break_reveal_10');
    return newly;
  }

  /// Called when the XP level changes.
  static Future<List<String>> onLevelReached(int level) async {
    final newly = <String>[];
    if (level >= 5 && !isUnlocked('level_5')) {
      if (await unlock('level_5')) newly.add('level_5');
    }
    if (level >= 7 && !isUnlocked('level_7')) {
      if (await unlock('level_7')) newly.add('level_7');
    }
    if (level >= 10 && !isUnlocked('level_10')) {
      if (await unlock('level_10')) newly.add('level_10');
    }
    return newly;
  }

  /// Called when comparing achievements with a nearby peer.
  static Future<List<String>> onPeerCompare() async {
    final newly = <String>[];
    if (!isUnlocked('first_compare')) {
      if (await unlock('first_compare')) newly.add('first_compare');
    }
    final crossed = await increment('compare_5', goal: 5);
    if (crossed) newly.add('compare_5');
    return newly;
  }

  /// Called when a mesh peer is met. Dedupes by [anonId]. [peerPersona] drives
  /// pack / mirror / opposite detection; [myPersona] is the user's own.
  static Future<List<String>> onMeet({
    required String anonId,
    required String peerPersona,
    required String myPersona,
  }) async {
    final met = _readStringSet(_metIdsKey);
    if (met.contains(anonId)) return const [];
    met.add(anonId);
    await _writeStringSet(_metIdsKey, met);

    final personas = _readStringSet(_metPersonasKey);
    personas.add(peerPersona);
    await _writeStringSet(_metPersonasKey, personas);

    _counts['met_total'] = met.length;
    await _save();

    final List<String> newly = [];
    if (!isUnlocked('first_meet') && await unlock('first_meet')) {
      newly.add('first_meet');
    }
    if (met.length >= 3 && !isUnlocked('social_butterfly')) {
      if (await unlock('social_butterfly')) newly.add('social_butterfly');
    }
    if (met.length >= 10 && !isUnlocked('networker')) {
      if (await unlock('networker')) newly.add('networker');
    }
    const basePack = {'hype', 'chill', 'dramatic', 'sarcastic'};
    if (personas.containsAll(basePack) && !isUnlocked('met_the_pack')) {
      if (await unlock('met_the_pack')) newly.add('met_the_pack');
    }
    if (peerPersona == myPersona && !isUnlocked('mirror')) {
      if (await unlock('mirror')) newly.add('mirror');
    }
    const opposites = {
      'hype': 'chill',
      'chill': 'hype',
      'dramatic': 'sarcastic',
      'sarcastic': 'dramatic',
    };
    if (opposites[myPersona] == peerPersona &&
        !isUnlocked('opposites_attract')) {
      if (await unlock('opposites_attract')) newly.add('opposites_attract');
    }
    return newly;
  }

  /// Returns the set of anonIds this device has met (for tests/UI).
  static Set<String> get metAnonIds => _readStringSet(_metIdsKey);

  /// Returns the set of personas met (for tests/UI).
  static Set<String> get metPersonas => _readStringSet(_metPersonasKey);

  /// Returns rank label based on current XP level.
  /// Falls back to unlock-count heuristic if XpService is unavailable (never
  /// true at runtime, but keeps the lookup total).
  static String getRank() {
    // Inline-implement to avoid circular import of XpService.
    // XpService.rankName() reads allUnlocks + effectiveXp — we repro the math
    // here using the canonical thresholds.
    var xp = getCount('bonus_xp_v1');
    for (final u in _unlocked) {
      final ach = kAchievements.where((a) => a.id == u.id).firstOrNull;
      if (ach != null) xp += ach.effectiveXp;
    }
    const thresholds = [0, 200, 600, 1500, 3500, 7000, 12000, 20000, 35000, 60000];
    const names = [
      'Newcomer',
      'Rookie',
      'Survivor',
      'Veteran',
      'Master',
      'Legend',
      'Mythic',
      'Ascendant',
      'Transcendent',
      'Eternal',
    ];
    var level = 1;
    for (var i = 1; i < thresholds.length; i++) {
      if (xp >= thresholds[i]) level = i + 1;
    }
    if (xp > thresholds.last) {
      level = thresholds.length + ((xp - thresholds.last) ~/ 25000);
    }
    if (level <= 0) return names[0];
    return names[level > names.length ? names.length - 1 : level - 1];
  }

  // ── Internal helpers ────────────────────────────────────────────────────

  /// Returns YYYY-MM-DD representation of the calendar date, ignoring time.
  static String _isoDateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Counts how many Mondays fall in the inclusive range [start, end].
  static int _countMondaysBetween(DateTime start, DateTime end) {
    if (end.isBefore(start)) return 0;
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    var count = 0;
    for (var d = s;
        !d.isAfter(e);
        d = d.add(const Duration(days: 1))) {
      if (d.weekday == DateTime.monday) count++;
    }
    return count;
  }

  static bool _alreadyInList(List<String> list, String id) => list.contains(id);

  static Set<String> _readStringSet(String key) {
    final raw = StorageService.getString(key);
    if (raw == null) return <String>{};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as String).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> _writeStringSet(String key, Set<String> value) async {
    await StorageService.saveString(key, jsonEncode(value.toList()));
  }

  /// Test-only: resets all in-memory + persisted state. Not for production.
  static Future<void> resetForTests() async {
    _unlocked = [];
    _counts = {};
    _loaded = false;
    _listeners.clear();
    await StorageService.delete(_key);
    await StorageService.delete(_countsKey);
    await StorageService.delete(_installKey);
    await StorageService.delete(_lastDayOpenKey);
    await StorageService.delete(_metIdsKey);
    await StorageService.delete(_metPersonasKey);
  }
}
