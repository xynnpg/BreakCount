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
        vsync: this,
        duration: const Duration(milliseconds: 380),
      );
    });

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentOpacity =
        CurvedAnimation(parent: _contentController, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _contentController, curve: Curves.easeOutCubic));

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
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
    for (final c in _charControllers) {
      c.dispose();
    }
    _contentController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedChar(String char, int index,
      {required bool isAccent}) {
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
              color:
                  isAccent ? AppColors.primary : AppColors.textPrimary,
              height: 1.0,
              letterSpacing: -2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
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
            return _buildAnimatedChar(
                e.value, e.key + _title1.length,
                isAccent: true);
          }).toList(),
        ),
        const SizedBox(height: 10),
        // Animated accent line under the title
        AnimatedBuilder(
          animation: _lineWidth,
          builder: (ctx, _) => FractionallySizedBox(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              _buildTitle(),
              const SizedBox(height: AppSpacing.xl),
              FadeTransition(
                opacity: _contentOpacity,
                child: SlideTransition(
                  position: _contentSlide,
                  child: _buildTagline(),
                ),
              ),
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _contentOpacity,
                child: _buildGetStartedButton(context),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Column(
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
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: () => Navigator.pushReplacementNamed(
            context, Routes.countrySelection),
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
          'Get Started',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
