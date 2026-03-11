import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';
import '../models/nearby_device.dart';
import '../services/analytics_service.dart';
import '../services/mesh_service.dart';
import '../services/schedule_service.dart';
import 'radar_painter.dart';

enum _OverlayState {
  searching,
  devicesFound,
  connecting,
  success,
  error,
  timeout,
}

class ShakeMeshOverlay extends StatefulWidget {
  const ShakeMeshOverlay({super.key});

  @override
  State<ShakeMeshOverlay> createState() => _ShakeMeshOverlayState();
}

class _ShakeMeshOverlayState extends State<ShakeMeshOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _radarCtrl;
  late final AnimationController _successCtrl;
  late final Animation<double> _radarAnim;
  late final Animation<double> _successScale;

  StreamSubscription<List<NearbyDevice>>? _devicesSub;
  StreamSubscription<ReceivedSchedule>? _receivedSub;

  _OverlayState _state = _OverlayState.searching;
  List<NearbyDevice> _devices = [];
  String _errorMessage = '';
  bool _dialogShowing = false;

  static const _bg = Color(0xF5080810);

  @override
  void initState() {
    super.initState();
    if (kDebugMode) debugPrint('[ShakeMeshOverlay] initState — new instance');

    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _radarAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_radarCtrl);
    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut),
    );

    _devicesSub = MeshService.instance.devicesStream.listen(
      (devices) {
        if (!mounted) return;
        setState(() {
          _devices = devices;
          if (_state == _OverlayState.searching && devices.isNotEmpty) {
            _state = _OverlayState.devicesFound;
          }
        });
      },
      onError: _onStreamError,
    );

    _receivedSub = MeshService.instance.receivedStream.listen(
      _onScheduleReceived,
      onError: _onStreamError,
    );

    _startMesh();
  }

  Future<void> _startMesh() async {
    // Always stop first to clear any stale Nearby Connections state from
    // a previous session that wasn't properly cleaned up.
    await MeshService.instance.stop();
    if (!mounted) return;
    final ok = await MeshService.instance.start();
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _state = _OverlayState.error;
        _errorMessage =
            'Could not start Nearby Connections.\nEnable Bluetooth & Location.';
      });
    }
    if (kDebugMode) debugPrint('[ShakeMeshOverlay] _startMesh ok=$ok state=$_state');
  }

  void _onStreamError(Object error) {
    if (!mounted) return;
    setState(() {
      _state = error.toString().contains('timeout')
          ? _OverlayState.timeout
          : _OverlayState.error;
      _errorMessage =
          error.toString().contains('timeout') ? '' : error.toString();
    });
  }

  void _onScheduleReceived(ReceivedSchedule received) {
    if (!mounted) return;
    // Guard: ignore duplicate payloads while a confirmation dialog is already open
    if (_dialogShowing) return;
    _dialogShowing = true;

    // Reset state so the device list is visible again while dialog shows
    if (_state == _OverlayState.connecting) {
      setState(() => _state = _OverlayState.devicesFound);
    }
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Replace Schedule?',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "Copy ${received.fromDisplayName}'s schedule?\n"
          "${received.subjects.length} subjects · ${received.schedule.entries.length} classes",
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Copy',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ).then((confirmed) async {
      _dialogShowing = false;
      if (confirmed == true) {
        await ScheduleService.saveFullSchedule(
          received.schedule,
          received.subjects,
        );
        AnalyticsService.scheduleReceived();
        if (mounted) {
          setState(() => _state = _OverlayState.success);
          _successCtrl.forward();
        }
      } else {
        if (mounted) setState(() => _state = _OverlayState.devicesFound);
      }
    });
  }

  @override
  void dispose() {
    if (kDebugMode) debugPrint('[ShakeMeshOverlay] dispose — state=$_state');
    _radarCtrl.dispose();
    _successCtrl.dispose();
    _devicesSub?.cancel();
    _receivedSub?.cancel();
    MeshService.instance.stop();
    super.dispose();
  }

  void _dismiss() {
    if (kDebugMode) debugPrint('[ShakeMeshOverlay] _dismiss called — state=$_state');
    Navigator.of(context).pop();
  }

  void _retry() {
    setState(() {
      _state = _OverlayState.searching;
      _devices = [];
      _errorMessage = '';
    });
    MeshService.instance.stop().then((_) {
      if (mounted) _startMesh();
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox.expand(
        child: ColoredBox(
          color: _bg,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                if (kDebugMode) _buildDebugBanner(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRadar(),
                      const SizedBox(height: 20),
                      _buildStatusText(),
                    ],
                  ),
                ),
                if (_state == _OverlayState.devicesFound ||
                    _state == _OverlayState.connecting)
                  _buildDeviceList(),
                const SizedBox(height: 16),
                _buildActions(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDebugBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.yellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow.withValues(alpha: 0.4)),
      ),
      child: Text(
        '[DEBUG] state=${_state.name}  '
        'devices=${_devices.length}  '
        'mesh=${MeshService.instance.isRunning}  '
        'dialog=$_dialogShowing',
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sensors_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Nearby Share',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (_state != _OverlayState.connecting)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white54),
              onPressed: _dismiss,
            ),
        ],
      ),
    );
  }

  Widget _buildRadar() {
    return RepaintBoundary(
      child: SizedBox(
        width: 200,
        height: 200,
        child: AnimatedBuilder(
          animation: _radarAnim,
          builder: (ctx, child) => CustomPaint(
            painter: RadarPainter(progress: _radarAnim.value),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    switch (_state) {
      case _OverlayState.searching:
        return _statusLabel('Looking for nearby students…');
      case _OverlayState.devicesFound:
        return _statusLabel(
          '${_devices.length} student${_devices.length == 1 ? '' : 's'} found',
          highlight: true,
        );
      case _OverlayState.connecting:
        return _statusLabel('Connecting…');
      case _OverlayState.success:
        return ScaleTransition(
          scale: _successScale,
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.greenAccent, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                'Schedule copied!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap Done to go back',
                style: GoogleFonts.outfit(
                    color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        );
      case _OverlayState.timeout:
        return _iconStatus(
          Icons.wifi_tethering_off_rounded,
          Colors.orange,
          'No students found nearby',
          'Make sure both devices have\nBluetooth & Location enabled',
        );
      case _OverlayState.error:
        return _iconStatus(
          Icons.error_outline_rounded,
          Colors.redAccent,
          'Something went wrong',
          _errorMessage,
        );
    }
  }

  Widget _statusLabel(String text, {bool highlight = false}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.outfit(
        color: highlight ? AppColors.primary : Colors.white54,
        fontSize: 14,
        fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _iconStatus(
      IconData icon, Color color, String title, String subtitle) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildDeviceList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _devices.length,
          itemBuilder: (ctx, i) {
            final device = _devices[i];
            return _DeviceCard(
              device: device,
              onCopy: () {
                setState(() => _state = _OverlayState.connecting);
                MeshService.instance.requestTransfer(device.endpointId);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildActions() {
    switch (_state) {
      case _OverlayState.success:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _dismiss,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text('Done',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        );
      case _OverlayState.timeout:
      case _OverlayState.error:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _retry,
                  child: Text('Try Again',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _dismiss,
                child: Text('Cancel',
                    style: GoogleFonts.outfit(
                        color: Colors.white38, fontSize: 14)),
              ),
            ],
          ),
        );
      case _OverlayState.connecting:
        return const SizedBox.shrink();
      default:
        return TextButton(
          onPressed: _dismiss,
          child: Text('Cancel',
              style: GoogleFonts.outfit(
                  color: Colors.white38, fontSize: 14)),
        );
    }
  }
}

// ── Device Card ──────────────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final NearbyDevice device;
  final VoidCallback onCopy;

  const _DeviceCard({required this.device, required this.onCopy});

  static const _cardBg = Color(0xFF12121F);
  static const _cardBorder = Color(0x336F4E37);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (device.subjectCount > 0)
                  Text(
                    '${device.subjectCount} subjects · ${device.entryCount} classes',
                    style: GoogleFonts.outfit(
                        color: Colors.white38, fontSize: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildAction(),
        ],
      ),
    );
  }

  Widget _buildAction() {
    if (device.status == NearbyDeviceStatus.connecting) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      );
    }
    if (device.status == NearbyDeviceStatus.failed) {
      return const Icon(Icons.error_outline_rounded,
          color: Colors.redAccent, size: 20);
    }
    return GestureDetector(
      onTap: onCopy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4), width: 1),
        ),
        child: Text(
          'Copy',
          style: GoogleFonts.outfit(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
