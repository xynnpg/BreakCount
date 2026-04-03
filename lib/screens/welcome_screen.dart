import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../app/routes.dart';
import 'welcome_pages.dart';
import 'welcome_google_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _title1 = 'Break';
  static const _title2 = 'Count.';

  late final List<AnimationController> _charControllers;
  late final AnimationController _contentController;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final AnimationController _lineController;
  late final Animation<double> _lineWidth;

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
    }
    // Page 3 drives its own navigation via WelcomePage3Google callbacks
  }

  void _goToCountrySelection() {
    Navigator.pushReplacementNamed(context, Routes.countrySelection);
  }

  void _onGoogleSignInDone(bool hasBackup) {
    if (hasBackup) {
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      Navigator.pushReplacementNamed(context, Routes.countrySelection);
    }
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
    final isOnGooglePage = _currentPage == 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button row — hidden on page 3 (that page has its own skip)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isOnGooglePage)
                    TextButton(
                      onPressed: _goToCountrySelection,
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
                  WelcomePage1(
                    charControllers: _charControllers,
                    lineWidth: _lineWidth,
                    contentOpacity: _contentOpacity,
                    contentSlide: _contentSlide,
                    title1: _title1,
                    title2: _title2,
                  ),
                  const WelcomePage2(),
                  WelcomePage3Google(
                    onSkip: _goToCountrySelection,
                    onConnected: _onGoogleSignInDone,
                  ),
                ],
              ),
            ),
            // Bottom: dots + Next button — hidden on page 3
            if (!isOnGooglePage)
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
                          'Next',
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
              )
            else
              const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
