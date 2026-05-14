import 'package:flutter/material.dart';

enum AchievementRarity { bronze, silver, gold, platinum, secret }

enum AchievementCategory {
  school,
  monday,
  exams,
  breaks,
  powerUser,
  mood,
  social,
  study,
  themes,
  personas,
  streaks,
  seasonal,
  appOpen,
  reminders,
  notifications,
  widget,
  backup,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AchievementRarity rarity;
  final AchievementCategory category;
  // For count-based achievements: goal > 0, progress tracked separately.
  final int goal;
  // XP awarded on unlock. If 0, falls back to the rarity default
  // (AchievementRarity.xpDefault).
  final int xp;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.category,
    this.goal = 0,
    this.xp = 0,
  });

  bool get isSecret => rarity == AchievementRarity.secret;
  bool get isCountBased => goal > 0;

  /// XP this achievement awards — honoring an explicit [xp] override or
  /// defaulting to the rarity tier.
  int get effectiveXp => xp > 0 ? xp : rarity.xpDefault;
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

  // ── Mood Streaks ─────────────────────────────────────────────────────────
  Achievement(
    id: 'on_fire_7',
    name: 'On Fire 🔥',
    description: '7 consecutive days hyped about the next break.',
    icon: Icons.local_fire_department_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.mood,
    goal: 7,
  ),
  Achievement(
    id: 'on_fire_30',
    name: 'Blazing',
    description: '30 consecutive 🔥 days. You feel it.',
    icon: Icons.whatshot_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.mood,
    goal: 30,
  ),
  Achievement(
    id: 'on_fire_100',
    name: 'Eternal Flame',
    description: '100 consecutive 🔥 days. Unstoppable.',
    icon: Icons.auto_awesome_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.mood,
    goal: 100,
  ),
  Achievement(
    id: 'hell_week',
    name: 'Survived Hell Week',
    description: '???',
    icon: Icons.warning_amber_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.mood,
  ),
  Achievement(
    id: 'mood_rollercoaster',
    name: 'Mood Rollercoaster',
    description: 'Hit every mood in a single week. What a ride.',
    icon: Icons.waves_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.mood,
  ),

  // ── Social (mesh bump) ───────────────────────────────────────────────────
  Achievement(
    id: 'first_meet',
    name: 'First Meet',
    description: 'Bumped schedules with another student nearby.',
    icon: Icons.handshake_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.social,
  ),
  Achievement(
    id: 'social_butterfly',
    name: 'Social Butterfly',
    description: 'Met 3 different students via bump.',
    icon: Icons.groups_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.social,
    goal: 3,
  ),
  Achievement(
    id: 'networker',
    name: 'Networker',
    description: 'Met 10 unique students. A real connector.',
    icon: Icons.hub_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.social,
    goal: 10,
  ),
  Achievement(
    id: 'met_the_pack',
    name: 'Met the Pack',
    description: 'Met at least one student of every base persona.',
    icon: Icons.diversity_3_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.social,
  ),
  Achievement(
    id: 'mirror',
    name: 'Mirror',
    description: '???',
    icon: Icons.contrast_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.social,
  ),
  Achievement(
    id: 'opposites_attract',
    name: 'Opposites Attract',
    description: '???',
    icon: Icons.compare_arrows_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.social,
  ),

  // ── Echo / Mentor (donor-side bumps) ─────────────────────────────────────
  Achievement(
    id: 'echo',
    name: 'Echo',
    description: 'Someone copied your schedule via bump.',
    icon: Icons.graphic_eq_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.social,
  ),
  Achievement(
    id: 'mentor',
    name: 'Mentor',
    description: 'Your schedule has been copied by 3 students.',
    icon: Icons.school_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.social,
    goal: 3,
  ),
  Achievement(
    id: 'teacher',
    name: 'Teacher',
    description: 'Your schedule has been copied by 10 students.',
    icon: Icons.cast_for_education_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.social,
    goal: 10,
  ),

  // ── Flex (shared Vibe Card) ──────────────────────────────────────────────
  Achievement(
    id: 'flex',
    name: 'Flex',
    description: 'Shared your Vibe Card. Confidence level: on display.',
    icon: Icons.share_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.social,
  ),

  // ── Weekly Recap ─────────────────────────────────────────────────────────
  Achievement(
    id: 'recap_regular',
    name: 'Recap Regular',
    description: 'Read 5 weekly vibe recaps.',
    icon: Icons.calendar_today_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.mood,
    goal: 5,
  ),
  Achievement(
    id: 'recap_master',
    name: 'Recap Master',
    description: 'Read 20 weekly vibe recaps.',
    icon: Icons.auto_stories_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.mood,
    goal: 20,
  ),
  Achievement(
    id: 'recap_streaker',
    name: 'Recap Streaker',
    description: '10 consecutive weeks, no recap skipped.',
    icon: Icons.bolt_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.mood,
    goal: 10,
  ),

  // ── Streaks (v2.1.0) ─────────────────────────────────────────────────────
  Achievement(
    id: 'streak_3',
    name: '3-Day Streak',
    description: 'Opened BreakCount 3 days in a row.',
    icon: Icons.local_fire_department_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.streaks,
    goal: 3,
  ),
  Achievement(
    id: 'streak_7',
    name: 'Week Lock-in',
    description: 'Seven days in a row. Consistent energy.',
    icon: Icons.local_fire_department_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.streaks,
    goal: 7,
  ),
  Achievement(
    id: 'streak_14',
    name: 'Fortnight',
    description: 'Fourteen consecutive days.',
    icon: Icons.whatshot_outlined,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    goal: 14,
  ),
  Achievement(
    id: 'streak_30',
    name: 'Monthly Regular',
    description: 'Thirty days straight. Building a habit.',
    icon: Icons.calendar_month_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    goal: 30,
  ),
  Achievement(
    id: 'streak_50',
    name: 'Half-Century Streak',
    description: 'Fifty days, uninterrupted.',
    icon: Icons.star_half_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    goal: 50,
  ),
  Achievement(
    id: 'streak_75',
    name: 'Seventy-Five Strong',
    description: 'Seventy-five consecutive days.',
    icon: Icons.electric_bolt_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    goal: 75,
  ),
  Achievement(
    id: 'streak_100',
    name: 'Centurion',
    description: 'Hundred days in a row. Legend status.',
    icon: Icons.emoji_events_outlined,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    goal: 100,
  ),
  Achievement(
    id: 'streak_150',
    name: 'Iron Discipline',
    description: 'A hundred and fifty days straight.',
    icon: Icons.shield_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.streaks,
    goal: 150,
  ),
  Achievement(
    id: 'streak_200',
    name: 'Two Hundred Days',
    description: 'Two hundred days. Untouchable.',
    icon: Icons.trending_up_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.streaks,
    goal: 200,
  ),
  Achievement(
    id: 'streak_365',
    name: 'Year-Round',
    description: 'A full year without breaking the streak.',
    icon: Icons.stars_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.streaks,
    goal: 365,
  ),

  // ── App-Open milestones (total unique days) ──────────────────────────────
  Achievement(
    id: 'app_open_5',
    name: 'Five Visits',
    description: 'Opened BreakCount on 5 different days.',
    icon: Icons.visibility_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.appOpen,
    goal: 5,
  ),
  Achievement(
    id: 'app_open_10',
    name: 'Regular',
    description: '10 unique-day visits.',
    icon: Icons.looks_one_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.appOpen,
    goal: 10,
  ),
  Achievement(
    id: 'app_open_25',
    name: 'Frequenter',
    description: '25 unique-day visits.',
    icon: Icons.event_repeat_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.appOpen,
    goal: 25,
  ),
  Achievement(
    id: 'app_open_50',
    name: 'Ritual',
    description: '50 unique-day visits.',
    icon: Icons.replay_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.appOpen,
    goal: 50,
  ),
  Achievement(
    id: 'app_open_100',
    name: 'Centennial Visits',
    description: '100 unique-day visits.',
    icon: Icons.workspace_premium_outlined,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.appOpen,
    goal: 100,
  ),
  Achievement(
    id: 'app_open_365',
    name: 'Every Day for a Year',
    description: '365 unique-day visits.',
    icon: Icons.auto_awesome_motion_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.appOpen,
    goal: 365,
  ),

  // ── Theme collector ──────────────────────────────────────────────────────
  Achievement(
    id: 'theme_explorer',
    name: 'Theme Explorer',
    description: 'Unlocked 3 themes.',
    icon: Icons.palette_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.themes,
    goal: 3,
  ),
  Achievement(
    id: 'theme_collector',
    name: 'Theme Collector',
    description: 'Unlocked 6 themes.',
    icon: Icons.palette_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.themes,
    goal: 6,
  ),
  Achievement(
    id: 'theme_curator',
    name: 'Theme Curator',
    description: 'Unlocked 10 themes.',
    icon: Icons.auto_fix_high_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.themes,
    goal: 10,
  ),
  Achievement(
    id: 'theme_master',
    name: 'Theme Master',
    description: 'Unlocked every theme in the app.',
    icon: Icons.format_color_fill_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.themes,
  ),

  // ── Persona collector ────────────────────────────────────────────────────
  Achievement(
    id: 'persona_five',
    name: 'Five Personas',
    description: 'Unlocked 5 personas.',
    icon: Icons.face_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.personas,
    goal: 5,
  ),
  Achievement(
    id: 'persona_fifteen',
    name: 'Persona Hunter',
    description: 'Unlocked 15 personas.',
    icon: Icons.groups_outlined,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.personas,
    goal: 15,
  ),
  Achievement(
    id: 'persona_all',
    name: 'Every Vibe',
    description: 'Unlocked all 30 personas.',
    icon: Icons.diversity_1_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.personas,
  ),

  // ── Achievement Hunter (total-unlock ladder) ─────────────────────────────
  Achievement(
    id: 'achievement_hunter_10',
    name: 'Getting Started',
    description: 'Unlocked 10 achievements.',
    icon: Icons.check_circle_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.powerUser,
    goal: 10,
  ),
  Achievement(
    id: 'achievement_hunter_25',
    name: 'Collector',
    description: 'Unlocked 25 achievements.',
    icon: Icons.inventory_2_outlined,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.powerUser,
    goal: 25,
  ),
  Achievement(
    id: 'achievement_hunter_50',
    name: 'Completionist',
    description: 'Unlocked 50 achievements.',
    icon: Icons.grade_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.powerUser,
    goal: 50,
  ),
  Achievement(
    id: 'achievement_hunter_75',
    name: 'Relentless',
    description: 'Unlocked 75 achievements.',
    icon: Icons.rocket_launch_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.powerUser,
    goal: 75,
  ),
  Achievement(
    id: 'achievement_hunter_100',
    name: 'Beyond',
    description: '100 achievements unlocked. What else is there?',
    icon: Icons.auto_awesome_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.powerUser,
    goal: 100,
  ),

  // ── Seasonal (per-break) ─────────────────────────────────────────────────
  Achievement(
    id: 'survived_autumn',
    name: 'Autumn Survivor',
    description: 'Reached the autumn / October break.',
    icon: Icons.park_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.seasonal,
  ),
  Achievement(
    id: 'survived_winter',
    name: 'Winter Survivor',
    description: 'Reached the winter / Christmas break.',
    icon: Icons.ac_unit_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.seasonal,
  ),
  Achievement(
    id: 'survived_spring',
    name: 'Spring Survivor',
    description: 'Reached the spring / Easter break.',
    icon: Icons.local_florist_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.seasonal,
  ),
  Achievement(
    id: 'survived_summer',
    name: 'Summer Survivor',
    description: 'Reached the summer break.',
    icon: Icons.beach_access_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.seasonal,
  ),
  Achievement(
    id: 'all_seasonal_breaks',
    name: 'All Four Seasons',
    description: 'Reached every seasonal break in one year.',
    icon: Icons.recycling_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.seasonal,
  ),
  Achievement(
    id: 'break_reveal_10',
    name: 'Ten Break Reveals',
    description: 'Witnessed 10 break-reveal animations.',
    icon: Icons.celebration_outlined,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.seasonal,
    goal: 10,
  ),

  // ── Study sessions ───────────────────────────────────────────────────────
  Achievement(
    id: 'first_study',
    name: 'First Study Log',
    description: 'Logged your first study session.',
    icon: Icons.menu_book_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.study,
  ),
  Achievement(
    id: 'study_10',
    name: 'Committed',
    description: 'Logged 10 study sessions.',
    icon: Icons.self_improvement_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.study,
    goal: 10,
  ),
  Achievement(
    id: 'study_50',
    name: 'Focused',
    description: 'Logged 50 study sessions.',
    icon: Icons.school_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.study,
    goal: 50,
  ),
  Achievement(
    id: 'study_100',
    name: 'Scholar',
    description: 'Logged 100 study sessions.',
    icon: Icons.psychology_outlined,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.study,
    goal: 100,
  ),
  Achievement(
    id: 'study_week_10h',
    name: 'Ten-Hour Week',
    description: 'Logged 10+ hours of study in a single week.',
    icon: Icons.access_time_filled_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.study,
  ),
  Achievement(
    id: 'study_marathon',
    name: 'Marathon Runner',
    description: 'Logged a single study session of 3+ hours.',
    icon: Icons.directions_run_outlined,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.study,
  ),

  // ── Daily quests ─────────────────────────────────────────────────────────
  Achievement(
    id: 'quest_first',
    name: 'First Quest',
    description: 'Completed your first daily quest.',
    icon: Icons.explore_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'quest_10',
    name: 'Questmonger',
    description: 'Completed 10 daily quests.',
    icon: Icons.task_alt_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.powerUser,
    goal: 10,
  ),
  Achievement(
    id: 'quest_50',
    name: 'Quest Veteran',
    description: 'Completed 50 daily quests.',
    icon: Icons.military_tech_outlined,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.powerUser,
    goal: 50,
  ),
  Achievement(
    id: 'quest_triple',
    name: 'Triple Threat',
    description: 'Completed all 3 daily quests in one day.',
    icon: Icons.bolt_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.powerUser,
  ),

  // ── XP / Level ───────────────────────────────────────────────────────────
  Achievement(
    id: 'level_5',
    name: 'Master Tier',
    description: 'Reached Level 5 — Master.',
    icon: Icons.workspace_premium_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'level_7',
    name: 'Mythic Tier',
    description: 'Reached Level 7 — Mythic.',
    icon: Icons.diamond_outlined,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'level_10',
    name: 'Eternal',
    description: 'Reached Level 10 — Eternal. The final name.',
    icon: Icons.all_inclusive_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.powerUser,
  ),

  // ── Social extensions ────────────────────────────────────────────────────
  Achievement(
    id: 'first_compare',
    name: 'Side by Side',
    description: 'Compared achievements with another student nearby.',
    icon: Icons.compare_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.social,
  ),
  Achievement(
    id: 'compare_5',
    name: 'Benchmarker',
    description: 'Compared with 5 different students.',
    icon: Icons.insights_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.social,
    goal: 5,
  ),

  // ── Hidden (secret) ──────────────────────────────────────────────────────
  Achievement(
    id: 'secret_birthday',
    name: 'Birthday Honors',
    description: '???',
    icon: Icons.cake_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'secret_new_year',
    name: 'New Year, New Me',
    description: '???',
    icon: Icons.celebration_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'secret_exact_break',
    name: 'Perfect Timing',
    description: '???',
    icon: Icons.hourglass_top_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'secret_leap_day',
    name: 'Leap Day',
    description: '???',
    icon: Icons.date_range_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'secret_midnight_exam',
    name: 'Witching Hour',
    description: '???',
    icon: Icons.access_time_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.powerUser,
  ),

  // ── Streaks (deeper) ─────────────────────────────────────────────────────
  Achievement(
    id: 'streak_21',
    name: 'Three Weeks Solid',
    description: 'Three weeks in a row. Habit forming.',
    icon: Icons.local_fire_department_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.streaks,
    goal: 21,
  ),
  Achievement(
    id: 'streak_42',
    name: 'The Answer',
    description: '42 days. The answer to life, the universe, and streaks.',
    icon: Icons.auto_awesome_outlined,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    goal: 42,
  ),
  Achievement(
    id: 'streak_60',
    name: 'Two Months',
    description: 'Sixty consecutive days. Serious commitment.',
    icon: Icons.calendar_today_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.streaks,
    goal: 60,
  ),
  Achievement(
    id: 'streak_90',
    name: 'Quarter Year',
    description: 'Ninety days straight. A full quarter.',
    icon: Icons.pie_chart_outline_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    goal: 90,
  ),
  Achievement(
    id: 'streak_120',
    name: 'Four Months',
    description: 'A hundred and twenty days. Relentless.',
    icon: Icons.bolt_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.streaks,
    goal: 120,
  ),
  Achievement(
    id: 'streak_250',
    name: 'Two-Fifty',
    description: 'Two hundred and fifty days. Almost a year.',
    icon: Icons.military_tech_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.streaks,
    goal: 250,
  ),

  // ── Study (deeper) ───────────────────────────────────────────────────────
  Achievement(
    id: 'study_200',
    name: 'Dedicated',
    description: 'Logged 200 study sessions.',
    icon: Icons.menu_book_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.study,
    goal: 200,
  ),
  Achievement(
    id: 'study_500',
    name: 'Obsessed',
    description: 'Logged 500 study sessions. Seek help.',
    icon: Icons.psychology_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.study,
    goal: 500,
  ),
  Achievement(
    id: 'study_total_24h',
    name: 'Full Day',
    description: 'Logged a total of 24 hours of study.',
    icon: Icons.access_time_filled_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.study,
  ),
  Achievement(
    id: 'study_total_100h',
    name: 'Centurion Hours',
    description: 'Logged a total of 100 hours of study.',
    icon: Icons.workspace_premium_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.study,
  ),
  Achievement(
    id: 'study_subject_master',
    name: 'Subject Master',
    description: 'Logged 50 sessions for the same subject.',
    icon: Icons.star_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.study,
  ),

  // ── Exams (countdown) ────────────────────────────────────────────────────
  Achievement(
    id: 'exam_countdown_1week',
    name: 'One Week Out',
    description: 'Added an exam with less than 7 days to go.',
    icon: Icons.calendar_today_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.exams,
  ),
  Achievement(
    id: 'exam_countdown_1day',
    name: 'Eve of Battle',
    description: 'Added an exam with less than 24 hours to go.',
    icon: Icons.alarm_on_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.exams,
  ),
  Achievement(
    id: 'exam_all_cleared',
    name: 'All Clear',
    description: 'Every tracked exam is now in the past.',
    icon: Icons.check_circle_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.exams,
  ),

  // ── Reminders ────────────────────────────────────────────────────────────
  Achievement(
    id: 'first_reminder',
    name: 'First Reminder',
    description: 'Set your first reminder.',
    icon: Icons.notifications_active_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.reminders,
  ),
  Achievement(
    id: 'reminder_5',
    name: 'Reminder Regular',
    description: 'Set 5 reminders.',
    icon: Icons.notifications_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.reminders,
    goal: 5,
  ),
  Achievement(
    id: 'reminder_20',
    name: 'Reminder Pro',
    description: 'Set 20 reminders. Never miss a thing.',
    icon: Icons.notification_important_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.reminders,
    goal: 20,
  ),
  Achievement(
    id: 'reminder_punctual',
    name: 'Punctual',
    description: 'A reminder fired right on time.',
    icon: Icons.timer_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.reminders,
  ),

  // ── Notifications ────────────────────────────────────────────────────────
  Achievement(
    id: 'notif_enabled',
    name: 'Notifications On',
    description: 'Enabled notifications.',
    icon: Icons.notifications_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.notifications,
  ),
  Achievement(
    id: 'notif_break_enabled',
    name: 'Break Alerts On',
    description: 'Enabled break notifications.',
    icon: Icons.event_available_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.notifications,
  ),
  Achievement(
    id: 'notif_class_enabled',
    name: 'Class Alerts On',
    description: 'Enabled class notifications.',
    icon: Icons.school_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.notifications,
  ),

  // ── Widget ───────────────────────────────────────────────────────────────
  Achievement(
    id: 'widget_first_use',
    name: 'Widget Activated',
    description: 'Tapped the home-screen widget.',
    icon: Icons.widgets_outlined,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.widget,
  ),
  Achievement(
    id: 'widget_persona_changed',
    name: 'Widget Customized',
    description: 'Changed the widget persona.',
    icon: Icons.tune_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.widget,
  ),
  Achievement(
    id: 'widget_5_taps',
    name: 'Widget Addict',
    description: 'Tapped the widget 5 times.',
    icon: Icons.touch_app_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.widget,
    goal: 5,
  ),

  // ── Backup ───────────────────────────────────────────────────────────────
  Achievement(
    id: 'first_backup',
    name: 'Backed Up',
    description: 'Backed up your data to Google Drive.',
    icon: Icons.backup_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.backup,
  ),
  Achievement(
    id: 'backup_5',
    name: 'Backup Regular',
    description: 'Backed up 5 times. Your data is safe.',
    icon: Icons.cloud_done_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.backup,
    goal: 5,
  ),
  Achievement(
    id: 'backup_restored',
    name: 'Restored',
    description: 'Restored your data from Google Drive.',
    icon: Icons.restore_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.backup,
  ),

  // ── Mood (deeper) ────────────────────────────────────────────────────────
  Achievement(
    id: 'on_fire_50',
    name: 'Inferno',
    description: '50 consecutive 🔥 days. You are the fire.',
    icon: Icons.local_fire_department_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.mood,
    goal: 50,
  ),
  Achievement(
    id: 'dead_streak_7',
    name: 'Rock Bottom Week',
    description: '7 consecutive 💀 days. It gets better.',
    icon: Icons.sentiment_very_dissatisfied_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.mood,
    goal: 7,
  ),
  Achievement(
    id: 'mood_logged_30',
    name: 'Mood Tracker',
    description: 'Logged 30 mood snapshots.',
    icon: Icons.mood_rounded,
    rarity: AchievementRarity.bronze,
    category: AchievementCategory.mood,
    goal: 30,
  ),
  Achievement(
    id: 'mood_logged_100',
    name: 'Mood Historian',
    description: 'Logged 100 mood snapshots.',
    icon: Icons.history_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.mood,
    goal: 100,
  ),
  Achievement(
    id: 'mood_logged_365',
    name: 'Year of Feelings',
    description: 'Logged 365 mood snapshots.',
    icon: Icons.calendar_month_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.mood,
    goal: 365,
  ),

  // ── Social (deeper) ──────────────────────────────────────────────────────
  Achievement(
    id: 'networker_25',
    name: 'Super Connector',
    description: 'Met 25 unique students.',
    icon: Icons.hub_outlined,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.social,
    goal: 25,
  ),
  Achievement(
    id: 'networker_50',
    name: 'Legend of the Network',
    description: 'Met 50 unique students.',
    icon: Icons.public_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.social,
    goal: 50,
  ),
  Achievement(
    id: 'teacher_25',
    name: 'Professor',
    description: 'Your schedule has been copied by 25 students.',
    icon: Icons.cast_for_education_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.social,
    goal: 25,
  ),
  Achievement(
    id: 'compare_10',
    name: 'Benchmarker Pro',
    description: 'Compared achievements with 10 students.',
    icon: Icons.leaderboard_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.social,
    goal: 10,
  ),
  Achievement(
    id: 'compare_25',
    name: 'Analyst',
    description: 'Compared achievements with 25 students.',
    icon: Icons.analytics_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.social,
    goal: 25,
  ),

  // ── App Opens (deeper) ───────────────────────────────────────────────────
  Achievement(
    id: 'app_open_200',
    name: 'Bicentennial',
    description: '200 unique-day visits.',
    icon: Icons.event_repeat_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.appOpen,
    goal: 200,
  ),
  Achievement(
    id: 'app_open_500',
    name: 'Half-Millennium',
    description: '500 unique-day visits.',
    icon: Icons.all_inclusive_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.appOpen,
    goal: 500,
  ),

  // ── Quests (deeper) ──────────────────────────────────────────────────────
  Achievement(
    id: 'quest_100',
    name: 'Quest Master',
    description: 'Completed 100 daily quests.',
    icon: Icons.military_tech_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.powerUser,
    goal: 100,
  ),
  Achievement(
    id: 'quest_200',
    name: 'Quest Legend',
    description: 'Completed 200 daily quests.',
    icon: Icons.emoji_events_rounded,
    rarity: AchievementRarity.platinum,
    category: AchievementCategory.powerUser,
    goal: 200,
  ),
  Achievement(
    id: 'quest_perfect_week',
    name: 'Perfect Week',
    description: 'Completed all 3 daily quests every day for 7 days straight.',
    icon: Icons.done_all_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.powerUser,
  ),

  // ── School (deeper) ──────────────────────────────────────────────────────
  Achievement(
    id: 'school_2nd_year',
    name: 'Second Year',
    description: 'Used BreakCount across 2 school years.',
    icon: Icons.looks_two_rounded,
    rarity: AchievementRarity.silver,
    category: AchievementCategory.school,
  ),
  Achievement(
    id: 'school_3rd_year',
    name: 'Third Year',
    description: 'Used BreakCount across 3 school years.',
    icon: Icons.looks_3_rounded,
    rarity: AchievementRarity.gold,
    category: AchievementCategory.school,
  ),

  // ── Secrets (new) ────────────────────────────────────────────────────────
  Achievement(
    id: 'secret_friday_13',
    name: 'Unlucky?',
    description: '???',
    icon: Icons.warning_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.powerUser,
  ),
  Achievement(
    id: 'secret_exam_eve',
    name: 'Eve of Doom',
    description: '???',
    icon: Icons.nightlight_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.exams,
  ),
  Achievement(
    id: 'secret_100_days_left',
    name: '100 Days Left',
    description: '???',
    icon: Icons.hourglass_bottom_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.school,
  ),
  Achievement(
    id: 'secret_first_week_done',
    name: 'First Week Survived',
    description: '???',
    icon: Icons.flag_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.school,
  ),
  Achievement(
    id: 'secret_no_breaks_month',
    name: 'No Rest for the Wicked',
    description: '???',
    icon: Icons.block_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.breaks,
  ),
  Achievement(
    id: 'secret_all_subjects',
    name: 'Full House',
    description: '???',
    icon: Icons.grid_view_rounded,
    rarity: AchievementRarity.secret,
    category: AchievementCategory.school,
  ),

  // ── Developer Easter Egg ─────────────────────────────────────────────────
  Achievement(
    id: 'you_are_a_dev',
    name: 'You\'re a Dev',
    description: '???',
    icon: Icons.terminal_rounded,
    rarity: AchievementRarity.secret,
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

  /// Default XP awarded for this rarity when an achievement doesn't override.
  int get xpDefault {
    switch (this) {
      case AchievementRarity.bronze:
        return 25;
      case AchievementRarity.silver:
        return 75;
      case AchievementRarity.gold:
        return 200;
      case AchievementRarity.platinum:
        return 500;
      case AchievementRarity.secret:
        return 750;
    }
  }

  /// Sort priority — used to order the rarity grid (Platinum → Gold →
  /// Silver → Bronze → Secret).
  int get sortOrder {
    switch (this) {
      case AchievementRarity.platinum:
        return 0;
      case AchievementRarity.gold:
        return 1;
      case AchievementRarity.silver:
        return 2;
      case AchievementRarity.bronze:
        return 3;
      case AchievementRarity.secret:
        return 4;
    }
  }
}

extension AchievementCategoryLabel on AchievementCategory {
  String get label {
    switch (this) {
      case AchievementCategory.school:
        return 'School';
      case AchievementCategory.monday:
        return 'Mondays';
      case AchievementCategory.exams:
        return 'Exams';
      case AchievementCategory.breaks:
        return 'Breaks';
      case AchievementCategory.powerUser:
        return 'Power User';
      case AchievementCategory.mood:
        return 'Mood';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.study:
        return 'Study';
      case AchievementCategory.themes:
        return 'Themes';
      case AchievementCategory.personas:
        return 'Personas';
      case AchievementCategory.streaks:
        return 'Streaks';
      case AchievementCategory.seasonal:
        return 'Seasonal';
      case AchievementCategory.appOpen:
        return 'App Opens';
      case AchievementCategory.reminders:
        return 'Reminders';
      case AchievementCategory.notifications:
        return 'Notifications';
      case AchievementCategory.widget:
        return 'Widget';
      case AchievementCategory.backup:
        return 'Backup';
    }
  }
}
