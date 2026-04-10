import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';

// ── Page 1: Animated title ───────────────────────────────────────────────────

class WelcomePage1 extends StatelessWidget {
  final List<AnimationController> charControllers;
  final Animation<double> lineWidth;
  final Animation<double> contentOpacity;
  final Animation<Offset> contentSlide;
  final String title1;
  final String title2;

  const WelcomePage1({
    super.key,
    required this.charControllers,
    required this.lineWidth,
    required this.contentOpacity,
    required this.contentSlide,
    required this.title1,
    required this.title2,
  });

  Widget _buildChar(String char, int index, {required bool isAccent}) {
    final ctrl = charControllers[index];
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

  @override
  Widget build(BuildContext context) {
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
                children: title1.split('').asMap().entries.map((e) {
                  return _buildChar(e.value, e.key, isAccent: false);
                }).toList(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: title2.split('').asMap().entries.map((e) {
                  return _buildChar(e.value, e.key + title1.length,
                      isAccent: true);
                }).toList(),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: lineWidth,
                builder: (ctx, child) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: lineWidth.value,
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
            opacity: contentOpacity,
            child: SlideTransition(
              position: contentSlide,
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
}

// ── Page 2: Features ─────────────────────────────────────────────────────────

class WelcomePage2 extends StatelessWidget {
  const WelcomePage2({super.key});

  static const _features = [
    (Icons.today_rounded, 'Track every break',
        'School year progress ring at a glance'),
    (Icons.grid_view_rounded, 'Manage your schedule',
        'Visual timetable with alternating week support'),
    (Icons.event_note_rounded, 'Never miss an exam',
        'Exam tracker with priority tags and countdown'),
  ];

  @override
  Widget build(BuildContext context) {
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
          ..._features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFDF0E6), AppColors.primaryLight],
                        ),
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
}
