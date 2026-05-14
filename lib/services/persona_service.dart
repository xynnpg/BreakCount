import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../app/constants.dart';
import '../app/theme_preset.dart';
import '../data/personas_data.dart';
import '../services/achievement_service.dart';
import '../services/storage_service.dart';
import '../services/unlock_service.dart';

/// Owns the active persona + the persona ladder unlock state.
/// Singleton. Initialize once during app startup (after StorageService.init
/// and AchievementService.init).
class PersonaService {
  PersonaService._();
  static final PersonaService instance = PersonaService._();

  static const String _unlockedKey = 'persona_unlocked_ids';

  /// Notifier that UI can listen to in order to rebuild on persona change.
  final ValueNotifier<Persona> currentNotifier =
      ValueNotifier(kPersonas.first);

  Persona get current => currentNotifier.value;

  bool _initialised = false;

  /// Must be called once during app startup.
  void init() {
    if (_initialised) return;
    _initialised = true;
    final id = StorageService.getString(StorageKeys.widgetPersona) ?? 'hype';
    currentNotifier.value = _unlockedForCurrentState().firstWhere(
      (p) => p.id == id,
      orElse: () => kPersonas.first,
    );
    // Push initial tint into the global theme controller.
    AppThemeController.setPersonaTint(currentNotifier.value.tint);
    // Re-evaluate ladder any time an achievement unlocks.
    AchievementService.addUnlockListener(_onAchievementUnlocked);
  }

  /// Returns the list of currently unlocked personas (base + those whose
  /// requirement is already satisfied).
  List<Persona> get unlockedPersonas => _unlockedForCurrentState();

  /// Returns true if [id] is currently unlocked for the user.
  bool isUnlocked(String id) =>
      _unlockedForCurrentState().any((p) => p.id == id);

  /// Switches the active persona. No-op if [id] is not unlocked.
  /// Emits via currentNotifier so listeners rebuild.
  Future<bool> setPersona(String id) async {
    final unlocked = _unlockedForCurrentState();
    Persona? match;
    for (final p in unlocked) {
      if (p.id == id) {
        match = p;
        break;
      }
    }
    if (match == null) return false;
    currentNotifier.value = match;
    AppThemeController.setPersonaTint(match.tint);
    await StorageService.saveString(StorageKeys.widgetPersona, match.id);
    return true;
  }

  /// Scans the ladder and returns newly unlocked persona ids (i.e. ones that
  /// became available since the last time this was called). Persists the
  /// cumulative set so overlays do not repeat.
  Future<List<String>> checkUnlocks() async {
    final seen = _readPersistedUnlocked();
    final available =
        _unlockedForCurrentState().map((p) => p.id).toSet();
    final newly = available.difference(seen).toList();
    if (newly.isNotEmpty) {
      await _writePersistedUnlocked(available);
    }
    return newly;
  }

  /// Clears init flag so [init] re-reads from storage after a restore.
  void resetForRestore() => _initialised = false;

  /// Test-only reset.
  @visibleForTesting
  Future<void> resetForTests() async {
    _initialised = false;
    currentNotifier.value = kPersonas.first;
    await StorageService.delete(_unlockedKey);
  }

  // ── Internals ────────────────────────────────────────────────────────────

  void _onAchievementUnlocked(String _) {
    // Fire-and-forget. UI layers observing AchievementService.unlockStream
    // are responsible for surfacing persona-unlock overlays.
    // Nothing to do synchronously here — consumers call checkUnlocks() where
    // they want to display them (usually home_screen unlock queue).
  }

  List<Persona> _unlockedForCurrentState() {
    final unlocks = AchievementService.allUnlocks;
    final unlockIds = unlocks.map((u) => u.id).toSet();
    final totalCount = unlocks.length;
    return kPersonas.where((p) {
      // Legacy gating via requiredAchievementId (pre-v2.1.0 personas).
      final req = p.requiredAchievementId;
      if (req != null) {
        if (req == Persona.kComputed25Unlocks) return totalCount >= 25;
        return unlockIds.contains(req);
      }
      // Base four (no requirement + no UnlockService map entry) + v2.1.0
      // personas that are streak/achievement gated via UnlockService.
      return UnlockService.isPersonaUnlocked(p.id);
    }).toList();
  }

  Set<String> _readPersistedUnlocked() {
    final raw = StorageService.getString(_unlockedKey);
    if (raw == null) {
      // First run — seed with the four base personas so we don't spam
      // overlays on fresh installs.
      return kPersonas
          .where((p) => p.requiredAchievementId == null)
          .map((p) => p.id)
          .toSet();
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as String).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _writePersistedUnlocked(Set<String> value) async {
    await StorageService.saveString(_unlockedKey, jsonEncode(value.toList()));
  }
}
