import 'package:flutter/material.dart';

enum BackgroundPattern { none, subtleGradient, radialGlow, meshGradient }

@immutable
class ThemeStyle {
  final double cardBorderRadius;
  final double shadowIntensity;
  final bool useGlow;
  final double glowIntensity;
  final BackgroundPattern bgPattern;

  const ThemeStyle({
    this.cardBorderRadius = 16,
    this.shadowIntensity = 1.0,
    this.useGlow = false,
    this.glowIntensity = 0.0,
    this.bgPattern = BackgroundPattern.none,
  });

  // ── Per-theme style presets ──────────────────────────────────────────────

  static const warm = ThemeStyle(
    cardBorderRadius: 16,
    shadowIntensity: 1.0,
    bgPattern: BackgroundPattern.subtleGradient,
  );

  static const clean = ThemeStyle(
    cardBorderRadius: 20,
    shadowIntensity: 0.5,
  );

  static const dark = ThemeStyle(
    cardBorderRadius: 16,
    shadowIntensity: 0.6,
  );

  static const pastel = ThemeStyle(
    cardBorderRadius: 16,
    shadowIntensity: 0.8,
    bgPattern: BackgroundPattern.subtleGradient,
  );

  static const neon = ThemeStyle(
    cardBorderRadius: 10,
    shadowIntensity: 0.3,
    useGlow: true,
    glowIntensity: 0.7,
    bgPattern: BackgroundPattern.radialGlow,
  );

  static const nature = ThemeStyle(
    cardBorderRadius: 14,
    shadowIntensity: 0.5,
    useGlow: true,
    glowIntensity: 0.4,
    bgPattern: BackgroundPattern.meshGradient,
  );

  static const cosmic = ThemeStyle(
    cardBorderRadius: 14,
    shadowIntensity: 0.4,
    useGlow: true,
    glowIntensity: 0.6,
    bgPattern: BackgroundPattern.meshGradient,
  );

  static const amoled = ThemeStyle(
    cardBorderRadius: 8,
    shadowIntensity: 0.0,
    useGlow: true,
    glowIntensity: 0.3,
  );
}
