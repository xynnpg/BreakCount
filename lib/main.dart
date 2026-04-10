import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'app/constants.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'app/theme_preset.dart';
import 'services/fcm_service.dart';
import 'services/notification_service.dart';
import 'services/break_notification_service.dart';
import 'services/reminder_service.dart';
import 'services/backup_service.dart';
import 'services/storage_service.dart';
import 'services/achievement_service.dart';
import 'services/widget_service.dart';
import 'utils/debug_log.dart';

/// Silently runs a backup if the configured auto-backup frequency is due.
/// Fire-and-forget — never blocks app startup.
Future<void> _maybeAutoBackup() async {
  try {
    final mode = StorageService.getString(StorageKeys.autoBackup) ?? 'off';
    if (mode == 'off') return;
    final lastRaw = StorageService.getString(StorageKeys.lastBackupTime);
    final last = lastRaw != null ? DateTime.tryParse(lastRaw) : null;
    final diff = last != null ? DateTime.now().difference(last) : null;
    final isDue = diff == null ||
        switch (mode) {
          'daily' => diff >= const Duration(hours: 24),
          'weekly' => diff >= const Duration(days: 7),
          'monthly' => diff >= const Duration(days: 30),
          _ => false,
        };
    if (isDue) await BackupService.backup();
  } catch (_) {
    // Never let auto-backup crash affect startup
  }
}

/// Called by the Android widget host when a widget interaction triggers
/// a background Dart execution (e.g. button tap on the widget).
@pragma('vm:entry-point')
Future<void> backgroundWidgetCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await WidgetService.update();
}

void main() {
  // ensureInitialized must be inside runZonedGuarded so it and runApp share
  // the same zone — otherwise platform-channel callbacks are dispatched to the
  // wrong zone and can be silently dropped in release builds.
  runZonedGuarded(() async {
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
    _maybeAutoBackup(); // fire-and-forget — must not block startup
    // ignore: deprecated_member_use
    HomeWidget.registerBackgroundCallback(backgroundWidgetCallback);
    await NotificationService.initTimezone();
    await NotificationService.init();
    await BreakNotificationService.init();

    AppThemeController.init(StorageService.getString(StorageKeys.themeId));
    AchievementService.init();

    if (StorageService.getBool(StorageKeys.notificationsEnabled) != false) {
      final reminders = ReminderService.getUpcomingReminders();
      await NotificationService.checkDueReminders(reminders);
    }

    FcmService.init(); // fire-and-forget
    WidgetService.update(); // fire-and-forget

    final isOnboarded =
        StorageService.getBool(StorageKeys.isOnboarded) ?? false;

    // ── Debug startup dump ─────────────────────────────────────────────────
    dLogBlock('BreakCount startup', {
      'build': kDebugMode ? 'DEBUG' : 'RELEASE',
      'onboarded': isOnboarded,
      'country': StorageService.getString(StorageKeys.selectedCountry) ?? '(none)',
      'theme': StorageService.getString(StorageKeys.themeId) ?? '(default)',
      'lastBackup': StorageService.getString(StorageKeys.lastBackupTime) ?? '(never)',
      'notifications': StorageService.getBool(StorageKeys.notificationsEnabled),
      'breakNotifs': StorageService.getBool(StorageKeys.breakNotificationsEnabled),
      'groqKey': (StorageService.getString(StorageKeys.groqApiKey)?.isNotEmpty == true)
          ? '*** set ***'
          : '(not set)',
      'deviceId': StorageService.getString(StorageKeys.deviceId) ?? '(none)',
      'scheduleEntries': () {
        final raw = StorageService.getString(StorageKeys.schedule);
        if (raw == null) return '(none)';
        return '${raw.length} bytes stored';
      }(),
    });

    runApp(BreakCountApp(
      initialRoute: isOnboarded ? Routes.home : Routes.welcome,
    ));
  }, (error, stack) {
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (_) {
      debugPrint('Uncaught error: $error\n$stack');
    }
  });
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
      debugShowCheckedModeBanner: kDebugMode,
      theme: AppTheme.build(AppThemeController.current),
      initialRoute: widget.initialRoute,
      onGenerateRoute: generateRoute,
    );
  }
}
