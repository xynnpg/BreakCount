import 'package:flutter/material.dart';
import '../app/constants.dart';

/// Animated gradient-sweep skeleton placeholder.
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = AppRadius.sm,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 0.5, 0),
              end: Alignment(_animation.value + 0.5, 0),
              colors: const [
                AppColors.bgSurface,
                Color(0xFFEDD9C8),
                AppColors.bgSurface,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A full-screen skeleton layout for the counter tab.
class CounterShimmer extends StatelessWidget {
  const CounterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          const ShimmerLoading(width: 200, height: 18, borderRadius: AppRadius.sm),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    const ShimmerLoading(width: 52, height: 68, borderRadius: AppRadius.sm),
                    const SizedBox(height: 6),
                    const ShimmerLoading(width: 40, height: 10),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const ShimmerLoading(height: 200, borderRadius: AppRadius.lg),
          const SizedBox(height: AppSpacing.md),
          const ShimmerLoading(height: 80, borderRadius: AppRadius.lg),
          const SizedBox(height: AppSpacing.md),
          const ShimmerLoading(height: 120, borderRadius: AppRadius.lg),
        ],
      ),
    );
  }
}
