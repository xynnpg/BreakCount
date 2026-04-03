import 'dart:math' as math;
import 'package:flutter/material.dart';

class CrackLine {
  final Offset origin;
  final double angle;
  final double length;
  final bool hasBranch;
  final double branchAngle;
  final double branchStartFraction;

  const CrackLine({
    required this.origin,
    required this.angle,
    required this.length,
    this.hasBranch = false,
    this.branchAngle = 0,
    this.branchStartFraction = 0.6,
  });
}

class GlassShard {
  final List<Offset> polygon;
  final Offset velocity;
  final double rotationSpeed;

  const GlassShard({
    required this.polygon,
    required this.velocity,
    required this.rotationSpeed,
  });
}

/// Generates a unique set of cracks and shards from a seed + impact point.
List<CrackLine> generateCracks(Offset impact, int seed) {
  final rng = math.Random(seed);
  final lines = <CrackLine>[];
  const count = 10;
  final baseAngle = 2 * math.pi / count;

  for (int i = 0; i < count; i++) {
    final angle = baseAngle * i + (rng.nextDouble() - 0.5) * (math.pi / 6);
    final length = 80 + rng.nextDouble() * 120; // 80–200 px
    final hasBranch = length > 130;
    final branchAngle = angle + (rng.nextDouble() - 0.5) * (math.pi / 4);
    lines.add(CrackLine(
      origin: impact,
      angle: angle,
      length: length,
      hasBranch: hasBranch,
      branchAngle: branchAngle,
      branchStartFraction: 0.5 + rng.nextDouble() * 0.2,
    ));
  }
  return lines;
}

List<GlassShard> generateShards(Offset impact, int seed) {
  final rng = math.Random(seed + 1);
  final shards = <GlassShard>[];
  const count = 18;
  final baseAngle = 2 * math.pi / count;

  for (int i = 0; i < count; i++) {
    final angle = baseAngle * i + (rng.nextDouble() - 0.5) * baseAngle;
    final dist = 20 + rng.nextDouble() * 60;
    final center = impact + Offset(
      math.cos(angle) * dist,
      math.sin(angle) * dist,
    );

    // Build a small convex polygon (4–6 points)
    final ptCount = 4 + rng.nextInt(3);
    final polygon = <Offset>[];
    final radius = 6 + rng.nextDouble() * 14;
    for (int j = 0; j < ptCount; j++) {
      final a = (2 * math.pi / ptCount) * j + rng.nextDouble() * 0.4;
      final r = radius * (0.7 + rng.nextDouble() * 0.5);
      polygon.add(center + Offset(math.cos(a) * r, math.sin(a) * r));
    }

    final speed = 40 + rng.nextDouble() * 80;
    final velocity = Offset(
      math.cos(angle) * speed,
      math.sin(angle) * speed + 30, // slight downward gravity
    );

    shards.add(GlassShard(
      polygon: polygon,
      velocity: velocity,
      rotationSpeed: (rng.nextDouble() - 0.5) * 4,
    ));
  }
  return shards;
}

class CrackPainter extends CustomPainter {
  final List<CrackLine> cracks;
  final List<GlassShard> shards;
  final double crackProgress; // 0→1 cracks grow
  final double shardProgress; // 0→1 shards drift + fade
  final bool reversing;

  const CrackPainter({
    required this.cracks,
    required this.shards,
    required this.crackProgress,
    required this.shardProgress,
    required this.reversing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveCrack = reversing ? 1 - crackProgress : crackProgress;
    final effectiveShard = reversing ? 1 - shardProgress : shardProgress;

    _paintCracks(canvas, effectiveCrack);
    if (effectiveShard > 0) _paintShards(canvas, effectiveShard);
  }

  void _paintCracks(Canvas canvas, double progress) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = const Color(0xDD1A0A00)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final crack in cracks) {
      final drawn = crack.length * progress;
      final end = crack.origin +
          Offset(math.cos(crack.angle) * drawn,
              math.sin(crack.angle) * drawn);

      // Main crack line — taper width
      paint.strokeWidth = 2.5 * (1 - progress * 0.5);
      glowPaint.strokeWidth = paint.strokeWidth + 2;

      canvas.drawLine(crack.origin, end, glowPaint);
      canvas.drawLine(crack.origin, end, paint);

      // Branch — starts at branchStartFraction of the drawn length
      if (crack.hasBranch && progress > crack.branchStartFraction) {
        final branchStart = crack.origin +
            Offset(math.cos(crack.angle) * crack.length * crack.branchStartFraction,
                math.sin(crack.angle) * crack.length * crack.branchStartFraction);
        final branchProgress =
            (progress - crack.branchStartFraction) / (1 - crack.branchStartFraction);
        final branchLen = crack.length * 0.5 * branchProgress.clamp(0, 1);
        final branchEnd = branchStart +
            Offset(math.cos(crack.branchAngle) * branchLen,
                math.sin(crack.branchAngle) * branchLen);

        paint.strokeWidth = 1.5 * (1 - progress * 0.5);
        glowPaint.strokeWidth = paint.strokeWidth + 1.5;

        canvas.drawLine(branchStart, branchEnd, glowPaint);
        canvas.drawLine(branchStart, branchEnd, paint);
      }
    }
  }

  void _paintShards(Canvas canvas, double progress) {
    final opacity = progress < 0.7 ? 1.0 : (1 - (progress - 0.7) / 0.3);
    if (opacity <= 0) return;

    final fillPaint = Paint()
      ..color = Color.fromARGB(
          (0x44 * opacity).round(), 220, 220, 240)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Color.fromARGB(
          (0x99 * opacity).round(), 180, 180, 200)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (final shard in shards) {
      canvas.save();

      // Translate + rotate the shard
      final center = shard.polygon.reduce((a, b) => a + b) / shard.polygon.length.toDouble();
      final offset = shard.velocity * progress;
      final rotation = shard.rotationSpeed * progress;

      canvas.translate(center.dx + offset.dx, center.dy + offset.dy);
      canvas.rotate(rotation);

      final path = Path();
      final local = shard.polygon.map((p) => p - center).toList();
      path.moveTo(local.first.dx, local.first.dy);
      for (final pt in local.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CrackPainter old) =>
      old.crackProgress != crackProgress ||
      old.shardProgress != shardProgress ||
      old.reversing != reversing;
}
