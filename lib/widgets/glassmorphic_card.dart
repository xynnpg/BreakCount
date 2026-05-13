import 'package:flutter/material.dart';
import '../app/constants.dart';
import '../app/theme_preset.dart';

/// Premium warm card — upgraded gradient, gradient border (inset light source),
/// named shadow tokens, snappier entrance, optional press-scale feedback.
/// Constructor signature kept fully compatible so all call sites continue to work.
class GlassmorphicCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  // Legacy params accepted but not used for blur:
  final double blurSigma;
  final double opacity;
  final bool animate;
  final int animationDelay;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppRadius.lg,
    this.blurSigma = 0,
    this.opacity = 1.0,
    this.animate = true,
    this.animationDelay = 0,
    this.borderColor,
    this.onTap,
  });

  @override
  State<GlassmorphicCard> createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pressController;
  late final Animation<double> _translateY;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _translateY = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutQuart),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0, 0.7, curve: Curves.easeOut)),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );

    if (widget.animate) {
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted) _entranceController.forward();
      });
    } else {
      _entranceController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _pressController.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _pressController]),
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _translateY.value),
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        ),
      ),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _onTapDown : null,
        onTapUp: widget.onTap != null ? _onTapUp : null,
        onTapCancel: widget.onTap != null ? _onTapCancel : null,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    final style = AppThemeController.current.style;
    final radius = BorderRadius.circular(
        widget.borderRadius != AppRadius.lg ? widget.borderRadius : style.cardBorderRadius);
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    // Soft gradient blends the surface with a slightly warmer tint toward the
    // bottom-right for light themes, or slightly lighter for dark themes.
    final gradTop = surface;
    final gradMid = isDark
        ? Color.alphaBlend(Colors.white.withAlpha(8), surface)
        : Color.alphaBlend(const Color(0xFFFFF8EF).withAlpha(160), surface);
    final gradBottom = isDark
        ? Color.alphaBlend(Colors.white.withAlpha(14), surface)
        : Color.alphaBlend(const Color(0xFFFDF5EE).withAlpha(200), surface);

    // Shadow with intensity from ThemeStyle
    final shadows = <BoxShadow>[];
    if (style.shadowIntensity > 0) {
      shadows.add(BoxShadow(
        color: AppElevation.mid.color.withAlpha(
            ((AppElevation.mid.color.a * 255) * style.shadowIntensity).round().clamp(0, 255)),
        blurRadius: AppElevation.mid.blurRadius,
        offset: AppElevation.mid.offset,
      ));
      shadows.add(BoxShadow(
        color: AppElevation.ambient.color.withAlpha(
            ((AppElevation.ambient.color.a * 255) * style.shadowIntensity).round().clamp(0, 255)),
        blurRadius: AppElevation.ambient.blurRadius,
        offset: AppElevation.ambient.offset,
      ));
    }
    // Glow effect
    if (style.useGlow && style.glowIntensity > 0) {
      shadows.add(BoxShadow(
        color: primary.withAlpha((style.glowIntensity * 40).round()),
        blurRadius: 16,
        spreadRadius: 1,
      ));
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadows.isEmpty ? null : shadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: _GradientBorderPainter(
            radius: radius.topLeft.x,
            borderColor: widget.borderColor ??
                (isDark
                    ? theme.dividerTheme.color ?? const Color(0xFF2A3040)
                    : null),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
                colors: [gradTop, gradMid, gradBottom],
              ),
              borderRadius: radius,
            ),
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Paints a gradient border that simulates a top-left light source.
class _GradientBorderPainter extends CustomPainter {
  final double radius;
  final Color? borderColor;

  const _GradientBorderPainter({required this.radius, this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: borderColor != null
            ? [borderColor!, borderColor!.withAlpha(160)]
            : const [Color(0xFFEDD9C8), Color(0xFFF5E6D8)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter old) =>
      old.radius != radius || old.borderColor != borderColor;
}
