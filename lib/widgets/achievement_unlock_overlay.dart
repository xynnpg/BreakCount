import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../data/achievements_data.dart';

/// Full-screen celebration overlay shown when an achievement is unlocked.
/// Auto-dismisses after 3 seconds or on tap.
class AchievementUnlockOverlay extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementUnlockOverlay({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  /// Shows the overlay as a route on top of the current stack.
  static Future<void> show(BuildContext context, String achievementId) async {
    final a =
        kAchievements.where((a) => a.id == achievementId).firstOrNull;
    if (a == null) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            AchievementUnlockOverlay(achievement: a),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  State<AchievementUnlockOverlay> createState() =>
      _AchievementUnlockOverlayState();
}

class _AchievementUnlockOverlayState extends State<AchievementUnlockOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _cardCtrl;
  late final AnimationController _confettiCtrl;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    _cardSlide = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.elasticOut),
    );
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _cardCtrl,
          curve: const Interval(0, 0.3, curve: Curves.easeOut)),
    );

    HapticFeedback.heavyImpact();
    _cardCtrl.forward();
    _confettiCtrl.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _dismiss();
    });
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (mounted) {
      HapticFeedback.lightImpact();
      Navigator.of(context).pop();
      widget.onDismiss?.call();
    }
  }

  Color _rarityColor() {
    switch (widget.achievement.rarity) {
      case AchievementRarity.bronze:
        return const Color(0xFFCD7F32);
      case AchievementRarity.silver:
        return const Color(0xFF9E9E9E);
      case AchievementRarity.gold:
        return const Color(0xFFFFB300);
      case AchievementRarity.platinum:
        return const Color(0xFF4FC3F7);
      case AchievementRarity.secret:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rColor = _rarityColor();

    return GestureDetector(
      onTap: _dismiss,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Dark warm overlay
            Container(color: const Color(0xCC1C1008)),
            // Confetti
            AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (context, child) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(progress: _confettiCtrl.value),
              ),
            ),
            // Centered card
            Center(
              child: AnimatedBuilder(
                animation: _cardCtrl,
                builder: (_, child) => Opacity(
                  opacity: _cardOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _cardSlide.value),
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: rColor.withAlpha(80), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: rColor.withAlpha(60),
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Achievement unlocked label
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: rColor.withAlpha(18),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'ACHIEVEMENT UNLOCKED',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: rColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Icon
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: rColor.withAlpha(20),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: rColor.withAlpha(60), width: 2),
                          ),
                          child: Icon(widget.achievement.icon,
                              size: 34, color: rColor),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          widget.achievement.name,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.achievement.description,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Tap anywhere to dismiss',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confetti particle painter with coffee/gold warm palette.
class _ConfettiPainter extends CustomPainter {
  final double progress;
  static final _rand = math.Random(42);
  static final _particles = List.generate(60, (i) => _Particle(_rand));

  const _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final y = (p.startY + progress * size.height * p.speed) % size.height;
      final x = p.startX * size.width +
          math.sin(progress * math.pi * 2 * p.wobble) * 20;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withAlpha((opacity * 200).round())
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * p.rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.w, height: p.h),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Particle {
  final double startX;
  final double startY;
  final double speed;
  final double wobble;
  final double rotation;
  final double w;
  final double h;
  final Color color;

  _Particle(math.Random r)
      : startX = r.nextDouble(),
        startY = r.nextDouble() * -0.5,
        speed = 0.4 + r.nextDouble() * 0.6,
        wobble = 0.5 + r.nextDouble() * 2,
        rotation = (r.nextBool() ? 1 : -1) * (1 + r.nextDouble() * 3),
        w = 4 + r.nextDouble() * 6,
        h = 6 + r.nextDouble() * 8,
        color = _colors[r.nextInt(_colors.length)];

  static const _colors = [
    Color(0xFF6F4E37), // coffee
    Color(0xFFFFB300), // gold
    Color(0xFFF59E0B), // amber
    Color(0xFFA0714F), // caramel
    Color(0xFF2D7A47), // success green
    Color(0xFFCD7F32), // bronze
  ];
}
