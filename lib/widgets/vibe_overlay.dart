import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';
import '../app/persona_theme_ext.dart';
import '../data/personas_data.dart';
import '../models/nearby_device.dart';
import '../services/mesh_service.dart';
import 'radar_painter.dart';

/// Modal bottom sheet that scans nearby BreakCount students and groups them
/// by persona. Triggered by tapping the persona hero card on the Vibe screen.
///
/// Starts a MeshService scan on open, stops it on close.
class VibeOverlay extends StatefulWidget {
  const VibeOverlay({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xF5080810),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const VibeOverlay(),
    );
  }

  @override
  State<VibeOverlay> createState() => _VibeOverlayState();
}

class _VibeOverlayState extends State<VibeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarCtrl;
  StreamSubscription<List<NearbyDevice>>? _sub;
  List<NearbyDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _startScan();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _radarCtrl.dispose();
    MeshService.instance.stop();
    super.dispose();
  }

  Future<void> _startScan() async {
    _sub = MeshService.instance.devicesStream.listen((d) {
      if (mounted) setState(() => _devices = d);
    });
    await MeshService.instance.start();
  }

  void _dismiss() => Navigator.of(context).pop();

  Map<String, List<NearbyDevice>> _groupByPersona() {
    final map = <String, List<NearbyDevice>>{};
    for (final d in _devices) {
      map.putIfAbsent(d.persona, () => []).add(d);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final tint = context.personaTint;
    final groups = _groupByPersona();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                RepaintBoundary(
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: AnimatedBuilder(
                      animation: _radarCtrl,
                      builder: (ctx, _) => CustomPaint(
                        painter: RadarPainter(
                          progress: _radarCtrl.value,
                          color: tint,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _devices.isEmpty
                      ? 'Scanning for vibes…'
                      : '${_devices.length} student${_devices.length == 1 ? '' : 's'} nearby',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (groups.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: groups.entries.map((e) {
                  final p = personaById(e.key);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: p.tint.withAlpha(40),
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                          color: p.tint.withAlpha(120), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${p.name} · ${e.value.length}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _dismiss,
            child: Text('Close',
                style:
                    GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.personaTint.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.sensors_rounded,
                color: context.personaTint, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Vibe Beacon',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
            onPressed: _dismiss,
          ),
        ],
      ),
    );
  }
}
