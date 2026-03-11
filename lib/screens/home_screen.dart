import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/constants.dart';
import '../services/analytics_service.dart';
import '../services/shake_service.dart';
import '../widgets/limelight_nav_bar.dart';
import '../widgets/shake_share_overlay.dart';
import 'counter_tab.dart';
import 'exams_tab.dart';
import 'schedule_tab.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final ShakeService _shakeService;
  // Static so it survives widget rebuilds and hot restarts — only one
  // ShakeMeshOverlay can ever be in the Navigator at a time.
  static bool _overlayShowing = false;

  @override
  void initState() {
    super.initState();
    _shakeService = ShakeService(onShake: _onShake);
    _shakeService.start();
  }

  @override
  void dispose() {
    _shakeService.stop();
    super.dispose();
  }

  Future<void> _onShake() async {
    if (_overlayShowing || !mounted) return;
    _overlayShowing = true;
    _shakeService.stop(); // silence ALL shake listeners while overlay is open
    if (kDebugMode) debugPrint('[HomeScreen] _onShake → pushing ShakeMeshOverlay');
    try {
      await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, a1, a2) => const ShakeMeshOverlay(),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (ctx, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
      ));
    } finally {
      if (kDebugMode) debugPrint('[HomeScreen] ShakeMeshOverlay popped — re-arming');
      _overlayShowing = false;
      if (mounted) _shakeService.start(); // re-arm after overlay closes
    }
  }

  static const List<LimelightNavItem> _navItems = [
    LimelightNavItem(icon: Icons.hourglass_top_rounded, label: 'Countdown'),
    LimelightNavItem(icon: Icons.grid_view_rounded, label: 'Schedule'),
    LimelightNavItem(icon: Icons.event_note_outlined, label: 'Exams'),
    LimelightNavItem(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  void _onTap(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    AnalyticsService.tabSwitched(i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          CounterTab(),
          ScheduleTab(),
          ExamsTab(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: LimelightNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: _onTap,
      ),
    );
  }
}
