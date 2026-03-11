import 'package:flutter/material.dart';
import '../app/constants.dart';

class RadarPainter extends CustomPainter {
  final double progress;

  const RadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final phases = [
      progress,
      (progress + 0.33) % 1.0,
      (progress + 0.67) % 1.0,
    ];

    for (final phase in phases) {
      final radius = maxRadius * phase;
      final opacity = (1.0 - phase) * 0.5;
      final paint = Paint()
        ..color = AppColors.primary.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, radius, paint);
    }

    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6.0, dotPaint);
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
