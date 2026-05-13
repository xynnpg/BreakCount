import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../data/achievements_data.dart';
import '../data/persona_copy.dart';
import '../services/achievement_service.dart';
import '../services/storage_service.dart';
import '../widgets/glassmorphic_card.dart';

class CounterAchievementsSection extends StatelessWidget {
  const CounterAchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final unlocks = AchievementService.allUnlocks;
    final total = kAchievements.length;
    final count = unlocks.length;
    final rank = AchievementService.getRank();

    // Last 3 unlocked, sorted newest first
    final recent = [...unlocks]
      ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    final recentThree = recent.take(3).toList();

    return GlassmorphicCard(
      animationDelay: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, rank),
          const SizedBox(height: AppSpacing.sm),
          _buildProgress(context, count, total),
          const SizedBox(height: AppSpacing.md),
          count == 0 ? _buildEmpty(context) : _buildRecentIcons(context, recentThree),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String rank) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
                color: theme.colorScheme.primary.withAlpha(40), width: 1),
          ),
          child: Text(
            rank.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Achievements',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/achievements'),
          child: Row(
            children: [
              Text(
                'View All',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 11, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(BuildContext context, int count, int total) {
    final theme = Theme.of(context);
    final progress = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Theme.of(context).dividerTheme.color ?? AppColors.surfaceBorder,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$count / $total unlocked',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withAlpha(180),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    final personaId =
        StorageService.getString(StorageKeys.widgetPersona) ?? 'hype';
    final text = PersonaCopy.get(personaId, 'empty_achievements',
        fallback: 'No achievements yet — keep going!');
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 12,
        color: theme.colorScheme.onSurface.withAlpha(120),
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildRecentIcons(BuildContext context, List<AchievementUnlock> recent) {
    final theme = Theme.of(context);
    return Row(
      children: recent.map((u) {
        final ach = _findAchievement(u.id);
        if (ach == null) return const SizedBox.shrink();
        final color = ach.rarity.color;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(24),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withAlpha(80), width: 1.5),
                ),
                child: Icon(ach.icon, size: 20, color: color),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                child: Text(
                  ach.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Achievement? _findAchievement(String id) {
    try {
      return kAchievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
