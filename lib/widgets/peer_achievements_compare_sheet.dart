import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';
import '../data/achievements_data.dart';
import '../models/nearby_device.dart';
import '../services/achievement_service.dart';
import '../services/mesh_service.dart';

/// Bottom sheet that shows the diff of unlocked achievements between the
/// current user and a nearby peer (via the MEET_HANDSHAKE payload).
class PeerAchievementsCompareSheet extends StatelessWidget {
  final NearbyDevice peer;

  const PeerAchievementsCompareSheet({super.key, required this.peer});

  /// Convenience launcher.
  static Future<void> show(BuildContext context, NearbyDevice peer) async {
    // Record a compare event.
    await AchievementService.onPeerCompare();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PeerAchievementsCompareSheet(peer: peer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = AchievementService.allUnlocks.map((u) => u.id).toSet();
    final theirs = MeshService.instance.peerUnlocks(peer.anonId) ?? <String>{};

    final both = mine.intersection(theirs);
    final onlyMine = mine.difference(theirs);
    final onlyTheirs = theirs.difference(mine);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerTheme.color,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Compare with ${peer.displayName}',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Shared: ${both.length} · You have ${onlyMine.length} they don\'t · They have ${onlyTheirs.length} you don\'t',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withAlpha(160),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                controller: scroll,
                children: [
                  if (onlyMine.isNotEmpty)
                    _Section(title: 'You have exclusively', ids: onlyMine),
                  if (onlyTheirs.isNotEmpty)
                    _Section(
                      title: 'They have exclusively',
                      ids: onlyTheirs,
                      locked: true,
                    ),
                  if (both.isNotEmpty)
                    _Section(title: 'You both have', ids: both),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Set<String> ids;
  final bool locked;

  const _Section({required this.title, required this.ids, this.locked = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (${ids.length})',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withAlpha(160),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ids.map((id) {
              final ach = kAchievements.where((a) => a.id == id).firstOrNull;
              if (ach == null) return const SizedBox.shrink();
              final rColor = ach.rarity.color;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: rColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: rColor.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        locked
                            ? Icons.lock_rounded
                            : (ach.isSecret
                                ? Icons.visibility_off_rounded
                                : ach.icon),
                        size: 14,
                        color: rColor),
                    const SizedBox(width: 6),
                    Text(
                      ach.isSecret && locked ? '???' : ach.name,
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
