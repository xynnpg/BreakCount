import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app/constants.dart';
import '../data/achievements_data.dart';
import '../services/achievement_service.dart';
import '../widgets/glassmorphic_card.dart';

// ── Grid ──────────────────────────────────────────────────────────────────────

class AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;
  const AchievementGrid({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.88,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, i) =>
          AchievementCard(achievement: achievements[i]),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const AchievementCard({super.key, required this.achievement});

  Color _rarityColor() {
    switch (achievement.rarity) {
      case AchievementRarity.bronze:
        return const Color(0xFFCD7F32);
      case AchievementRarity.silver:
        return const Color(0xFF9E9E9E);
      case AchievementRarity.gold:
        return const Color(0xFFFFB300);
      case AchievementRarity.platinum:
        return const Color(0xFF4FC3F7);
      case AchievementRarity.secret:
        return AppColors.textTertiary;
    }
  }

  String _rarityLabel() {
    switch (achievement.rarity) {
      case AchievementRarity.bronze:
        return 'Bronze';
      case AchievementRarity.silver:
        return 'Silver';
      case AchievementRarity.gold:
        return 'Gold';
      case AchievementRarity.platinum:
        return 'Platinum';
      case AchievementRarity.secret:
        return 'Secret';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlock = AchievementService.getUnlock(achievement.id);
    final isUnlocked = unlock != null;
    final isSecret = achievement.isSecret && !isUnlocked;
    final rColor = _rarityColor();
    final count = achievement.isCountBased
        ? AchievementService.getCount(achievement.id)
        : 0;

    return GlassmorphicCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: isUnlocked ? rColor.withAlpha(80) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? rColor.withAlpha(20)
                      : AppColors.surfaceBorder.withAlpha(80),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: ColorFiltered(
                  colorFilter: isUnlocked
                      ? ColorFilter.mode(
                          Colors.transparent, BlendMode.multiply)
                      : const ColorFilter.matrix([
                          0.2, 0.2, 0.2, 0, 0,
                          0.2, 0.2, 0.2, 0, 0,
                          0.2, 0.2, 0.2, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                  child: Icon(
                    achievement.icon,
                    size: 22,
                    color: isUnlocked ? rColor : AppColors.textTertiary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: rColor.withAlpha(isUnlocked ? 20 : 10),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  _rarityLabel(),
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isUnlocked ? rColor : AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isSecret ? '???' : achievement.name,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color:
                  isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              isSecret ? 'Unlock to reveal' : achievement.description,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: AppColors.textTertiary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (achievement.isCountBased && !isUnlocked) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: (count / achievement.goal).clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: AppColors.surfaceBorder,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$count/${achievement.goal}',
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ] else if (isUnlocked) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              DateFormat('d MMM yyyy').format(unlock.unlockedAt),
              style: GoogleFonts.outfit(
                fontSize: 9,
                color: rColor.withAlpha(180),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
