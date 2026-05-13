import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';
import '../data/personas_data.dart';
import '../services/mood_service.dart';
import '../services/persona_service.dart';
import '../services/recap_ai_service.dart';
import '../services/storage_service.dart';
import '../services/unlock_service.dart';
import '../widgets/vibe_card_share.dart';
import '../widgets/vibe_overlay.dart';

/// Full-view Vibe screen — dedicated screen for persona gallery, mood history,
/// nearby beacon, vibe-card share, and recap history.
class VibeScreen extends StatefulWidget {
  const VibeScreen({super.key});

  @override
  State<VibeScreen> createState() => _VibeScreenState();
}

class _VibeScreenState extends State<VibeScreen> {
  @override
  void initState() {
    super.initState();
    PersonaService.instance.currentNotifier.addListener(_refresh);
  }

  @override
  void dispose() {
    PersonaService.instance.currentNotifier.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = PersonaService.instance.current;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(theme)),
            SliverToBoxAdapter(child: _buildHeroCard(theme, current)),
            SliverToBoxAdapter(child: _buildActions(theme)),
            SliverToBoxAdapter(child: _buildPersonaGallerySection(theme)),
            SliverToBoxAdapter(child: _buildMoodCalendar(theme)),
            SliverToBoxAdapter(child: _buildRecapHistory(theme)),
            SliverToBoxAdapter(
              child: SizedBox(height: bottomPad + AppSpacing.lg),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(
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
                  color:
                      theme.dividerTheme.color ?? AppColors.surfaceBorder,
                ),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: 18, color: theme.colorScheme.onSurface),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Your Vibe',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(ThemeData theme, Persona current) {
    final moodIdx = MoodService.history().isEmpty
        ? MoodKind.neutral
        : MoodService.history().last.index;
    final fireStreak = MoodService.currentStreak(MoodKind.fire);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => VibeOverlay.show(context),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                current.tint,
                Color.alphaBlend(Colors.black.withAlpha(60), current.tint),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: current.tint.withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(current.emoji, style: const TextStyle(fontSize: 60)),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        MoodService.emojiFor(moodIdx),
                        style: const TextStyle(fontSize: 36),
                      ),
                      Text(
                        'today\'s mood',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withAlpha(180),
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                current.name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                current.description,
                style: GoogleFonts.outfit(
                  color: Colors.white.withAlpha(220),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.sensors_rounded,
                      size: 12, color: Colors.white.withAlpha(180)),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to see who\'s nearby',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withAlpha(180),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              if (fireStreak >= 2) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '🔥 $fireStreak-day fire streak',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => VibeCardShare.exportAndShare(context),
          icon: const Icon(Icons.ios_share_rounded, size: 16),
          label: const Text('Share Card'),
        ),
      ),
    );
  }

  Widget _buildPersonaGallerySection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'PERSONAS',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withAlpha(160),
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                '${PersonaService.instance.unlockedPersonas.length} / ${kPersonas.length}',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withAlpha(160),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final useThree = width >= 330;
              final spacing = useThree ? 10.0 : 12.0;
              final aspect = useThree ? 0.85 : 0.95;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: useThree ? 3 : 2,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: aspect,
                ),
                itemCount: kPersonas.length,
                itemBuilder: (ctx, i) => _PersonaTile(persona: kPersonas[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCalendar(ThemeData theme) {
    final days = List.generate(30, (i) {
      final d = DateTime.now().subtract(Duration(days: 29 - i));
      return d;
    });
    final history = MoodService.history();
    final byIso = <String, int>{};
    for (final h in history) {
      byIso['${h.date.year}-${h.date.month.toString().padLeft(2, '0')}-${h.date.day.toString().padLeft(2, '0')}'] =
          h.index;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAST 30 DAYS',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withAlpha(160),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 10,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: days.map((d) {
              final iso =
                  '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
              final idx = byIso[iso];
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: idx == null
                      ? (theme.dividerTheme.color?.withAlpha(60) ??
                          AppColors.surfaceBorder)
                      : _moodColor(idx).withAlpha(40),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: idx == null
                        ? (theme.dividerTheme.color ?? AppColors.surfaceBorder)
                        : _moodColor(idx).withAlpha(100),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  idx == null ? '' : MoodService.emojiFor(idx),
                  style: const TextStyle(fontSize: 11),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _moodColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF334155);
      case 1:
        return const Color(0xFF64748B);
      case 2:
        return const Color(0xFFEAB308);
      case 3:
        return const Color(0xFF4ADE80);
      case 4:
        return const Color(0xFFEF4444);
      case 5:
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF2F7FB8);
    }
  }

  Widget _buildRecapHistory(ThemeData theme) {
    final recaps = <MapEntry<String, String>>[];
    // Pull any cached recap one-liners from StorageService.
    for (var i = 0; i < 10; i++) {
      final weekKey = RecapAiService.isoWeekKey(
          DateTime.now().subtract(Duration(days: i * 7)));
      final cached = StorageService.getString('recap_cache_$weekKey');
      if (cached != null && cached.isNotEmpty) {
        recaps.add(MapEntry(weekKey, cached));
      }
    }
    if (recaps.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY RECAPS',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withAlpha(160),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final r in recaps)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                    color: theme.dividerTheme.color ??
                        AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.key,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withAlpha(140),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.value,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PersonaTile extends StatelessWidget {
  final Persona persona;
  const _PersonaTile({required this.persona});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = PersonaService.instance.isUnlocked(persona.id);
    final selected = PersonaService.instance.current.id == persona.id;
    return InkWell(
      onTap: () async {
        if (unlocked) {
          await PersonaService.instance.setPersona(persona.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                '🔒 ${persona.name}: ${UnlockService.personaUnlockHint(persona.id)}',
                style: GoogleFonts.outfit(fontSize: 13),
              ),
            ),
          );
        }
      },
      onLongPress: unlocked
          ? () => VibeCardShare.exportAndShare(context, personaId: persona.id)
          : null,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        children: [
          // Card body — Positioned.fill ensures it covers the full grid tile.
          // Without this, AnimatedContainer inside Stack gets loose constraints
          // and shrinks to its content, leaving gaps between tiles.
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: selected
                      ? persona.tint
                      : (theme.dividerTheme.color ?? AppColors.surfaceBorder),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(persona.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(
                    persona.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Locked overlay — consistent with theme_picker_grid.dart style:
          // lock icon at bottom-right, not centered.
          if (!unlocked)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withAlpha(80),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.lock_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ),
          if (selected)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: persona.tint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
