import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/country_selection_screen.dart';
import '../screens/profile_selection_screen.dart';
import '../screens/home_screen.dart';
import '../screens/add_subject_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/add_reminder_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';
import '../models/subject.dart';
import '../models/reminder.dart';

class Routes {
  static const String welcome = '/welcome';
  static const String countrySelection = '/country-selection';
  static const String profileSelection = '/profile-selection';
  static const String home = '/home';
  static const String addSubject = '/add-subject';
  static const String reminders = '/reminders';
  static const String addReminder = '/add-reminder';
  static const String settings = '/settings';
  static const String stats = '/stats';
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.welcome:
      return _slide(const WelcomeScreen());

    case Routes.countrySelection:
      return _slide(const CountrySelectionScreen());

    case Routes.profileSelection:
      final country = settings.arguments as String? ?? '';
      return _slide(ProfileSelectionScreen(country: country));

    case Routes.home:
      return _fade(const HomeScreen());

    case Routes.addSubject:
      final subject = settings.arguments as Subject?;
      return _slide(AddSubjectScreen(subject: subject));

    case Routes.reminders:
      return _slide(const RemindersScreen());

    case Routes.addReminder:
      final reminder = settings.arguments as Reminder?;
      return _slide(AddReminderScreen(reminder: reminder));

    case Routes.settings:
      return _slide(const SettingsScreen());

    case Routes.stats:
      return _slide(const StatsScreen());

    default:
      return _slide(const HomeScreen());
  }
}

PageRouteBuilder _slide(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (ctx, animation, secondary) => page,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (ctx, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

PageRouteBuilder _fade(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (ctx, animation, secondary) => page,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (ctx, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}
