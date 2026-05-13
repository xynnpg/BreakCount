import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app/constants.dart';
import '../data/achievements_data.dart';
import '../data/personas_data.dart';
import '../services/achievement_service.dart';
import '../services/mood_service.dart';
import '../services/storage_service.dart';

/// Renders a beautiful persona-tinted 9:16 share card offscreen and shares it
/// as a PNG via the OS share sheet.
///
/// Entry point is [VibeCardShare.exportAndShare] — it shows a lightweight
/// progress indicator while rendering.
class VibeCardShare {
  /// Export a vibe card as PNG and open a share sheet.
  ///
  /// [personaId] — when provided, renders that persona's card instead of the
  /// currently active one. Useful for sharing any unlocked persona from the
  /// gallery without switching the active persona.
  static Future<void> exportAndShare(BuildContext context,
      {String? personaId}) async {
    final rootContext = context;
    final overlay = Overlay.of(rootContext, rootOverlay: true);
    final key = GlobalKey();
    final readyCompleter = Completer<void>();
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: -9999, // keep offscreen
        top: 0,
        child: Material(
          color: Colors.transparent,
          child: _VibeCardRaster(
            key: key,
            personaId: personaId,
            onReady: () {
              if (!readyCompleter.isCompleted) readyCompleter.complete();
            },
          ),
        ),
      ),
    );
    overlay.insert(entry);

    // Wait for the first frame to paint.
    await readyCompleter.future;
    // Give the tree one extra frame so the RepaintBoundary layer is ready.
    await Future<void>.delayed(const Duration(milliseconds: 32));

    try {
      final boundary = key.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final file = await _writeTemp(bytes.buffer.asUint8List());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My BreakCount vibe 👀',
      );
      // Unlock the "flex" achievement on a successful share — fire-and-forget.
      unawaited(AchievementService.unlock('flex'));
    } finally {
      entry.remove();
    }
  }

  static Future<File> _writeTemp(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/breakcount_vibe_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file;
  }
}

/// The visual card — 1080×1920 portrait canvas.
class _VibeCardRaster extends StatefulWidget {
  final VoidCallback onReady;
  final String? personaId;
  const _VibeCardRaster({super.key, required this.onReady, this.personaId});

  @override
  State<_VibeCardRaster> createState() => _VibeCardRasterState();
}

class _VibeCardRasterState extends State<_VibeCardRaster> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onReady());
  }

  @override
  Widget build(BuildContext context) {
    final personaId = widget.personaId ??
        StorageService.getString(StorageKeys.widgetPersona) ??
        'hype';
    final persona = personaById(personaId);
    final displayName =
        StorageService.getString('display_name') ?? 'Student';
    final rank = AchievementService.getRank();
    final unlocks = [...AchievementService.allUnlocks]
      ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    final topThree = unlocks.take(3).toList();
    final fireStreak = MoodService.currentStreak(MoodKind.fire);
    final moodEmoji = MoodService.emojiFor(
      MoodService.history().isNotEmpty
          ? MoodService.history().last.index
          : MoodKind.neutral,
    );

    return RepaintBoundary(
      key: widget.key,
      child: Container(
        width: 1080,
        height: 1920,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              persona.tint,
              Color.alphaBlend(Colors.black.withAlpha(120), persona.tint),
            ],
          ),
        ),
        padding: const EdgeInsets.all(64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'BreakCount',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              persona.emoji,
              style: const TextStyle(fontSize: 280),
            ),
            const SizedBox(height: 24),
            Text(
              persona.name.toUpperCase(),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 96,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                height: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              style: GoogleFonts.outfit(
                color: Colors.white.withAlpha(200),
                fontSize: 44,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                _StatPill(
                  label: 'RANK',
                  value: rank,
                ),
                const SizedBox(width: 16),
                _StatPill(
                  label: 'MOOD',
                  value: moodEmoji,
                ),
                const SizedBox(width: 16),
                if (fireStreak >= 2)
                  _StatPill(
                    label: 'STREAK',
                    value: '🔥 $fireStreak',
                  ),
              ],
            ),
            const SizedBox(height: 48),
            if (topThree.isNotEmpty) ...[
              Text(
                'LATEST UNLOCKS',
                style: GoogleFonts.outfit(
                  color: Colors.white.withAlpha(180),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: topThree.map((u) {
                  final ach = kAchievements
                      .where((a) => a.id == u.id)
                      .firstOrNull;
                  if (ach == null) return const SizedBox.shrink();
                  return Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withAlpha(80), width: 2),
                    ),
                    child: Icon(ach.icon, size: 60, color: Colors.white),
                  );
                }).toList(),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Text(
                  'breakcount.tech',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withAlpha(180),
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white.withAlpha(160),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
