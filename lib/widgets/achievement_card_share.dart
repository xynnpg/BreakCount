import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/achievements_data.dart';
import '../data/personas_data.dart';
import '../services/achievement_service.dart';
import '../services/storage_service.dart';
import '../app/constants.dart';

/// Exports a 1080x1920 PNG for sharing any unlocked [Achievement].
class AchievementCardShare {
  static Future<void> exportAndShare(
      BuildContext context, Achievement achievement) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final key = GlobalKey();
    final ready = Completer<void>();
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -9999,
        top: 0,
        child: Material(
          color: Colors.transparent,
          child: _AchievementCardRaster(
            key: key,
            achievement: achievement,
            onReady: () {
              if (!ready.isCompleted) ready.complete();
            },
          ),
        ),
      ),
    );
    overlay.insert(entry);

    await ready.future;
    await Future<void>.delayed(const Duration(milliseconds: 32));

    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final file = await _writeTemp(byteData.buffer.asUint8List());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Unlocked "${achievement.name}" on BreakCount 🏆',
      );
    } finally {
      entry.remove();
    }
  }

  static Future<File> _writeTemp(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/breakcount_ach_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file;
  }
}

class _AchievementCardRaster extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onReady;
  const _AchievementCardRaster({
    super.key,
    required this.achievement,
    required this.onReady,
  });

  @override
  State<_AchievementCardRaster> createState() => _AchievementCardRasterState();
}

class _AchievementCardRasterState extends State<_AchievementCardRaster> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onReady());
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final personaId =
        StorageService.getString(StorageKeys.widgetPersona) ?? 'hype';
    final persona = personaById(personaId);
    final rColor = a.rarity.color;
    final unlock = AchievementService.getUnlock(a.id);
    final unlockedAt = unlock?.unlockedAt ?? DateTime.now();
    final displayName =
        StorageService.getString('display_name') ?? 'Student';
    final rank = AchievementService.getRank();

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
              Color.alphaBlend(Colors.black.withAlpha(140), persona.tint),
            ],
          ),
        ),
        padding: const EdgeInsets.all(72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(60),
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
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: rColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    a.rarity.label.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    rColor,
                    Color.alphaBlend(Colors.black.withAlpha(140), rColor),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 8),
                boxShadow: [
                  BoxShadow(
                    color: rColor.withAlpha(100),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(a.icon, size: 200, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Text(
              'UNLOCKED',
              style: GoogleFonts.outfit(
                color: Colors.white.withAlpha(180),
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              a.name,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 88,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              a.description,
              maxLines: 3,
              style: GoogleFonts.outfit(
                color: Colors.white.withAlpha(220),
                fontSize: 36,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(60),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Text(persona.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$rank · ${a.effectiveXp} XP',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withAlpha(180),
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${unlockedAt.year}-'
                    '${unlockedAt.month.toString().padLeft(2, '0')}-'
                    '${unlockedAt.day.toString().padLeft(2, '0')}',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withAlpha(200),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
