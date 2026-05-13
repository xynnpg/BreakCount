import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/nearby_device.dart';
import '../services/mesh_service.dart';
import '../services/persona_service.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/peer_achievements_compare_sheet.dart';

const _personaDisplay = {
  'hype': ('🔥', 'Hype'),
  'chill': ('😎', 'Chill'),
  'dramatic': ('🎭', 'Dramatic'),
  'sarcastic': ('🙃', 'Sarcastic'),
};

class NearbyUserCard extends StatelessWidget {
  final NearbyDevice device;
  final VoidCallback onTransfer;

  const NearbyUserCard({
    super.key,
    required this.device,
    required this.onTransfer,
  });

  Future<void> _sharePersona(BuildContext context) async {
    final theme = Theme.of(context);
    final unlocked = PersonaService.instance.unlockedPersonas;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerTheme.color ?? AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Share Persona',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick a persona to share with ${device.displayName}',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withAlpha(140),
              ),
            ),
            const SizedBox(height: 8),
            ...unlocked.map((p) => InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    MeshService.instance.sharePersona(
                      device.endpointId,
                      personaId: p.id,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: 12),
                    child: Row(
                      children: [
                        Text(p.emoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p.name,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (emoji, label) =
        _personaDisplay[device.persona] ?? ('🔥', 'Hype');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onLongPress: () {
          PeerAchievementsCompareSheet.show(context, device);
        },
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _buildAvatar(context),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildInfo(context, emoji, label)),
              const SizedBox(width: AppSpacing.sm),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        color: theme.colorScheme.primary,
        size: 24,
      ),
    );
  }

  Widget _buildInfo(BuildContext context, String emoji, String label) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          device.displayName,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$emoji  $label',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withAlpha(180),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${device.subjectCount} subjects · ${device.entryCount} classes',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withAlpha(120),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    switch (device.status) {
      case NearbyDeviceStatus.discovered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Share Persona — always available
            IconButton(
              onPressed: () => _sharePersona(context),
              tooltip: 'Share Persona',
              icon: Icon(Icons.auto_awesome_rounded,
                  size: 18, color: theme.colorScheme.primary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const SizedBox(width: 4),
            // Copy Schedule
            OutlinedButton(
              onPressed: onTransfer,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary, width: 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                'Copy',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      case NearbyDeviceStatus.connecting:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        );
      case NearbyDeviceStatus.connected:
        return const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 24,
        );
      case NearbyDeviceStatus.failed:
        return GestureDetector(
          onTap: onTransfer,
          child: const Icon(
            Icons.error_rounded,
            color: AppColors.error,
            size: 24,
          ),
        );
    }
  }
}
