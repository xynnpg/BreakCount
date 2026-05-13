import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';
import '../app/theme_preset.dart';
import '../services/unlock_service.dart';

/// Grid of persona/theme swatches. Tapping a swatch switches the active theme.
///
/// Locked themes render greyed out with a lock icon; tapping shows a snackbar
/// explaining the unlock condition. Unlock state is computed via
/// [UnlockService], which reads StreakService + AchievementService on the fly.
class ThemePickerGrid extends StatefulWidget {
  const ThemePickerGrid({super.key});

  @override
  State<ThemePickerGrid> createState() => _ThemePickerGridState();
}

class _ThemePickerGridState extends State<ThemePickerGrid> {
  @override
  void initState() {
    super.initState();
    AppThemeController.notifier.addListener(_onChange);
  }

  @override
  void dispose() {
    AppThemeController.notifier.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  Future<void> _onTap(ThemePreset preset) async {
    if (UnlockService.isThemeUnlocked(preset.id)) {
      await AppThemeController.setTheme(preset);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          '🔒 ${preset.name}: ${UnlockService.themeUnlockHint(preset.id)}',
          style: GoogleFonts.outfit(fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = AppThemeController.current;
    // Always 3 columns to match the screenshot layout
    const crossAxisCount = 3;
    const spacing = 10.0;

    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      // BUG FIX: was 1.0 (square), screenshot shows taller cards (~0.78 ratio)
      childAspectRatio: 0.78,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: [
        for (final preset in ThemePreset.all)
          _ThemeSwatch(
            preset: preset,
            selected: preset.id == current.id,
            unlocked: UnlockService.isThemeUnlocked(preset.id),
            onTap: () => _onTap(preset),
          ),
      ],
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final ThemePreset preset;
  final bool selected;
  final bool unlocked;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.preset,
    required this.selected,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !unlocked;

    // BUG FIX: use theme's primary color for selected border,
    // fall back to a neutral border for unselected/unlocked states.
    final borderColor = selected
        ? preset.primary
        : disabled
            ? Colors.transparent
            : preset.surfaceBorder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        children: [
          // Card body — fills the full grid cell via Positioned.fill so the
          // border and gradient cover the entire tile, not just content size.
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: disabled ? const Color(0xFFB0AEA8) : null,
                gradient: disabled
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [preset.bgDeep, preset.bgSurface],
                      ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: preset.primary.withAlpha(60),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    preset.emoji,
                    style: const TextStyle(fontSize: 36),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      preset.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: disabled
                            ? Colors.white
                            : (preset.textPrimary ?? AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Locked overlay — semi-transparent dark veil + lock icon
          // BUG FIX: lock icon was inside a Positioned.fill DecoratedBox which
          // stacked ON TOP of the card content including the name label.
          // Moved to overlay only the top 70% so the name label stays readable,
          // OR kept full overlay but used a lighter alpha so text shows through.
          if (disabled)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // BUG FIX: reduced alpha from 90 → 60 so the emoji beneath
                  // is subtly visible (matches screenshot's grey-card look)
                  color: Colors.black.withAlpha(60),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      // BUG FIX: lock was 18 px and centred — screenshot shows
                      // it bottom-right at ~16 px
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),

          // Selected checkmark badge — top right corner
          if (selected)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: preset.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}