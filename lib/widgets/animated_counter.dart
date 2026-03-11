import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';

/// Flip-clock countdown using the light indigo theme.
class AnimatedCounter extends StatelessWidget {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final bool showSeconds;

  const AnimatedCounter({
    super.key,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.showSeconds = true,
  });

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.primary;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CountUnit(value: days, label: 'DAYS', accentColor: accent),
          _Separator(),
          _CountUnit(value: hours, label: 'HRS', accentColor: accent),
          _Separator(),
          _CountUnit(value: minutes, label: 'MIN', accentColor: accent),
          if (showSeconds) ...[
            _Separator(),
            _CountUnit(value: seconds, label: 'SEC', accentColor: accent),
          ],
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22, left: 3, right: 3),
      child: Text(
        ':',
        style: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w300,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _CountUnit extends StatelessWidget {
  final int value;
  final String label;
  final Color accentColor;

  const _CountUnit(
      {required this.value,
      required this.label,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final twoDigit = value.toString().padLeft(2, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FlipDigit(digit: twoDigit[0], accentColor: accentColor),
            const SizedBox(width: 4),
            _FlipDigit(digit: twoDigit[1], accentColor: accentColor),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _FlipDigit extends StatefulWidget {
  final String digit;
  final Color accentColor;
  const _FlipDigit({required this.digit, required this.accentColor});

  @override
  State<_FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<_FlipDigit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideOut;
  late final Animation<double> _slideIn;
  String _currentDigit = '';
  String _previousDigit = '';

  @override
  void initState() {
    super.initState();
    _currentDigit = widget.digit;
    _previousDigit = widget.digit;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 480),
      vsync: this,
    );
    _slideOut = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.45, curve: Curves.easeIn),
      ),
    );
    _slideIn = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void didUpdateWidget(_FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != oldWidget.digit) {
      _previousDigit = _currentDigit;
      _currentDigit = widget.digit;
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final showPrev = _controller.value < 0.5;
        final offset = showPrev ? _slideOut.value : _slideIn.value;
        final digit = showPrev ? _previousDigit : _currentDigit;
        return Transform.translate(
          offset: Offset(0, offset * 16),
          child: Opacity(
            opacity: (1 - offset.abs()).clamp(0.0, 1.0),
            child: _buildDigitCard(digit),
          ),
        );
      },
    );
  }

  Widget _buildDigitCard(String digit) {
    return Container(
      width: 56,
      height: 74,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBF8), Color(0xFFFFF2E8)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
          const BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: GoogleFonts.outfit(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1,
          letterSpacing: -1.5,
        ),
      ),
    );
  }
}
