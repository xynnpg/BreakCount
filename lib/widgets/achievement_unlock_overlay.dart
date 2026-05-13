import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../app/theme_preset.dart';
import '../data/achievements_data.dart';
import '../data/persona_copy.dart';
import '../data/personas_data.dart';
import '../services/storage_service.dart';

/// Full-screen celebration overlay shown when an achievement is unlocked.
/// Auto-dismisses after 3 seconds or on tap.
class AchievementUnlockOverlay extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;
  // When set, overrides the default label ("ACHIEVEMENT UNLOCKED") and tint
  // so the same overlay can announce persona unlocks.
  final String? overrideLabel;
  final Color? overrideTint;
  final String? overrideEmoji;

  const AchievementUnlockOverlay({
    super.key,
    required this.achievement,
    this.onDismiss,
    this.overrideLabel,
    this.overrideTint,
    this.overrideEmoji,
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

  /// Shows the overlay in "persona unlocked" mode — tints + label + emoji
  /// swapped. Uses a synthesized Achievement wrapper so the animation path
  /// is identical.
  static Future<void> showPersonaUnlock(
    BuildContext context,
    String personaId,
  ) async {
    final p = personaById(personaId);
    final synthetic = Achievement(
      id: 'persona_${p.id}',
      name: p.name,
      description: p.description,
      icon: Icons.face_rounded,
      rarity: AchievementRarity.platinum,
      category: AchievementCategory.powerUser,
    );
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            AchievementUnlockOverlay(
          achievement: synthetic,
          overrideLabel: 'PERSONA UNLOCKED',
          overrideTint: p.tint,
          overrideEmoji: p.emoji,
        ),
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

    _triggerPersonaHaptic();
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
    if (widget.overrideTint != null) return widget.overrideTint!;
    final base = switch (widget.achievement.rarity) {
      AchievementRarity.bronze => const Color(0xFFCD7F32),
      AchievementRarity.silver => const Color(0xFF9E9E9E),
      AchievementRarity.gold => const Color(0xFFFFB300),
      AchievementRarity.platinum => const Color(0xFF4FC3F7),
      AchievementRarity.secret => AppColors.primary,
    };
    // Blend with the active persona tint at 30% for flavor while keeping
    // the rarity cue readable.
    final tint = AppThemeController.personaTint;
    return Color.lerp(base, tint, 0.3) ?? base;
  }

  String get _personaId =>
      StorageService.getString(StorageKeys.widgetPersona) ?? 'hype';

  /// Dispatches a persona-tuned haptic on show. Hype/dramatic/menace are
  /// heavy; sage/ghost/zen are medium; chill/sarcastic are light.
  void _triggerPersonaHaptic() {
    const heavy = {'hype', 'dramatic', 'menace'};
    const medium = {'sage', 'ghost', 'zen'};
    final id = _personaId;
    if (heavy.contains(id)) {
      HapticFeedback.heavyImpact();
    } else if (medium.contains(id)) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  /// 3-color confetti palette derived from the persona tint + a rarity accent.
  /// Dramatic/menace lean darker; chill/zen lean lighter; sarcastic is
  /// intentionally bland.
  List<Color> _confettiPaletteFor(String personaId) {
    final base = personaById(personaId).tint;
    final lighter =
        Color.alphaBlend(Colors.white.withAlpha(120), base);
    final darker = Color.alphaBlend(Colors.black.withAlpha(80), base);
    final rarity = _rarityColor();
    return [base, lighter, darker, rarity];
  }

  /// Particle count per persona. Hype/dramatic dump a lot; sarcastic is
  /// deliberately sparse ("fine. whatever."); chill/zen are subtle.
  int _confettiDensityFor(String personaId) {
    switch (personaId) {
      case 'hype':
      case 'dramatic':
      case 'menace':
        return 80;
      case 'sarcastic':
        return 8;
      case 'chill':
      case 'zen':
        return 24;
      default:
        return 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rColor = _rarityColor();
    final label = widget.overrideLabel ?? 'ACHIEVEMENT UNLOCKED';
    final emoji = widget.overrideEmoji;

    return GestureDetector(
      onTap: _dismiss,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Dark warm overlay
            Container(color: const Color(0xCC1C1008)),
            // Confetti — palette + density driven by active persona.
            AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (context, child) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  progress: _confettiCtrl.value,
                  palette: _confettiPaletteFor(_personaId),
                  density: _confettiDensityFor(_personaId),
                ),
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
                            label,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: rColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Icon — emoji version for persona unlocks, icon
                        // otherwise.
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: rColor.withAlpha(20),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: rColor.withAlpha(60), width: 2),
                          ),
                          alignment: Alignment.center,
                          child: emoji != null
                              ? Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 34),
                                )
                              : Icon(widget.achievement.icon,
                                  size: 34, color: rColor),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          widget.achievement.name,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.achievement.description,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withAlpha(180),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        // Persona tagline (falls back to dismiss hint if
                        // the persona has an empty value somehow).
                        () {
                          final tagline = PersonaCopy.get(
                            _personaId,
                            'unlock_tagline',
                            fallback: 'Tap anywhere to dismiss',
                          );
                          return Text(
                            tagline,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: rColor,
                              letterSpacing: 0.5,
                            ),
                          );
                        }(),
                        const SizedBox(height: 4),
                        Text(
                          'Tap anywhere to dismiss',
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            color: theme.colorScheme.onSurface.withAlpha(120),
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

/// Confetti particle painter — palette + density are driven by the active
/// persona so hype bursts loud red-orange, sarcastic drops a lonely grey
/// square, etc.
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> palette;
  final int density;

  _ConfettiPainter({
    required this.progress,
    required this.palette,
    required this.density,
  }) : _particles = _generate(density, palette);

  final List<_Particle> _particles;

  static List<_Particle> _generate(int count, List<Color> palette) {
    // Seed per (density, palette) pair so the same persona produces the same
    // confetti shape between frames — only the progress animates.
    final seed = Object.hashAll([count, ...palette.map((c) => c.toARGB32())]);
    final r = math.Random(seed);
    return List.generate(count, (_) => _Particle(r, palette));
  }

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
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress ||
      old.density != density ||
      !_paletteEqual(old.palette, palette);

  static bool _paletteEqual(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
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

  _Particle(math.Random r, List<Color> palette)
      : startX = r.nextDouble(),
        startY = r.nextDouble() * -0.5,
        speed = 0.4 + r.nextDouble() * 0.6,
        wobble = 0.5 + r.nextDouble() * 2,
        rotation = (r.nextBool() ? 1 : -1) * (1 + r.nextDouble() * 3),
        w = 4 + r.nextDouble() * 6,
        h = 6 + r.nextDouble() * 8,
        color = palette[r.nextInt(palette.length)];
}
