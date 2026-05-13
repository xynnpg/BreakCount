import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';
import '../data/personas_data.dart';
import '../services/persona_service.dart';

import '../services/widget_service.dart';
import '../widgets/glassmorphic_card.dart';

class PersonaPickerScreen extends StatefulWidget {
  const PersonaPickerScreen({super.key});

  @override
  State<PersonaPickerScreen> createState() => _PersonaPickerScreenState();
}

class _PersonaPickerScreenState extends State<PersonaPickerScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = PersonaService.instance.current.id;
  }

  Future<void> _pick(String id) async {
    await PersonaService.instance.setPersona(id);
    WidgetService.update();
    setState(() => _selected = id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = PersonaService.instance.current;
    final unlockedIds =
        PersonaService.instance.unlockedPersonas.map((p) => p.id).toSet();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(theme)),
          SliverToBoxAdapter(child: _buildHero(theme, current)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _PersonaTile(
                  persona: kPersonas[i],
                  selected: kPersonas[i].id == _selected,
                  unlocked: unlockedIds.contains(kPersonas[i].id),
                  onTap: () => _pick(kPersonas[i].id),
                ),
                childCount: kPersonas.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return SafeArea(
      bottom: false,
      child: Padding(
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
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: theme.dividerTheme.color ??
                          AppColors.surfaceBorder),
                ),
                child: Icon(Icons.arrow_back_rounded,
                    size: 18, color: theme.colorScheme.onSurface),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Choose Persona',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${PersonaService.instance.unlockedPersonas.length}/${kPersonas.length}',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withAlpha(120),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(ThemeData theme, Persona current) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GlassmorphicCard(
        child: Row(
          children: [
            Text(current.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current.name,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: current.tint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current.description,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(160),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonaTile extends StatelessWidget {
  final Persona persona;
  final bool selected;
  final bool unlocked;
  final VoidCallback onTap;

  const _PersonaTile({
    required this.persona,
    required this.selected,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Stack(
        children: [
          // Positioned.fill makes the card body expand to the full grid tile.
          // Without it, AnimatedContainer inside Stack gets loose constraints
          // and shrinks to its content, so borders/backgrounds don't fill the cell.
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: selected
                    ? persona.tint.withAlpha(20)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: selected
                      ? persona.tint
                      : theme.dividerTheme.color ?? AppColors.surfaceBorder,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Opacity(
                opacity: unlocked ? 1.0 : 0.45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(persona.emoji,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        persona.name,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? persona.tint
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lock badge — bottom-right, consistent with theme_picker_grid.dart.
          if (!unlocked)
            const Positioned(
              bottom: 6,
              right: 6,
              child: Icon(Icons.lock_rounded, size: 14, color: Colors.white54),
            ),
          if (selected)
            Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.check_circle_rounded,
                  size: 16, color: persona.tint),
            ),
        ],
      ),
    );
  }
}
