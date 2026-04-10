import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../widgets/animated_counter.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/progress_ring.dart';

enum CounterRingMode { percent, days, hours, minutes, seconds, milliseconds }

// ── Progress ring ─────────────────────────────────────────────────────────────

class CounterProgressRing extends StatelessWidget {
  final double progress;
  final String ringValue;
  final String ringLabel;
  final CounterRingMode ringMode;
  final VoidCallback onTap;

  const CounterProgressRing({
    super.key,
    required this.progress,
    required this.ringValue,
    required this.ringLabel,
    required this.ringMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPercent = ringMode == CounterRingMode.percent;
    final valueSize = isPercent
        ? 30.0
        : ringMode == CounterRingMode.milliseconds
            ? 18.0
            : 24.0;

    return GestureDetector(
      onTap: onTap,
      child: ProgressRing(
        progress: progress,
        size: 192,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                ringValue.isEmpty
                    ? '${(progress * 100).round()}%'
                    : ringValue,
                key: ValueKey(ringValue + ringMode.name),
                style: GoogleFonts.outfit(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              ringLabel.isEmpty ? 'School Year' : ringLabel,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'tap to cycle',
              style: GoogleFonts.outfit(
                fontSize: 9,
                color: AppColors.textTertiary.withAlpha(120),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Countdown card ────────────────────────────────────────────────────────────

class CounterCountdownCard extends StatelessWidget {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  const CounterCountdownCard({
    super.key,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF8F5), Color(0xFFFAF3EC)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFFEDD9C8), width: 1),
        boxShadow: const [AppElevation.mid, AppElevation.ambient],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 2,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFA0714F),
                  borderRadius: BorderRadius.all(Radius.circular(1)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'COUNTDOWN',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedCounter(
            days: days,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
          ),
        ],
      ),
    );
  }
}

// ── Year-over badge ───────────────────────────────────────────────────────────

class CounterYearOverBadge extends StatelessWidget {
  const CounterYearOverBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Column(
        children: [
          Text(
            'See you next year!',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'School year is complete.',
            style: GoogleFonts.outfit(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
