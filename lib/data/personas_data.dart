import 'package:flutter/material.dart';

/// One persona in the ladder. Contains display info + its tint color used by
/// persona-aware theming, and (legacy) the achievement id that unlocks it.
/// For v2.1.0, [UnlockService] is the authoritative source — [requiredAchievementId]
/// is kept in-sync for backward compat but new personas can leave it null.
@immutable
class Persona {
  final String id;
  final String emoji;
  final String name;
  final String description;
  final Color tint;
  final String? requiredAchievementId;

  /// Special marker: when requiredAchievementId is set to [kComputed25Unlocks],
  /// PersonaService evaluates it against `AchievementService.allUnlocks.length`.
  static const String kComputed25Unlocks = '__25_unlocks__';

  const Persona({
    required this.id,
    required this.emoji,
    required this.name,
    required this.description,
    required this.tint,
    this.requiredAchievementId,
  });
}

/// Full 30-persona roster. First 4 are always unlocked (base set). The rest
/// unlock via UnlockService (mix of streak + achievement triggers).
const List<Persona> kPersonas = [
  // ── Base (always unlocked) ──────────────────────────────────────────────
  Persona(
    id: 'hype',
    emoji: '🔥',
    name: 'Hype',
    description: 'Every update is LOUD. Every break is a celebration.',
    tint: Color(0xFFE85D2A),
  ),
  Persona(
    id: 'chill',
    emoji: '😎',
    name: 'Chill',
    description: 'Breaks come when they come. No stress.',
    tint: Color(0xFF00A79D),
  ),
  Persona(
    id: 'dramatic',
    emoji: '🎭',
    name: 'Dramatic',
    description: 'Every Monday is a tragedy. Every Friday a miracle.',
    tint: Color(0xFF7B2CBF),
  ),
  Persona(
    id: 'sarcastic',
    emoji: '🙃',
    name: 'Sarcastic',
    description: 'Oh, another school day? Fantastic. Thrilling. Whatever.',
    tint: Color(0xFF6B7280),
  ),

  // ── Legacy unlockables (pre-v2.1.0) ─────────────────────────────────────
  Persona(
    id: 'ghost',
    emoji: '👻',
    name: 'Ghost',
    description: 'Passed through 50 Mondays. Mostly unbothered.',
    tint: Color(0xFF475569),
    requiredAchievementId: '50_mondays',
  ),
  Persona(
    id: 'sage',
    emoji: '🧙',
    name: 'Sage',
    description: 'Six months in. You know the rhythm now.',
    tint: Color(0xFF4F46E5),
    requiredAchievementId: 'old_guard',
  ),
  Persona(
    id: 'menace',
    emoji: '😈',
    name: 'Menace',
    description: '25+ achievements. A collector with no mercy.',
    tint: Color(0xFFB91C1C),
    requiredAchievementId: Persona.kComputed25Unlocks,
  ),
  Persona(
    id: 'zen',
    emoji: '🧘',
    name: 'Zen',
    description: 'All four seasonal breaks reached. Fully balanced.',
    tint: Color(0xFF7CB342),
    requiredAchievementId: 'break_collector',
  ),

  // ── v2.1.0: streak-gated ────────────────────────────────────────────────
  Persona(
    id: 'nerd',
    emoji: '🤓',
    name: 'Nerd',
    description: 'Eyes on the prize, always.',
    tint: Color(0xFF3B82F6),
  ),
  Persona(
    id: 'tired',
    emoji: '🥱',
    name: 'Tired',
    description: 'Coffee and determination — in that order.',
    tint: Color(0xFF94A3B8),
  ),
  Persona(
    id: 'ice',
    emoji: '🧊',
    name: 'Ice',
    description: 'Cool under pressure. No melting.',
    tint: Color(0xFF38BDF8),
  ),
  Persona(
    id: 'gremlin',
    emoji: '👺',
    name: 'Gremlin',
    description: 'Chaos, but make it lovable.',
    tint: Color(0xFF84CC16),
  ),
  Persona(
    id: 'philosopher',
    emoji: '🧐',
    name: 'Philosopher',
    description: 'Why even school, though? (Don\'t answer that.)',
    tint: Color(0xFF8B5CF6),
  ),
  Persona(
    id: 'goblin',
    emoji: '👹',
    name: 'Goblin',
    description: 'Snack-fueled pandemonium.',
    tint: Color(0xFF65A30D),
  ),
  Persona(
    id: 'cloud',
    emoji: '☁️',
    name: 'Cloud',
    description: 'Drifting through the semester.',
    tint: Color(0xFF60A5FA),
  ),
  Persona(
    id: 'volcano',
    emoji: '🌋',
    name: 'Volcano',
    description: 'Calm now. Erupting Friday at 3.',
    tint: Color(0xFFDC2626),
  ),
  Persona(
    id: 'sloth',
    emoji: '🦥',
    name: 'Sloth',
    description: 'Slow. Unbothered. Winning anyway.',
    tint: Color(0xFFA3A380),
  ),
  Persona(
    id: 'storm',
    emoji: '⛈️',
    name: 'Storm',
    description: 'Chaotic energy. Lightning optional.',
    tint: Color(0xFF4338CA),
  ),
  Persona(
    id: 'sprout',
    emoji: '🌱',
    name: 'Sprout',
    description: 'Growing one Monday at a time.',
    tint: Color(0xFF22C55E),
  ),
  Persona(
    id: 'moon',
    emoji: '🌙',
    name: 'Moon',
    description: 'Studies better after dark.',
    tint: Color(0xFF6366F1),
  ),
  Persona(
    id: 'star',
    emoji: '⭐',
    name: 'Star',
    description: 'Visible only on rare, brilliant days.',
    tint: Color(0xFFF59E0B),
  ),
  Persona(
    id: 'phoenix',
    emoji: '🦅',
    name: 'Phoenix',
    description: 'Ashes of last semester. Fire of this one.',
    tint: Color(0xFFEA580C),
  ),
  Persona(
    id: 'sunflower',
    emoji: '🌻',
    name: 'Sunflower',
    description: 'Always facing the Friday sun.',
    tint: Color(0xFFEAB308),
  ),

  // ── v2.1.0: achievement-gated ───────────────────────────────────────────
  Persona(
    id: 'jester',
    emoji: '🃏',
    name: 'Jester',
    description: 'Every week, a joke — nothing taken seriously.',
    tint: Color(0xFFDB2777),
  ),
  Persona(
    id: 'monk',
    emoji: '☸️',
    name: 'Monk',
    description: 'Fifty achievements deep. Perfectly present.',
    tint: Color(0xFFF97316),
  ),
  Persona(
    id: 'rebel',
    emoji: '🤘',
    name: 'Rebel',
    description: 'Mood rollercoaster survivor. Won\'t be tamed.',
    tint: Color(0xFF9333EA),
  ),
  Persona(
    id: 'hacker',
    emoji: '💻',
    name: 'Hacker',
    description: 'Used the AI timetable scan. Welcome to the future.',
    tint: Color(0xFF10B981),
  ),
  Persona(
    id: 'chef',
    emoji: '👨‍🍳',
    name: 'Chef',
    description: 'Full schedule served. Chef\'s kiss.',
    tint: Color(0xFFF43F5E),
  ),
  Persona(
    id: 'pirate',
    emoji: '🏴‍☠️',
    name: 'Pirate',
    description: 'Ten bumps and counting. The treasure is the classmates.',
    tint: Color(0xFF0F172A),
  ),
  Persona(
    id: 'robot',
    emoji: '🤖',
    name: 'Robot',
    description: 'Completed an entire school year. Systems nominal.',
    tint: Color(0xFF475569),
  ),
];

/// Quick lookup by id. Falls back to Hype if missing.
Persona personaById(String id) {
  for (final p in kPersonas) {
    if (p.id == id) return p;
  }
  return kPersonas.first;
}
