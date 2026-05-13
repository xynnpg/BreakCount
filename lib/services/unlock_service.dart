import '../app/theme_preset.dart';
import '../data/personas_data.dart';
import 'achievement_service.dart';
import 'streak_service.dart';

/// Kind of unlock requirement.
enum UnlockKind { defaultUnlocked, streak, achievement }

/// Requirement spec — what must be true for an item to be unlocked.
class UnlockRequirement {
  final UnlockKind kind;

  /// Required streak days (for [UnlockKind.streak]).
  final int streakDays;

  /// Required achievement id (for [UnlockKind.achievement]).
  final String achievementId;

  const UnlockRequirement.defaultUnlocked()
      : kind = UnlockKind.defaultUnlocked,
        streakDays = 0,
        achievementId = '';

  const UnlockRequirement.streak(this.streakDays)
      : kind = UnlockKind.streak,
        achievementId = '';

  const UnlockRequirement.achievement(this.achievementId)
      : kind = UnlockKind.achievement,
        streakDays = 0;

  String humanHint() {
    switch (kind) {
      case UnlockKind.defaultUnlocked:
        return 'Unlocked from the start.';
      case UnlockKind.streak:
        return 'Unlock at a $streakDays-day streak.';
      case UnlockKind.achievement:
        return 'Unlock via the "$achievementId" achievement.';
    }
  }
}

/// Central registry of theme + persona unlock rules. Used by the Settings
/// theme picker and Vibe persona gallery to render locked state with hints,
/// and by the rest of the app to gate `setTheme`/`setPersona` calls.
class UnlockService {
  // ── Theme unlock map ─────────────────────────────────────────────────────
  static const Map<String, UnlockRequirement> _themeRequirements = {
    'coffee': UnlockRequirement.defaultUnlocked(),
    'midnight': UnlockRequirement.defaultUnlocked(),
    'mint': UnlockRequirement.defaultUnlocked(),
    'sakura': UnlockRequirement.defaultUnlocked(),
    'ocean': UnlockRequirement.defaultUnlocked(),
    'sunset': UnlockRequirement.defaultUnlocked(),
    'lavender': UnlockRequirement.streak(7),
    'forest': UnlockRequirement.streak(14),
    'aurora': UnlockRequirement.streak(30),
    'paper': UnlockRequirement.streak(50),
    'cosmic': UnlockRequirement.streak(75),
    'neon': UnlockRequirement.streak(100),
    'amoled': UnlockRequirement.streak(150),
    'vapor': UnlockRequirement.streak(200),
    'solarized': UnlockRequirement.streak(365),
    'zen': UnlockRequirement.achievement('all_seasonal_breaks'),
    'mono': UnlockRequirement.achievement('achievement_hunter_50'),
  };

  /// Persona unlock map. Default-unlocked personas don't appear in the map
  /// (implicit). Only locked ones here — each locked persona states its
  /// requirement.
  ///
  /// Defaults (always unlocked): hype, chill, dramatic, sarcastic.
  static const Map<String, UnlockRequirement> _personaRequirements = {
    // Legacy (pre-v2.1.0) unlockables — preserved so saved states don't break.
    'ghost': UnlockRequirement.achievement('50_mondays'),
    'sage': UnlockRequirement.achievement('old_guard'),
    'menace': UnlockRequirement.achievement('achievement_hunter_25'),
    'zen': UnlockRequirement.achievement('break_collector'),
    // v2.1.0 additions — mostly streak-based, a few achievement-gated.
    'nerd': UnlockRequirement.streak(3),
    'tired': UnlockRequirement.streak(7),
    'ice': UnlockRequirement.streak(14),
    'gremlin': UnlockRequirement.streak(21),
    'philosopher': UnlockRequirement.streak(30),
    'goblin': UnlockRequirement.streak(42),
    'cloud': UnlockRequirement.streak(50),
    'volcano': UnlockRequirement.streak(60),
    'sloth': UnlockRequirement.streak(75),
    'storm': UnlockRequirement.streak(90),
    'sprout': UnlockRequirement.streak(100),
    'moon': UnlockRequirement.streak(120),
    'star': UnlockRequirement.streak(150),
    'phoenix': UnlockRequirement.streak(200),
    'sunflower': UnlockRequirement.streak(250),
    'jester': UnlockRequirement.achievement('recap_regular'),
    'monk': UnlockRequirement.achievement('achievement_hunter_50'),
    'rebel': UnlockRequirement.achievement('mood_rollercoaster'),
    'hacker': UnlockRequirement.achievement('ai_wizard'),
    'chef': UnlockRequirement.achievement('fully_loaded'),
    'pirate': UnlockRequirement.achievement('networker'),
    'robot': UnlockRequirement.achievement('year_legend'),
  };

  // ── Public API ───────────────────────────────────────────────────────────

  /// Whether theme [id] is currently unlocked.
  static bool isThemeUnlocked(String id) =>
      _evaluate(_themeRequirements[id]);

  /// Whether persona [id] is currently unlocked.
  static bool isPersonaUnlocked(String id) {
    // Default-unlocked personas (no entry in map) are always unlocked.
    final req = _personaRequirements[id];
    if (req == null) return true;
    return _evaluate(req);
  }

  /// Human-readable unlock hint for theme [id].
  static String themeUnlockHint(String id) =>
      (_themeRequirements[id] ??
              const UnlockRequirement.defaultUnlocked())
          .humanHint();

  /// Human-readable unlock hint for persona [id].
  static String personaUnlockHint(String id) =>
      (_personaRequirements[id] ??
              const UnlockRequirement.defaultUnlocked())
          .humanHint();

  /// All unlocked theme ids.
  static List<String> unlockedThemeIds() =>
      ThemePreset.all.map((t) => t.id).where(isThemeUnlocked).toList();

  /// All unlocked persona ids.
  static List<String> unlockedPersonaIds() =>
      kPersonas.map((p) => p.id).where(isPersonaUnlocked).toList();

  /// Given a new streak / achievement event, returns theme + persona ids that
  /// flipped from locked to unlocked. Useful for surfacing overlays.
  static List<String> themesUnlockedByStreak(int streakDays) {
    return _themeRequirements.entries
        .where((e) =>
            e.value.kind == UnlockKind.streak &&
            e.value.streakDays == streakDays)
        .map((e) => e.key)
        .toList();
  }

  static List<String> personasUnlockedByStreak(int streakDays) {
    return _personaRequirements.entries
        .where((e) =>
            e.value.kind == UnlockKind.streak &&
            e.value.streakDays == streakDays)
        .map((e) => e.key)
        .toList();
  }

  static List<String> themesUnlockedByAchievement(String achievementId) {
    return _themeRequirements.entries
        .where((e) =>
            e.value.kind == UnlockKind.achievement &&
            e.value.achievementId == achievementId)
        .map((e) => e.key)
        .toList();
  }

  static List<String> personasUnlockedByAchievement(String achievementId) {
    return _personaRequirements.entries
        .where((e) =>
            e.value.kind == UnlockKind.achievement &&
            e.value.achievementId == achievementId)
        .map((e) => e.key)
        .toList();
  }

  // ── Internals ────────────────────────────────────────────────────────────

  static bool _evaluate(UnlockRequirement? req) {
    if (req == null) return true;
    switch (req.kind) {
      case UnlockKind.defaultUnlocked:
        return true;
      case UnlockKind.streak:
        return StreakService.currentStreak >= req.streakDays;
      case UnlockKind.achievement:
        return AchievementService.isUnlocked(req.achievementId);
    }
  }
}
