import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'achievement_service.dart';
import 'storage_service.dart';
import 'xp_service.dart';

/// A static quest template. [id] is stable — used by persistence so rotating
/// templates doesn't break ongoing progress.
class QuestTemplate {
  final String id;
  final String title;
  final String hint;
  final int goal;
  final int xp;
  final String icon;

  const QuestTemplate({
    required this.id,
    required this.title,
    required this.hint,
    required this.goal,
    required this.xp,
    required this.icon,
  });
}

/// Runtime snapshot of a quest — template + user progress.
class Quest {
  final QuestTemplate template;
  final int progress;

  const Quest({required this.template, required this.progress});

  String get id => template.id;
  bool get isComplete => progress >= template.goal;
  double get fraction =>
      template.goal == 0 ? 1.0 : (progress / template.goal).clamp(0.0, 1.0);
}

/// Daily quests — 3 per day, deterministically picked from a seeded rotation
/// so two devices on the same date see the same quests.
///
/// Storage layout (all under StorageService):
///   daily_quests_date          → ISO date of the currently active day.
///   daily_quests_progress      → JSON {questId: progress}
///   daily_quests_ids           → JSON `List<String>` today's 3 ids
///   quest_total_completed      → int lifetime completed count
class QuestService {
  static const String _dateKey = 'daily_quests_date';
  static const String _progressKey = 'daily_quests_progress';
  static const String _idsKey = 'daily_quests_ids';
  static const String _totalKey = 'quest_total_completed';

  /// Number of quests per day.
  static const int questsPerDay = 3;

