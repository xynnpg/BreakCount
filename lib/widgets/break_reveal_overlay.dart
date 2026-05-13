import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/persona_copy.dart';
import '../services/achievement_service.dart';
import '../services/persona_service.dart';

/// Full-screen confetti + persona-flavored headline on the first app-open
/// after a break starts. Call [BreakRevealOverlay.show] from CounterTab after
/// storing the new active-break id.
class BreakRevealOverlay extends StatefulWidget {
  final String personaId;
  final String breakName;

  const BreakRevealOverlay({
    super.key,
    required this.personaId,
    required this.breakName,
  });

  /// Pushes the overlay as a transparent route and fires the
  /// AchievementService.onBreakReveal helper.
  static Future<void> show(
    BuildContext context, {
    required String breakName,
  }) async {
    final personaId = PersonaService.instance.current.id;
    // Track the reveal ahead of time so counters match even if user navigates
    // away mid-animation.
    unawaited(AchievementService.onBreakReveal());
    HapticFeedback.mediumImpact();
    await Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (ctx, a, b) =>
          BreakRevealOverlay(personaId: personaId, breakName: breakName),
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (ctx, anim, b, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  State<BreakRevealOverlay> createState() => _BreakRevealOverlayState();
}

class _BreakRevealOverlayState extends State<BreakRevealOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _confettiCtrl;
  late final List<_ConfettiPiece> _pieces;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    final persona = PersonaService.instance.current;
    _pieces = List.generate(
      60,
      (_) => _ConfettiPiece(
        startX: _rand.nextDouble(),
        color: _colorOptions(persona.tint)[_rand.nextInt(4)],
        delay: _rand.nextDouble() * 0.3,
        speed: 0.8 + _rand.nextDouble() * 0.6,
        drift: (_rand.nextDouble() - 0.5) * 0.4,
        rotation: _rand.nextDouble() * pi * 2,
      ),
    );
    _confettiCtrl.forward();
  }

  List<Color> _colorOptions(Color base) => [
        base,
        Color.alphaBlend(Colors.white.withAlpha(80), base),
        const Color(0xFFFFD54F),
        const Color(0xFFE91E63),
      ];

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final persona = PersonaService.instance.current;
    final copy = PersonaCopy.get(
      widget.personaId,
      'break_reveal',
      fallback: '${widget.breakName} starts now!',
    );
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Darkened tinted backdrop.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    persona.tint.withAlpha(220),
                    Color.alphaBlend(Colors.black.withAlpha(200), persona.tint),
                  ],
                ),
              ),
            ),
          ),
          // Confetti particles.
          AnimatedBuilder(
            animation: _confettiCtrl,
            builder: (ctx, _) {
              final t = _confettiCtrl.value;
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(pieces: _pieces, progress: t),
              );
            },
          ),
          // Foreground message.
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      persona.emoji,
                      style: const TextStyle(fontSize: 96),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.breakName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withAlpha(200),
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      copy,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'tap to dismiss',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withAlpha(160),
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPiece {
  final double startX;
  final Color color;
  final double delay;
  final double speed;
  final double drift;
  final double rotation;

  _ConfettiPiece({
    required this.startX,
    required this.color,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.rotation,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final local = ((progress - p.delay) * p.speed).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final x = (p.startX + p.drift * local) * size.width;
      final y = local * size.height * 1.1;
      final paint = Paint()..color = p.color.withAlpha(220);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + local * 6);
      canvas.drawRect(
        const Rect.fromLTWH(-6, -3, 12, 6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}

/// Dart equivalent of unawaited() (avoid a dart:async import just for one fn).
void unawaited(Future<dynamic> future) {}
