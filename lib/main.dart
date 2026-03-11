import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/constants.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'app/theme_preset.dart';
import 'services/fcm_service.dart';
import 'services/notification_service.dart';
import 'services/reminder_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp();

  // Crashlytics — disabled in debug so local errors don't pollute the dashboard.
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Analytics — disable data collection in debug builds.
  await FirebaseAnalytics.instance
      .setAnalyticsCollectionEnabled(!kDebugMode);

  await StorageService.init();
  await NotificationService.initTimezone();
  await NotificationService.init();

  AppThemeController.init(StorageService.getString(StorageKeys.themeId));

  if (StorageService.getBool(StorageKeys.notificationsEnabled) != false) {
    final reminders = ReminderService.getUpcomingReminders();
    await NotificationService.checkDueReminders(reminders);
  }

  FcmService.init(); // fire-and-forget

  final isOnboarded =
      StorageService.getBool(StorageKeys.isOnboarded) ?? false;

  // Wrap runApp in a zone to catch all uncaught async errors.
  runZonedGuarded(
    () => runApp(BreakCountApp(
      initialRoute: isOnboarded ? Routes.home : Routes.welcome,
    )),
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class BreakCountApp extends StatefulWidget {
  final String initialRoute;
  const BreakCountApp({super.key, required this.initialRoute});

  @override
  State<BreakCountApp> createState() => _BreakCountAppState();
}

class _BreakCountAppState extends State<BreakCountApp> {
  @override
  void initState() {
    super.initState();
    AppThemeController.notifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    AppThemeController.notifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BreakCount',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(AppThemeController.current),
      initialRoute: widget.initialRoute,
      onGenerateRoute: generateRoute,
    );
  }
}
