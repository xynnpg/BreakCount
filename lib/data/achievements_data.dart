import 'package:flutter/material.dart';

enum AchievementRarity { bronze, silver, gold, platinum, secret }

enum AchievementCategory { school, monday, exams, breaks, powerUser }

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AchievementRarity rarity;
  final AchievementCategory category;
  // For count-based achievements: goal > 0, progress tracked separately.
  final int goal;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.category,
    this.goal = 0,
  });

  bool get isSecret => rarity == AchievementRarity.secret;
  bool get isCountBased => goal > 0;
}

const List<Achievement> kAchievements = [
  // ── School Progress ──────────────────────────────────────────────────────
  Achievement(
    id: 'first_day',
    name: 'First Day Down',
    description: 'Survived the first school day of the year.',
    icon: Icons.school_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.school,
  ),
  Achievement(
    id: 'one_month',
    name: 'One Month Warrior',
    description: 'Completed 30 school days. You\'re doing great.',
    icon: Icons.calendar_month_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.school,
    goal: 30,
  ),
  Achievement(
    id: 'halfway',
    name: 'Halfway There',
    description: 'School year is 50% complete. Downhill from here.',
    icon: Icons.trending_up_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.school,
  ),
  Achievement(
    id: 'three_quarters',
    name: 'Three Quarters',
    description: '75% of the year done. The finish line is visible.',
    icon: Icons.hourglass_bottom_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.school,
  ),
  Achievement(
    id: 'year_legend',
    name: 'School Year Legend',
    description: 'Completed the full school year. Absolute legend.',
    icon: Icons.emoji_events_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.school,
  ),
  Achievement(
    id: 'summer_now',
    name: 'Summer Starts Now',
    description: 'Opened the app on the first day of summer break.',
    icon: Icons.wb_sunny_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.school,
  ),

  // ── Monday Club ───────────────────────────────────────────────────────────
  Achievement(
    id: 'first_monday',
    name: 'First Monday Survived',
    description: 'You survived a Monday. Many more to come.',
    icon: Icons.sentiment_dissatisfied_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.monday,
  ),
  Achievement(
    id: '10_mondays',
    name: '10 Mondays',
    description: 'Survived 10 Mondays. You\'re built different.',
    icon: Icons.filter_9_plus_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.monday,
    goal: 10,
  ),
  Achievement(
    id: '25_mondays',
    name: '25 Mondays',
    description: 'A quarter century of Mondays. Respect.',
    icon: Icons.military_tech_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.monday,
    goal: 25,
  ),
  Achievement(
    id: '50_mondays',
    name: '50 Mondays',
    description: 'Survived 50 Mondays. You\'re basically immortal.',
    icon: Icons.workspace_premium_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.monday,
    goal: 50,
  ),
  Achievement(
    id: 'all_mondays',
    name: 'Every Single Monday',
    description: 'Survived every Monday in a full school year. Platinum tier.',
    icon: Icons.stars_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.monday,
  ),

  // ── Exams & Schedule ─────────────────────────────────────────────────────
  Achievement(
    id: 'first_exam',
    name: 'First Exam Added',
    description: 'Added your first exam. The stress begins.',
    icon: Icons.edit_note_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.exams,
  ),
  Achievement(
    id: 'exam_veteran',
    name: 'Exam Veteran',
    description: 'Added 5 exams to track. Planning ahead.',
    icon: Icons.assignment_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.exams,
    goal: 5,
  ),
  Achievement(
    id: 'exam_master',
    name: 'Exam Master',
    description: 'Added 20 exams. Either very prepared or very stressed.',
    icon: Icons.menu_book_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.exams,
    goal: 20,
  ),
  Achievement(
    id: 'fully_loaded',
    name: 'Fully Loaded',
    description: 'Set up a complete weekly schedule.',
    icon: Icons.grid_on_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.exams,
  ),
  Achievement(
    id: 'early_bird',
    name: 'Early Bird',
    description: 'Has a class before 8am. We\'re sorry.',
    icon: Icons.alarm_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.exams,
  ),
  Achievement(
    id: 'all_nighter',
    name: 'All-Nighter Subject',
    description: '???',
    icon: Icons.bedtime_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.exams,
  ),

  // ── Break Milestones ──────────────────────────────────────────────────────
  Achievement(
    id: 'first_break',
    name: 'First Break Reached',
    description: 'Survived until your first school break. Freedom!',
    icon: Icons.celebration_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.breaks,
  ),
  Achievement(
    id: 'break_collector',
    name: 'Break Collector',
    description: 'Reached all 4 seasonal breaks in one year.',
    icon: Icons.collections_bookmark_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.breaks,
  ),
  Achievement(
    id: 'vacation_speed_run',
    name: 'Vacation Speed Run',
    description: '???',
    icon: Icons.directions_run_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.breaks,
  ),

  // ── Power User ────────────────────────────────────────────────────────────
  Achievement(
    id: 'ai_wizard',
    name: 'AI Wizard',
    description: 'Used AI photo scan to import a timetable.',
    icon: Icons.auto_awesome_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'shake_master',
    name: 'Shake Master',
    description: 'Used shake-to-share 3 times.',
    icon: Icons.vibration_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.powerUser,
    goal: 3,
  ),
  Achievement(
    id: 'night_owl',
    name: 'Night Owl',
    description: '???',
    icon: Icons.nightlight_round_outlined,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'speed_run',
    name: 'Speed Run',
    description: '???',
    icon: Icons.flash_on_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'old_guard',
    name: 'Old Guard',
    description: 'App installed for 6+ months. A true veteran.',
    icon: Icons.history_edu_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.powerUser,
  ),
];

extension AchievementRarityLabel on AchievementRarity {
  String get label {
    switch (this) {
      case AchievementRarity.bronze:
        return 'Bronze';
      case AchievementRarity.silver:
        return 'Silver';
      case AchievementRarity.gold:
        return 'Gold';
      case AchievementRarity.platinum:
        return 'Platinum';
      case AchievementRarity.secret:
        return 'Secret';
    }
  }

  Color get color {
    switch (this) {
      case AchievementRarity.bronze:
        return const Color(0xFFCD7F32);
      case AchievementRarity.silver:
        return const Color(0xFF9E9E9E);
      case AchievementRarity.gold:
        return const Color(0xFFFFB300);
      case AchievementRarity.platinum:
        return const Color(0xFF4FC3F7);
      case AchievementRarity.secret:
        return const Color(0xFFA89888);
    }
  }
}
