import 'dart:ui';

/// All magic numbers, colors, and string constants live here.
class AppColors {
  // Primary accent — Coffee Brown
  static const Color primary = Color(0xFF6F4E37);
  static const Color primaryLight = Color(0xFFFDF6F0); // warm cream
  static const Color primaryHover = Color(0xFF5C3D2E); // darker roast

  // Legacy aliases kept for backward compatibility
  static const Color primaryPurple = Color(0xFF6F4E37);
  static const Color primaryBlue = Color(0xFF6F4E37);
  static const Color accentCyan = Color(0xFF6F4E37);

  // Backgrounds
  static const Color scaffoldBg = Color(0xFFFDFAF7); // warm off-white
  static const Color bgDeep = Color(0xFFFDFAF7);   // alias
  static const Color bgDark = Color(0xFFFFFFFF);    // alias → white surface
  static const Color bgSurface = Color(0xFFFDF6F0); // warm cream surface
  static const Color bgGlass = Color(0xFFFFFFFF);   // no longer glass

  // Surface / Cards
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceBorder = Color(0xFFE8D5C4); // warm tan border

  // Status
  static const Color success = Color(0xFF2D7A47);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFC0392B); // warm red

  // Text
  static const Color textPrimary = Color(0xFF1C1008); // warm near-black
  static const Color textSecondary = Color(0xFF6B5744); // warm brown-grey
  static const Color textTertiary = Color(0xFFA89888); // muted warm tone

  // Preset accent palette (kept for any legacy usage)
  static const List<Color> accentPalette = [
    Color(0xFF6F4E37),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];

  // Subject color palette
  static const List<int> subjectColors = [
    0xFF4F46E5,
    0xFF0EA5E9,
    0xFF10B981,
    0xFFF59E0B,
    0xFFEF4444,
    0xFF8B5CF6,
    0xFFEC4899,
    0xFF14B8A6,
    0xFF6366F1,
    0xFFF97316,
  ];
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

class AppDurations {
  static const Duration pageTransition = Duration(milliseconds: 400);
  static const Duration cardEntrance = Duration(milliseconds: 300);
  static const Duration numberFlip = Duration(milliseconds: 800);
  static const Duration progressFill = Duration(milliseconds: 1200);
  static const Duration microInteraction = Duration(milliseconds: 150);
  static const Duration gradientCycle = Duration(seconds: 12);
}

class StorageKeys {
  static const String schoolYear = 'school_year_data';
  static const String selectedCountry = 'selected_country';
  static const String isOnboarded = 'is_onboarded';
  static const String schedule = 'schedule_data';
  static const String reminders = 'reminders_data';
  static const String exams = 'exams_data';
  static const String lastUpdated = 'last_updated';
  static const String accentColor = 'accent_color';
  static const String useAlternatingWeeks = 'use_alternating_weeks';
  static const String currentWeekType = 'current_week_type';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String aiApiKey = 'ai_api_key';
  static const String groqApiKey = 'groq_api_key';
  static const String deviceId = 'device_id';
  static const String themeId = 'theme_id';
}

/// Countries available in the SchoolYear GitHub API
const List<String> schoolYearCountries = [
  'Romania',
  'France',
  'Germany',
  'Italy',
  'Japan',
  'Canada',
  'Mexico',
  'Poland',
  'Turkey',
  'United Kingdom',
  'Usa',
];

/// All selectable countries with name, ISO code, and emoji flag
const List<Map<String, String>> allCountries = [
  {'name': 'Australia', 'iso': 'AU', 'flag': '🇦🇺'},
  {'name': 'Austria', 'iso': 'AT', 'flag': '🇦🇹'},
  {'name': 'Belgium', 'iso': 'BE', 'flag': '🇧🇪'},
  {'name': 'Brazil', 'iso': 'BR', 'flag': '🇧🇷'},
  {'name': 'Canada', 'iso': 'CA', 'flag': '🇨🇦'},
  {'name': 'Croatia', 'iso': 'HR', 'flag': '🇭🇷'},
  {'name': 'Czech Republic', 'iso': 'CZ', 'flag': '🇨🇿'},
  {'name': 'Denmark', 'iso': 'DK', 'flag': '🇩🇰'},
  {'name': 'Estonia', 'iso': 'EE', 'flag': '🇪🇪'},
  {'name': 'Finland', 'iso': 'FI', 'flag': '🇫🇮'},
  {'name': 'France', 'iso': 'FR', 'flag': '🇫🇷'},
  {'name': 'Germany', 'iso': 'DE', 'flag': '🇩🇪'},
  {'name': 'Greece', 'iso': 'GR', 'flag': '🇬🇷'},
  {'name': 'Hungary', 'iso': 'HU', 'flag': '🇭🇺'},
  {'name': 'Ireland', 'iso': 'IE', 'flag': '🇮🇪'},
  {'name': 'Italy', 'iso': 'IT', 'flag': '🇮🇹'},
  {'name': 'Japan', 'iso': 'JP', 'flag': '🇯🇵'},
  {'name': 'Latvia', 'iso': 'LV', 'flag': '🇱🇻'},
  {'name': 'Lithuania', 'iso': 'LT', 'flag': '🇱🇹'},
  {'name': 'Luxembourg', 'iso': 'LU', 'flag': '🇱🇺'},
  {'name': 'Mexico', 'iso': 'MX', 'flag': '🇲🇽'},
  {'name': 'Netherlands', 'iso': 'NL', 'flag': '🇳🇱'},
  {'name': 'Norway', 'iso': 'NO', 'flag': '🇳🇴'},
  {'name': 'Poland', 'iso': 'PL', 'flag': '🇵🇱'},
  {'name': 'Portugal', 'iso': 'PT', 'flag': '🇵🇹'},
  {'name': 'Romania', 'iso': 'RO', 'flag': '🇷🇴'},
  {'name': 'Slovakia', 'iso': 'SK', 'flag': '🇸🇰'},
  {'name': 'Slovenia', 'iso': 'SI', 'flag': '🇸🇮'},
  {'name': 'Spain', 'iso': 'ES', 'flag': '🇪🇸'},
  {'name': 'Sweden', 'iso': 'SE', 'flag': '🇸🇪'},
  {'name': 'Switzerland', 'iso': 'CH', 'flag': '🇨🇭'},
  {'name': 'Turkey', 'iso': 'TR', 'flag': '🇹🇷'},
  {'name': 'United Kingdom', 'iso': 'GB', 'flag': '🇬🇧'},
  {'name': 'Usa', 'iso': 'US', 'flag': '🇺🇸'},
];

String countryFlag(String countryName) {
  final entry = allCountries.firstWhere(
    (c) => c['name'] == countryName,
    orElse: () => {'flag': '🌍'},
  );
  return entry['flag']!;
}

String countryIso(String countryName) {
  final entry = allCountries.firstWhere(
    (c) => c['name'] == countryName,
    orElse: () => {'iso': 'US'},
  );
  return entry['iso']!;
}
