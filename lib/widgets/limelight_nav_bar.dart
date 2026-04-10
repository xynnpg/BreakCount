import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Container(
          height: _navHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEFB), // slightly warm white
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: const Color(0xFFE8D5C4),
              width: 0.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 24,
                offset: Offset(0, -4), // upward shadow for floating feel
              ),
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 2,
                offset: Offset(0, -1), // inner top shadow — lifts bar from content
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
                      child: const _SpotlightCone(),
                    ),

                    // Coffee pill at top of nav, above active icon
                    AnimatedPositioned(
                      duration: _animDuration,
                      curve: _animCurve,
                      left: activeLeft,
                      top: 0,
                      width: pillWidth,
                      height: 4,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.vertical(
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
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
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
                                          ? AppColors.primary
                                          : const Color(0xFFA89888),
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
  const _SpotlightCone();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpotlightPainter(),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
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
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x286F4E37), // coffee/16 at top — more visible spotlight
          Color(0x006F4E37), // transparent at bottom
        ],
      ).createShader(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => false;
}

class LimelightNavItem {
  final IconData icon;
  final String label;
  const LimelightNavItem({required this.icon, required this.label});
}
