import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';
import '../models/school_year.dart';
/// A small dot that optionally pulses — used in the status badge.
class CounterPulsingDot extends StatefulWidget {
  final Color color;
  final bool pulse;
  const CounterPulsingDot({super.key, required this.color, this.pulse = false});

  @override
  State<CounterPulsingDot> createState() => _CounterPulsingDotState();
}

class _CounterPulsingDotState extends State<CounterPulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 2.6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0.55, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.pulse) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(CounterPulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_ctrl.isAnimating) _ctrl.repeat();
    if (!widget.pulse && _ctrl.isAnimating) _ctrl.stop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.pulse)
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => Transform.scale(
                scale: _scale.value,
                child: Opacity(
                  opacity: _fade.value,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration:
                        BoxDecoration(color: widget.color, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: widget.color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

/// A stats item for the stats row in CounterTab — 28pt value.
class CounterStatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  const CounterStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: GoogleFonts.outfit(
                fontSize: 10, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient divider that fades at both ends — used between stats items.
class CounterGradientDivider extends StatelessWidget {
  const CounterGradientDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.surfaceBorder,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Status badge at the top of the counter tab.
class CounterStatusBadge extends StatelessWidget {
  final bool onBreak;
  final bool yearOver;
  final SchoolBreak? next;
  final String? activeBreakName;

  const CounterStatusBadge({
    super.key,
    required this.onBreak,
    required this.yearOver,
    required this.next,
    this.activeBreakName,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    Color bgColor;

    if (yearOver) {
      label = 'School year complete';
      color = AppColors.success;
      bgColor = AppColors.success.withAlpha(10);
    } else if (onBreak) {
      label = '${activeBreakName ?? 'Break'} — enjoy it!';
      color = AppColors.primary;
      bgColor = AppColors.primary.withAlpha(12);
    } else if (next != null) {
      label = 'Until ${next!.name}';
      color = AppColors.textSecondary;
      bgColor = Colors.white;
    } else {
      label = 'Until end of school year';
      color = AppColors.textSecondary;
      bgColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: onBreak
              ? AppColors.primary.withAlpha(40)
              : AppColors.surfaceBorder,
        ),
        color: bgColor,
        boxShadow: const [AppElevation.low],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CounterPulsingDot(color: color, pulse: onBreak),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
