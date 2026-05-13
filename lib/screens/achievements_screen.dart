import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';
import '../app/persona_theme_ext.dart';
import '../data/achievements_data.dart';
import '../services/achievement_service.dart';
import '../services/quest_service.dart';
import '../services/streak_service.dart';
import '../services/xp_service.dart';
import '../widgets/achievement_card_share.dart';

/// Full-view Achievements screen (v2.1.0).
///
/// Structure (single CustomScrollView):
///   1. Header (back, title, level/XP, streak pill).
///   2. XP progress bar + level tiers.
///   3. Daily Quests strip.
///   4. Filter chips (All / Unlocked / Locked / Secret / Recent + category
///      chips).
///   5. Search field.
///   6. Rarity-sorted grid of achievement cards.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

enum _Filter { all, unlocked, locked, secret, recent }

class _AchievementsScreenState extends State<AchievementsScreen> {
  _Filter _filter = _Filter.all;
  AchievementCategory? _categoryFilter;
  String _search = '';
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    QuestService.revision.addListener(_forceRebuild);
    StreakService.currentNotifier.addListener(_forceRebuild);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    QuestService.revision.removeListener(_forceRebuild);
    StreakService.currentNotifier.removeListener(_forceRebuild);
    super.dispose();
  }

  void _forceRebuild() {
    if (mounted) setState(() {});
  }

  List<Achievement> _visibleAchievements() {
    final search = _search.trim().toLowerCase();
    Iterable<Achievement> list = kAchievements;
    if (_filter == _Filter.unlocked) {
      list = list.where((a) => AchievementService.isUnlocked(a.id));
    } else if (_filter == _Filter.locked) {
      list = list.where((a) => !AchievementService.isUnlocked(a.id));
    } else if (_filter == _Filter.secret) {
      list = list.where((a) => a.isSecret);
    } else if (_filter == _Filter.recent) {
      final recent = [...AchievementService.allUnlocks]
        ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
      final recentIds = recent.take(10).map((u) => u.id).toSet();
      list = list.where((a) => recentIds.contains(a.id));
    }
    if (_categoryFilter != null) {
      list = list.where((a) => a.category == _categoryFilter);
    }
    if (search.isNotEmpty) {
      list = list.where((a) =>
          a.name.toLowerCase().contains(search) ||
          a.description.toLowerCase().contains(search));
    }
    final result = list.toList();
    // Sort: rarity (Platinum→Bronze→Secret) then name.
    result.sort((a, b) {
      final r = a.rarity.sortOrder - b.rarity.sortOrder;
      if (r != 0) return r;
      return a.name.compareTo(b.name);
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(theme)),
            SliverToBoxAdapter(child: _buildLevelBar(theme)),
            SliverToBoxAdapter(child: _buildQuestsStrip(theme)),
            SliverToBoxAdapter(child: _buildFilters(theme)),
            SliverToBoxAdapter(child: _buildSearch(theme)),
            _buildGrid(theme),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(ThemeData theme) {
    final total = kAchievements.length;
    final unlocked = AchievementService.allUnlocks.length;
    final rank = AchievementService.getRank();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: theme.dividerTheme.color ?? AppColors.surfaceBorder),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: 18, color: theme.colorScheme.onSurface),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achievements',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '$unlocked / $total unlocked · $rank',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          _StreakChip(),
        ],
      ),
    );
  }

  // ── Level progress bar ──────────────────────────────────────────────────
  Widget _buildLevelBar(ThemeData theme) {
    final level = XpService.level();
    final xp = XpService.totalXp();
    final progress = XpService.progress();
    final tint = context.personaTint;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Level $level · ${XpService.rankName()}',
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface),
              ),
              const Spacer(),
              Text(
                '$xp XP',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.dividerTheme.color?.withAlpha(80) ??
                  AppColors.surfaceBorder,
              valueColor: AlwaysStoppedAnimation<Color>(tint),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${XpService.xpToNextLevel()} XP to next level',
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withAlpha(130),
            ),
          ),
        ],
      ),
    );
  }

  // ── Daily quests strip ──────────────────────────────────────────────────
  Widget _buildQuestsStrip(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: FutureBuilder<List<Quest>>(
        future: QuestService.today(),
        builder: (ctx, snap) {
          final quests = snap.data ?? const <Quest>[];
          if (quests.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DAILY QUESTS',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withAlpha(140),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: quests.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) => _QuestCard(quest: quests[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Filter chips ────────────────────────────────────────────────────────
  Widget _buildFilters(ThemeData theme) {
    final chips = <Widget>[];
    void addChip(String label, bool selected, VoidCallback onTap) {
      chips.add(Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          labelStyle: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
        ),
      ));
    }

    addChip('All', _filter == _Filter.all && _categoryFilter == null, () {
      setState(() {
        _filter = _Filter.all;
        _categoryFilter = null;
      });
    });
    addChip('Unlocked', _filter == _Filter.unlocked,
        () => setState(() => _filter = _Filter.unlocked));
    addChip('Locked', _filter == _Filter.locked,
        () => setState(() => _filter = _Filter.locked));
    addChip('Recent', _filter == _Filter.recent,
        () => setState(() => _filter = _Filter.recent));
    addChip('Secret', _filter == _Filter.secret,
        () => setState(() => _filter = _Filter.secret));
    for (final cat in AchievementCategory.values) {
      addChip(cat.label, _categoryFilter == cat, () {
        setState(() {
          _categoryFilter = _categoryFilter == cat ? null : cat;
        });
      });
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: chips,
      ),
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────
  Widget _buildSearch(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _search = v),
        style: GoogleFonts.outfit(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search achievements…',
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: _search.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                  },
                ),
        ),
      ),
    );
  }

  // ── Grid ────────────────────────────────────────────────────────────────
  Widget _buildGrid(ThemeData theme) {
    final items = _visibleAchievements();
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Text(
              'Nothing matches.',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => _AchievementTile(
            achievement: items[i],
            unlocked: AchievementService.isUnlocked(items[i].id),
            onTap: () => _showDetail(items[i]),
          ),
          childCount: items.length,
        ),
      ),
    );
  }

  Future<void> _showDetail(Achievement a) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AchievementDetailSheet(achievement: a),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subwidgets
