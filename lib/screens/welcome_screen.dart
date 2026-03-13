import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../app/routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Page 1 title animation controllers
  late final List<AnimationController> _charControllers;
  late final AnimationController _contentController;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final AnimationController _lineController;
  late final Animation<double> _lineWidth;

  static const _title1 = 'Break';
  static const _title2 = 'Count.';

  @override
  void initState() {
    super.initState();
    final totalChars = _title1.length + _title2.length;
    _charControllers = List.generate(totalChars, (_) {
      return AnimationController(
          vsync: this, duration: const Duration(milliseconds: 380));
    });
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _contentOpacity =
        CurvedAnimation(parent: _contentController, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _contentController, curve: Curves.easeOutCubic));
    _lineController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _lineWidth =
        CurvedAnimation(parent: _lineController, curve: Curves.easeOutCubic);
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    for (int i = 0; i < _charControllers.length; i++) {
      if (!mounted) return;
      _charControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 48));
    }
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    _lineController.forward();
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _charControllers) {
      c.dispose();
    }
    _contentController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _getStarted();
    }
  }

  void _getStarted() {
    Navigator.pushReplacementNamed(context, Routes.countrySelection);
  }

  Widget _buildAnimatedChar(String char, int index, {required bool isAccent}) {
    final ctrl = _charControllers[index];
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic));
    final fade = CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    return ClipRect(
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Text(
            char,
            style: GoogleFonts.outfit(
              fontSize: 76,
              fontWeight: FontWeight.w800,
              color: isAccent ? AppColors.primary : AppColors.textPrimary,
              height: 1.0,
              letterSpacing: -2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _title1.split('').asMap().entries.map((e) {
                  return _buildAnimatedChar(e.value, e.key, isAccent: false);
                }).toList(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _title2.split('').asMap().entries.map((e) {
                  return _buildAnimatedChar(e.value, e.key + _title1.length,
                      isAccent: true);
                }).toList(),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _lineWidth,
                builder: (ctx, child) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _lineWidth.value,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          FadeTransition(
            opacity: _contentOpacity,
            child: SlideTransition(
              position: _contentSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your countdown to freedom.',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Track school breaks, manage your schedule,\nand stay ahead — all offline.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    const features = [
      (Icons.today_rounded, 'Track every break',
          'School year progress ring at a glance'),
      (Icons.grid_view_rounded, 'Manage your schedule',
          'Visual timetable with alternating week support'),
      (Icons.event_note_rounded, 'Never miss an exam',
          'Exam tracker with priority tags and countdown'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          Text(
            'Everything you need.',
            style: GoogleFonts.outfit(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -1.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(f.$1, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.$2,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              )),
                          Text(f.$3,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppColors.textTertiary,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Text(
            'Almost there!',
            style: GoogleFonts.outfit(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -1.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Select your country to load accurate\nschool year data and break dates.',
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Flag showcase
          Row(
            children: ['🇷🇴', '🇬🇧', '🇺🇸', '🇩🇪', '🇫🇷'].map((flag) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Center(
                  child: Text(flag, style: const TextStyle(fontSize: 22)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '34 countries supported',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surfaceBorder,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button row
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isLast)
                    TextButton(
                      onPressed: _getStarted,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.outfit(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 36),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),
            // Bottom: dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildDots()],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isLast ? 'Get Started' : 'Next',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
