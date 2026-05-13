import '../data/achievements_data.dart';
import 'achievement_service.dart';

/// Computes XP totals, level, and rank from unlocked achievements.
///
/// Levels:
///   L1   0     Newcomer
///   L2   200   Rookie
///   L3   600   Survivor
///   L4   1500  Veteran
///   L5   3500  Master
///   L6   7000  Legend
///   L7   12000 Mythic
///   L8   20000 Ascendant
///   L9   35000 Transcendent
///   L10+ 60000 Eternal (every +25k levels up)
class XpService {
  static const List<int> _thresholds = [
    0, 200, 600, 1500, 3500, 7000, 12000, 20000, 35000, 60000,
  ];

  static const List<String> _rankNames = [
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

  static const int _extraLevelStep = 25000; // XP per post-L10 level

  /// Plus this XP counts as Task 7 quest rewards + manual grants. Persisted
  /// via AchievementService._counts under this id.
  static const String kBonusXpKey = 'bonus_xp_v1';

  /// Total XP from unlocked achievements + bonus.
  static int totalXp() {
    var total = AchievementService.getCount(kBonusXpKey);
    for (final unlock in AchievementService.allUnlocks) {
      final a = _findAchievement(unlock.id);
      if (a != null) total += a.effectiveXp;
    }
    return total;
  }

  /// Current level number (1-indexed).
  static int level() => _levelForXp(totalXp());

  /// Total XP required to reach [level].
  static int xpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    if (level <= _thresholds.length) return _thresholds[level - 1];
    // Past the array: each extra level is +25k.
    final overflow = level - _thresholds.length;
    return _thresholds.last + overflow * _extraLevelStep;
  }

  /// XP progress into the current level band (0..1).
  static double progress() {
    final xp = totalXp();
    final lvl = _levelForXp(xp);
    final floor = xpRequiredForLevel(lvl);
    final ceil = xpRequiredForLevel(lvl + 1);
    final span = ceil - floor;
    if (span <= 0) return 1.0;
    return ((xp - floor) / span).clamp(0.0, 1.0);
  }

  /// XP until the next level.
  static int xpToNextLevel() {
    final xp = totalXp();
    final lvl = _levelForXp(xp);
    final ceil = xpRequiredForLevel(lvl + 1);
    final diff = ceil - xp;
    return diff < 0 ? 0 : diff;
  }

  /// Rank label from current level.
  static String rankName() => rankNameForLevel(level());

  /// Rank label from a specific level.
  static String rankNameForLevel(int level) {
    if (level <= 0) return _rankNames[0];
    if (level <= _rankNames.length) return _rankNames[level - 1];
    return _rankNames.last;
  }

  /// Grants bonus XP (e.g., quest completion). Persisted as a count.
  static Future<void> grantBonusXp(int amount) async {
    if (amount <= 0) return;
    // Use increment with a goal we can never hit so it just ticks forward.
    // Technically this mirrors AchievementService.getCount / _save semantics.
    final current = AchievementService.getCount(kBonusXpKey);
    await AchievementService.setCount(kBonusXpKey, current + amount);
  }

  // ── Internals ────────────────────────────────────────────────────────────

  static int _levelForXp(int xp) {
    var level = 1;
    for (var i = 1; i < _thresholds.length; i++) {
      if (xp >= _thresholds[i]) {
        level = i + 1;
      } else {
        return level;
      }
    }
    // Past L10
    final extra = xp - _thresholds.last;
    if (extra <= 0) return _thresholds.length;
    return _thresholds.length + (extra ~/ _extraLevelStep);
  }

  static Achievement? _findAchievement(String id) {
    for (final a in kAchievements) {
      if (a.id == id) return a;
    }
    return null;
  }
}
