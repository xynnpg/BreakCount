import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../app/constants.dart';
import '../models/school_year.dart';
import '../services/calculator_service.dart';

enum _TimeMode { days, hours, minutes, seconds, milliseconds }

class SchoolTimePanel extends StatefulWidget {
  final SchoolYear schoolYear;
  final int schoolHoursPerDay;

  const SchoolTimePanel({
    super.key,
    required this.schoolYear,
    this.schoolHoursPerDay = 6,
  });

  @override
  State<SchoolTimePanel> createState() => _SchoolTimePanelState();
}

class _SchoolTimePanelState extends State<SchoolTimePanel>
    with SingleTickerProviderStateMixin {
  _TimeMode _mode = _TimeMode.days;
  Timer? _ticker;
  String _currentValue = '0';
  String _prevValue = '0';
  String _modeLabel = 'school days remaining';

  late final AnimationController _transCtrl;
  late final Animation<double> _slideOutOffset;
  late final Animation<double> _slideOutOpacity;
  late final Animation<double> _slideInOffset;
  late final Animation<double> _slideInOpacity;

  static final _formatter = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _transCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _slideOutOffset = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(
        parent: _transCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _slideOutOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _transCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _slideInOffset = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _transCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _slideInOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _transCtrl,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    _recompute(animate: false);
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _transCtrl.dispose();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    final interval = _mode == _TimeMode.milliseconds
        ? const Duration(milliseconds: 16)
        : const Duration(seconds: 1);
    _ticker = Timer.periodic(interval, (_) => _recompute());
  }

  void _recompute({bool animate = true}) {
    final days =
        CalculatorService.activeSchoolDaysRemaining(widget.schoolYear);
    final h = widget.schoolHoursPerDay;
    final int raw;
    switch (_mode) {
      case _TimeMode.days:
        raw = days;
        break;
      case _TimeMode.hours:
        raw = days * h;
        break;
      case _TimeMode.minutes:
        raw = days * h * 60;
        break;
      case _TimeMode.seconds:
        raw = days * h * 3600;
        break;
      case _TimeMode.milliseconds:
        final baseMs = days * h * 3600 * 1000;
        final msOffset = DateTime.now().millisecondsSinceEpoch % 1000;
        raw = baseMs + (1000 - msOffset);
        break;
    }

    final newStr = _formatValue(raw);
    if (!mounted) return;
    if (newStr != _currentValue && animate) {
      _prevValue = _currentValue;
      _currentValue = newStr;
      _transCtrl.forward(from: 0);
    } else if (!animate) {
      _currentValue = newStr;
      _prevValue = newStr;
    }
    setState(() {});
  }

  String _formatValue(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 10000) return _formatter.format(v);
    return v.toString();
  }

  double _fontSize() {
    switch (_mode) {
      case _TimeMode.days:
        return 52;
      case _TimeMode.hours:
        return 46;
      case _TimeMode.minutes:
        return 40;
      case _TimeMode.seconds:
        return 36;
      case _TimeMode.milliseconds:
        return 30;
    }
  }

  void _cycleMode() {
    final next = _TimeMode.values[(_mode.index + 1) % _TimeMode.values.length];
    _ticker?.cancel();
    setState(() {
      _mode = next;
      _modeLabel = _buildModeLabel(next);
    });
    _startTicker();
    _recompute(animate: false);
  }

  String _buildModeLabel(_TimeMode m) {
    switch (m) {
      case _TimeMode.days:
        return 'school days remaining';
      case _TimeMode.hours:
        return 'school hours remaining (${widget.schoolHoursPerDay}h/day)';
      case _TimeMode.minutes:
        return 'school minutes remaining';
      case _TimeMode.seconds:
        return 'school seconds remaining';
      case _TimeMode.milliseconds:
        return 'live milliseconds remaining';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _cycleMode,
      child: Container(
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
          border: Border.all(color: const Color(0xFFEDD9C8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A6F4E37),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ACTIVE SCHOOL TIME',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _transCtrl,
                builder: (context, child) {
                  final transitioning = _transCtrl.isAnimating;
                  return SizedBox(
                    height: _fontSize() + 12,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        if (transitioning)
                          Transform.translate(
                            offset: Offset(0, _slideOutOffset.value),
                            child: Opacity(
                              opacity: _slideOutOpacity.value,
                              child: _buildValueText(_prevValue),
                            ),
                          ),
                        Transform.translate(
                          offset: transitioning
                              ? Offset(0, _slideInOffset.value)
                              : Offset.zero,
                          child: Opacity(
                            opacity: transitioning
                                ? _slideInOpacity.value
                                : 1.0,
                            child: _buildValueText(_currentValue),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _modeLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.touch_app_outlined,
                    size: 13, color: AppColors.textTertiary),
                const SizedBox(width: 3),
                Text(
                  'tap',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueText(String value) {
    return Text(
      value,
      style: GoogleFonts.outfit(
        fontSize: _fontSize(),
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1,
        letterSpacing: -1,
      ),
    );
  }
}