// ─────────────────────────────────────────────────────────────────────────────

class _StreakChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: StreakService.currentNotifier,
      builder: (ctx, streak, _) {
        if (streak <= 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB300).withAlpha(30),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: const Color(0xFFFFB300).withAlpha(80)),
          ),
          child: Text(
            '🔥 $streak',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB35B00),
            ),
          ),
        );
      },
    );
  }
}

class _QuestCard extends StatefulWidget {
  final Quest quest;
  const _QuestCard({required this.quest});

  @override
  State<_QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<_QuestCard> {
  @override
  Widget build(BuildContext context) {
    final q = widget.quest;
    final theme = Theme.of(context);
    final tint = context.personaTint;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: q.isComplete
              ? tint.withAlpha(160)
              : (theme.dividerTheme.color ?? AppColors.surfaceBorder),
          width: q.isComplete ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(q.template.icon, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              Text(
                '+${q.template.xp} XP',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: tint,
                ),
              ),
            ],
          ),
          Text(
            q.template.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            q.template.hint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withAlpha(140),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: q.fraction,
              minHeight: 5,
              backgroundColor: theme.dividerTheme.color?.withAlpha(80) ??
                  AppColors.surfaceBorder,
              valueColor: AlwaysStoppedAnimation<Color>(tint),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  final VoidCallback onTap;

  const _AchievementTile({
    required this.achievement,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rColor = achievement.rarity.color;
    final isSecretLocked = achievement.isSecret && !unlocked;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: unlocked
                ? rColor.withAlpha(120)
                : (theme.dividerTheme.color ?? AppColors.surfaceBorder),
            width: unlocked ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (unlocked ? rColor : Colors.grey).withAlpha(24),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (unlocked ? rColor : Colors.grey).withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isSecretLocked
                    ? Icons.question_mark_rounded
                    : achievement.icon,
                size: 22,
                color: unlocked ? rColor : Colors.grey.shade500,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                isSecretLocked ? '???' : achievement.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: unlocked
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withAlpha(160),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: rColor.withAlpha(unlocked ? 40 : 18),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                achievement.rarity.label.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: rColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet that shows rich detail + share + compare CTAs.
class AchievementDetailSheet extends StatelessWidget {
  final Achievement achievement;
  const AchievementDetailSheet({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = achievement;
    final unlocked = AchievementService.isUnlocked(a.id);
    final unlock = AchievementService.getUnlock(a.id);
    final rColor = a.rarity.color;
    final isSecretLocked = a.isSecret && !unlocked;
    final countFor = a.isCountBased ? AchievementService.getCount(a.id) : 0;
    final progress =
        a.isCountBased ? (countFor / a.goal).clamp(0.0, 1.0) : (unlocked ? 1.0 : 0.0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerTheme.color ?? AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: rColor.withAlpha(32),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: rColor.withAlpha(100), width: 2),
                  ),
                  child: Icon(
                    isSecretLocked ? Icons.question_mark_rounded : a.icon,
                    size: 28,
                    color: rColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSecretLocked ? '???' : a.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${a.rarity.label} · ${a.category.label} · ${a.effectiveXp} XP',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withAlpha(160),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isSecretLocked
                  ? 'This achievement is hidden. Keep exploring to reveal it.'
                  : a.description,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withAlpha(200),
                height: 1.4,
              ),
            ),
            if (a.isCountBased) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: theme.dividerTheme.color?.withAlpha(80) ??
                      AppColors.surfaceBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(rColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$countFor / ${a.goal}',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ],
            if (unlock != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Unlocked ${_formatDate(unlock.unlockedAt)}',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (unlocked)
              FilledButton.icon(
                onPressed: () {
                  AchievementCardShare.exportAndShare(context, a);
                },
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: Text('Share'),
              )
            else
              OutlinedButton(
                onPressed: null,
                child: Text(
                  'Locked — keep going!',
                  style: GoogleFonts.outfit(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    if (diff < 7) return '$diff days ago';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