  /// Notifier UI can listen to for refreshes on progress/completion/rollover.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static const List<QuestTemplate> templates = [
    QuestTemplate(
      id: 'q_check_countdown',
      title: 'Check the Countdown',
      hint: 'Open the Countdown tab',
      goal: 1,
      xp: 25,
      icon: '⏳',
    ),
    QuestTemplate(
      id: 'q_view_schedule',
      title: 'Peek at Your Schedule',
      hint: 'Open the Schedule tab',
      goal: 1,
      xp: 25,
      icon: '🗓️',
    ),
    QuestTemplate(
      id: 'q_view_exams',
      title: 'Review Exams',
      hint: 'Open the Exams tab',
      goal: 1,
      xp: 25,
      icon: '📝',
    ),
    QuestTemplate(
      id: 'q_open_settings',
      title: 'Tune Settings',
      hint: 'Open Settings',
      goal: 1,
      xp: 15,
      icon: '⚙️',
    ),
    QuestTemplate(
      id: 'q_tap_countdown',
      title: 'Cycle the Timer',
      hint: 'Tap the countdown 3 times',
      goal: 3,
      xp: 40,
      icon: '🔄',
    ),
    QuestTemplate(
      id: 'q_view_stats',
      title: 'Read the Stats',
      hint: 'Open the Stats screen',
      goal: 1,
      xp: 30,
      icon: '📊',
    ),
    QuestTemplate(
      id: 'q_view_achievements',
      title: 'Visit Achievements',
      hint: 'Open the Achievements screen',
      goal: 1,
      xp: 20,
      icon: '🏆',
    ),
    QuestTemplate(
      id: 'q_view_vibe',
      title: 'Check Your Vibe',
      hint: 'Open the Vibe screen',
      goal: 1,
      xp: 20,
      icon: '✨',
    ),
    QuestTemplate(
      id: 'q_change_persona',
      title: 'Swap Persona',
      hint: 'Change persona from the Vibe screen',
      goal: 1,
      xp: 50,
      icon: '🎭',
    ),
    QuestTemplate(
      id: 'q_change_theme',
      title: 'Rotate Theme',
      hint: 'Switch to any other theme',
      goal: 1,
      xp: 50,
      icon: '🎨',
    ),
    QuestTemplate(
      id: 'q_log_study',
      title: 'Log a Study Session',
      hint: 'Add a study session from Stats',
      goal: 1,
      xp: 80,
      icon: '📚',
    ),
    QuestTemplate(
      id: 'q_share_vibe_card',
      title: 'Share Your Vibe Card',
      hint: 'Tap the share kebab on your vibe',
      goal: 1,
      xp: 100,
      icon: '📤',
    ),
    QuestTemplate(
      id: 'q_share_schedule',
      title: 'Share Schedule',
      hint: 'Use shake-to-share or nearby-students',
      goal: 1,
      xp: 60,
      icon: '📡',
    ),
    QuestTemplate(
      id: 'q_view_nearby',
      title: 'Find Nearby Students',
      hint: 'Open Nearby Students',
      goal: 1,
      xp: 40,
      icon: '📍',
    ),
    QuestTemplate(
      id: 'q_3_app_opens',
      title: 'Three Visits',
      hint: 'Open the app 3 times today',
      goal: 3,
      xp: 30,
      icon: '🚪',
    ),
    QuestTemplate(
      id: 'q_add_exam',
      title: 'Plan an Exam',
      hint: 'Add or edit an exam',
      goal: 1,
      xp: 60,
      icon: '✏️',
    ),
    QuestTemplate(
      id: 'q_weekly_recap',
      title: 'Read the Recap',
      hint: 'Dismiss the weekly recap card',
      goal: 1,
      xp: 40,
      icon: '📖',
    ),
    QuestTemplate(
      id: 'q_check_mood',
      title: 'Log Your Mood',
      hint: 'Open the Vibe screen to record today\'s mood',
      goal: 1,
      xp: 25,
      icon: '🎯',
    ),
  ];

  /// Returns today's 3 quests. Rotates automatically on calendar-day change.
  static Future<List<Quest>> today({DateTime? now}) async {
    await _rollIfStale(now);
    final ids = _readIds();
    final progress = _readProgress();
    final out = <Quest>[];
    for (final id in ids) {
      final t = templates.where((t) => t.id == id).firstOrNull;
      if (t == null) continue;
      out.add(Quest(template: t, progress: progress[id] ?? 0));
    }
    return out;
  }

  /// Increments progress for [questId] by [delta]. Returns true if the quest
  /// flipped from incomplete to complete (triggering the XP reward + any
  /// achievement side-effects).
  static Future<bool> progress(
    String questId, {
    int delta = 1,
    DateTime? now,
  }) async {
    await _rollIfStale(now);
    final ids = _readIds();
    if (!ids.contains(questId)) return false; // not an active quest today
    final t = templates.where((t) => t.id == questId).firstOrNull;
    if (t == null) return false;
    final current = _readProgress();
    final prior = current[questId] ?? 0;
    if (prior >= t.goal) return false; // already complete
    final next = prior + delta;
    current[questId] = next;
    await StorageService.saveString(_progressKey, jsonEncode(current));
    revision.value++;
    if (next >= t.goal) {
      // Completion side-effects.
      await XpService.grantBonusXp(t.xp);
      final totalCompleted =
          (StorageService.getInt(_totalKey) ?? 0) + 1;
      await StorageService.saveInt(_totalKey, totalCompleted);

      // Check triple threat.
      final allComplete = ids.every((id) {
        final tt = templates.where((t) => t.id == id).firstOrNull;
        if (tt == null) return false;
        return (current[id] ?? 0) >= tt.goal;
      });

      await AchievementService.onQuestCompleted(
        totalQuestsCompleted: totalCompleted,
        allThreeTodayComplete: allComplete,
      );
      return true;
    }
    return false;
  }

  /// Convenience wrapper — called from places like CounterTab initState.
  static Future<void> tickQuest(String questId, {int delta = 1}) =>
      progress(questId, delta: delta);

  /// Total lifetime quests completed.
  static int totalCompleted() => StorageService.getInt(_totalKey) ?? 0;

  /// Test-only reset.
  @visibleForTesting
  static Future<void> resetForTests() async {
    revision.value = 0;
    await StorageService.delete(_dateKey);
    await StorageService.delete(_progressKey);
    await StorageService.delete(_idsKey);
    await StorageService.delete(_totalKey);
  }

  // ── Internals ────────────────────────────────────────────────────────────

  /// Ensures today's quest set matches the current calendar day. Rolls over
  /// at local midnight by picking a fresh triplet.
  static Future<void> _rollIfStale(DateTime? now) async {
    final n = now ?? DateTime.now();
    final today = _iso(n);
    final saved = StorageService.getString(_dateKey);
    if (saved == today && _readIds().length == questsPerDay) return;

    // New day — pick 3 deterministic ids from the template list.
    final ids = _pickIds(n);
    await StorageService.saveString(_dateKey, today);
    await StorageService.saveString(_idsKey, jsonEncode(ids));
    await StorageService.saveString(_progressKey, jsonEncode(<String, int>{}));
    revision.value++;
  }

  /// Deterministic 3-pick from templates using [now]'s date as seed.
  static List<String> _pickIds(DateTime now) {
    // Daysince epoch acts as our seed — same device+date always produces the
    // same triplet.
    final epoch = DateTime(now.year, now.month, now.day)
        .difference(DateTime(2020, 1, 1))
        .inDays;
    final shuffled = [...templates];
    // Fisher-Yates seeded with epoch.
    var seed = epoch == 0 ? 1 : epoch;
    for (var i = shuffled.length - 1; i > 0; i--) {
      // LCG step.
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final j = seed % (i + 1);
      final tmp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = tmp;
    }
    return shuffled.take(questsPerDay).map((t) => t.id).toList();
  }

  static List<String> _readIds() {
    final raw = StorageService.getString(_idsKey);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  static Map<String, int> _readProgress() {
    final raw = StorageService.getString(_progressKey);
    if (raw == null) return <String, int>{};
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return <String, int>{};
    }
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
