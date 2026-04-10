import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../data/achievements_data.dart';
import '../services/achievement_service.dart';
import 'achievements_card.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _tabs = const [
    Tab(text: 'All'),
    Tab(text: 'School'),
    Tab(text: 'Monday'),
    Tab(text: 'Exams'),
    Tab(text: 'Secret'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<Achievement> _filtered(AchievementCategory? cat) {
    if (cat == null) return kAchievements;
    return kAchievements.where((a) => a.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final unlockCount = AchievementService.allUnlocks.length;
    final total = kAchievements.length;
    final rank = AchievementService.getRank();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surfaceBorder),
                        boxShadow: const [AppElevation.low],
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievements',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '$unlockCount / $total unlocked — $rank',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: total > 0 ? unlockCount / total : 0,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceBorder,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TabBar(
              controller: _tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle:
                  GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 13),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              tabs: _tabs,
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  AchievementGrid(achievements: _filtered(null)),
                  AchievementGrid(
                      achievements: _filtered(AchievementCategory.school)),
                  AchievementGrid(
                      achievements: _filtered(AchievementCategory.monday)),
                  AchievementGrid(
                      achievements: _filtered(AchievementCategory.exams)
                        ..addAll(_filtered(AchievementCategory.breaks))
                        ..addAll(_filtered(AchievementCategory.powerUser))),
                  AchievementGrid(
                      achievements:
                          kAchievements.where((a) => a.isSecret).toList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
