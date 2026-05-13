import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../app/persona_theme_ext.dart';

/// A floating bottom navigation bar with a limelight spotlight effect.
///
/// The active tab shows a coffee-brown pill at the top of the nav container,
/// with a trapezoidal gradient cone spreading down through the icon.
/// The pill + cone slide with AnimatedPositioned when switching tabs.
class LimelightNavBar extends StatefulWidget {
  final int currentIndex;
  final List<LimelightNavItem> items;
  final ValueChanged<int> onTap;

  const LimelightNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  State<LimelightNavBar> createState() => _LimelightNavBarState();
}

class _LimelightNavBarState extends State<LimelightNavBar> {
  static const double _navHeight = 64;
  static const Duration _animDuration = Duration(milliseconds: 300);
  static const Curve _animCurve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    final tint = context.personaTint;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Container(
          height: _navHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: theme.dividerTheme.color ?? AppColors.surfaceBorder,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : const Color(0x14000000),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
              BoxShadow(
                color: isDark ? Colors.black12 : const Color(0x08000000),
                blurRadius: 2,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / widget.items.length;
              const pillWidth = 44.0;
              final activeLeft =
                  widget.currentIndex * itemWidth + (itemWidth - pillWidth) / 2;

              return ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Spotlight cone (trapezoid gradient) behind icons
                    // Starts just below the pill (top: 4)
                    AnimatedPositioned(
                      duration: _animDuration,
                      curve: _animCurve,
                      left: widget.currentIndex * itemWidth,
                      top: 4,
                      width: itemWidth,
                      height: _navHeight - 4,
                      child: _SpotlightCone(tint: tint),
                    ),

                    // Persona-tinted pill at top of nav, above active icon
                    AnimatedPositioned(
                      duration: _animDuration,
                      curve: _animCurve,
                      left: activeLeft,
                      top: 0,
                      width: pillWidth,
                      height: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: tint,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    // Nav items row
                    Row(
                      children: List.generate(widget.items.length, (i) {
                        final selected = i == widget.currentIndex;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onTap(i);
                            },
                            child: SizedBox(
                              height: _navHeight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    scale: selected ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutBack,
                                    child: AnimatedOpacity(
                                      duration: _animDuration,
                                      opacity: selected ? 1.0 : 0.4,
                                      child: Icon(
                                        widget.items[i].icon,
                                        size: 22,
                                        color: selected
                                            ? tint
                                            : Theme.of(context).colorScheme.onSurface.withAlpha(200),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  AnimatedDefaultTextStyle(
                                    duration: _animDuration,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: selected
                                          ? tint
                                          : theme.colorScheme.onSurface.withAlpha(100),
                                    ),
                                    child: Text(widget.items[i].label),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The trapezoidal spotlight cone that glows below the pill.
/// Narrow at top (~60px span), wider at bottom (~80px span).
class _SpotlightCone extends StatelessWidget {
  final Color tint;
  const _SpotlightCone({required this.tint});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpotlightPainter(tint: tint),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Color tint;
  _SpotlightPainter({required this.tint});

  @override
  void paint(Canvas canvas, Size size) {
    // Trapezoid: 60px wide at top center → 80px wide at bottom center
    final topHalf = 30.0; // half of 60px top width
    final bottomHalf = 40.0; // half of 80px bottom width
    final centerX = size.width / 2;

    final path = Path()
      ..moveTo(centerX - topHalf, 0)
      ..lineTo(centerX + topHalf, 0)
      ..lineTo(centerX + bottomHalf, size.height)
      ..lineTo(centerX - bottomHalf, size.height)
      ..close();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          tint.withAlpha(40), // tint top — more visible spotlight
          tint.withAlpha(0),  // transparent at bottom
        ],
      ).createShader(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.tint != tint;
}

class LimelightNavItem {
  final IconData icon;
  final String label;
  const LimelightNavItem({required this.icon, required this.label});
}
