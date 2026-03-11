import 'package:flutter/material.dart';
import '../app/constants.dart';

/// Clean white card with subtle border and shadow — replaces the old glassmorphism card.
/// The constructor signature is kept fully compatible so all call sites continue to work.
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
  });

  @override
  State<GlassmorphicCard> createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _translateY;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _translateY = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.7, curve: Curves.easeOut)),
    );

    if (widget.animate) {
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _translateY.value),
          child: child,
        ),
      ),
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFDF8F4)],
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor ?? const Color(0xFFEDD9C8),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D6F4E37),
            blurRadius: 24,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: widget.padding,
      child: widget.child,
    );
  }
}
