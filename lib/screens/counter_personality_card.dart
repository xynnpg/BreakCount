import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../app/persona_theme_ext.dart';
import '../data/personas_data.dart';
import '../models/nearby_device.dart';
import '../services/mesh_service.dart';
import '../services/mood_service.dart';
import '../services/persona_service.dart';
import '../services/storage_service.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/radar_painter.dart';
import '../widgets/vibe_card_share.dart';
import '../widgets/vibe_overlay.dart';

class PersonalityCard extends StatefulWidget {
  final int daysUntilBreak;
  final bool isOnBreak;

  const PersonalityCard({
    super.key,
    required this.daysUntilBreak,
    required this.isOnBreak,
  });

  @override
  State<PersonalityCard> createState() => _PersonalityCardState();
}

class _PersonalityCardState extends State<PersonalityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarCtrl;
  StreamSubscription<List<NearbyDevice>>? _beaconSub;
  List<NearbyDevice> _beaconDevices = [];

  bool get _beaconEnabled =>
      StorageService.getBool(StorageKeys.vibeBeaconEnabled) ?? false;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Passively listen to MeshService so any scan happening elsewhere (bump,
    // nearby-users, vibe overlay) feeds into the PersonalityCard counter.
    // We don't start MeshService here — opt-in through the VibeOverlay scan.
    _beaconSub = MeshService.instance.devicesStream.listen((d) {
      if (mounted) setState(() => _beaconDevices = d);
    });
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    _beaconSub?.cancel();
    super.dispose();
  }

  int _nearbyMatchingCount(String myPersona) {
    if (!_beaconEnabled) return 0;
    return _beaconDevices.where((d) => d.persona == myPersona).length;
  }

  Future<void> _showQuickPersonaSheet() async {
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
              'Swap Persona',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Short tap to swap, long-press the card for the vibe radar.',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withAlpha(120),
              ),
            ),
            const SizedBox(height: 12),
            ...unlocked.map((p) => InkWell(
                  onTap: () async {
                    await PersonaService.instance.setPersona(p.id);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) setState(() {});
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
                              color: p.id == PersonaService.instance.current.id
                                  ? p.tint
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (p.id == PersonaService.instance.current.id)
                          Icon(Icons.check_rounded, color: p.tint, size: 18),
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

  Future<void> _maybeEnableBeaconThenOverlay() async {
    final enabled = _beaconEnabled;
    if (!enabled) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Enable Vibe Beacon?',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          content: Text(
            'Uses Bluetooth + Location to show nearby students when the app is open. Low-power, opt-in.',
            style: GoogleFonts.outfit(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Enable'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await StorageService.saveBool(
          StorageKeys.vibeBeaconEnabled, true);
      if (mounted) setState(() {});
    }
    if (mounted) await VibeOverlay.show(context);
  }

  Future<void> _shareVibeCard() async {
    await VibeCardShare.exportAndShare(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personaId =
        StorageService.getString(StorageKeys.widgetPersona) ?? 'hype';
    final persona = personaById(personaId);
    final moodIdx = MoodService.computeMoodIndex(
      widget.daysUntilBreak,
      widget.isOnBreak,
    );
    final moodEmoji = MoodService.emojiFor(moodIdx);
    final fireStreak = MoodService.currentStreak(MoodKind.fire);
    final matchCount = _nearbyMatchingCount(personaId);

    return GlassmorphicCard(
      animationDelay: 290,
      onTap: _showQuickPersonaSheet,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: _maybeEnableBeaconThenOverlay,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'YOUR VIBE',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withAlpha(120),
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                // Kebab → share Vibe Card
                Semantics(
                  label: 'Share vibe card',
                  child: InkResponse(
                    onTap: _shareVibeCard,
                    radius: 16,
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.more_vert_rounded,
                          size: 16, color: theme.colorScheme.onSurface.withAlpha(120)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                // Persona block
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(persona.emoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 2),
                    Text(
                      persona.name,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Tap to swap',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                  ],
                ),
                // Divider
                Container(
                  width: 1,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  color: theme.dividerTheme.color ?? AppColors.surfaceBorder,
                ),
                // Mood block (with optional fire-streak pill)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(moodEmoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 2),
                    if (fireStreak >= 2)
                      _StreakPill(streak: fireStreak)
                    else
                      Text(
                        'Current Mood',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                // Radar + hint
                Column(
                  children: [
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _radarCtrl,
                        builder: (context, child) => CustomPaint(
                          painter: RadarPainter(
                            progress: _radarCtrl.value,
                            color: context.personaTint,
                          ),
                          size: const Size(32, 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      matchCount > 0
                          ? '$matchCount ${persona.emoji} nearby'
                          : 'Long-press',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        color: matchCount > 0
                            ? context.personaTint
                            : Theme.of(context).colorScheme.onSurface.withAlpha(140),
                        fontWeight: matchCount > 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int streak;
  const _StreakPill({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300).withAlpha(30),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: const Color(0xFFFFB300).withAlpha(80),
          width: 0.8,
        ),
      ),
      child: Text(
        '🔥 $streak ${streak == 1 ? 'day' : 'days'}',
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFB35B00),
        ),
      ),
    );
  }
}
