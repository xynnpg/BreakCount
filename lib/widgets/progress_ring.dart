import 'dart:math';
import 'package:flutter/material.dart';
import '../app/constants.dart';

/// Animated circular progress ring with indigo stroke on grey track.
class ProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color startColor;
  final Color endColor;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 12,
    this.startColor = AppColors.primary,
    this.endColor = const Color(0xFFA0714F), // lighter coffee/caramel
    this.child,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.progressFill,
      vsync: this,
    );
    _progressAnim = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _progressAnim,
        builder: (context, child) {
          return CustomPaint(
            painter: _RingPainter(
              progress: _progressAnim.value,
              strokeWidth: widget.strokeWidth,
              startColor: widget.startColor,
              endColor: widget.endColor,
            ),
            child: child,
          );
        },
        child: widget.child != null
            ? Center(child: widget.child!)
            : null,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color startColor;
  final Color endColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Warm tan track
    final trackPaint = Paint()
      ..color = const Color(0xFFEDD9C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    // Gradient arc
    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + sweepAngle,
        colors: [startColor, endColor],
      ).createShader(rect);

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, gradientPaint);

    // Dot at the leading edge
    final glowAngle = -pi / 2 + sweepAngle;
    final glowX = center.dx + radius * cos(glowAngle);
    final glowY = center.dy + radius * sin(glowAngle);
    final glowCenter = Offset(glowX, glowY);

    // Glow halo behind dot
    final haloPaint = Paint()
      ..color = endColor.withAlpha(50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawCircle(glowCenter, strokeWidth * 0.9, haloPaint);

    final dotPaint = Paint()..color = endColor;
    canvas.drawCircle(glowCenter, strokeWidth * 0.5, dotPaint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
