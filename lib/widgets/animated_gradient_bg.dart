import 'package:flutter/material.dart';
import '../app/constants.dart';

/// Previously a dark animated gradient background.
/// Now simply provides a clean `#F8FAFC` scaffold background.
/// The API (wrapping child) is kept identical so all call sites compile.
class AnimatedGradientBg extends StatelessWidget {
  final Widget child;

  const AnimatedGradientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBg,
      child: child,
    );
  }
}
