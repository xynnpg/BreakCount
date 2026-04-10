import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/constants.dart';
import '../models/nearby_device.dart';
import '../services/mesh_service.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/radar_painter.dart';
import 'nearby_user_card.dart';

class NearbyUsersScreen extends StatefulWidget {
  const NearbyUsersScreen({super.key});

  @override
  State<NearbyUsersScreen> createState() => _NearbyUsersScreenState();
}

class _NearbyUsersScreenState extends State<NearbyUsersScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarCtrl;
  List<NearbyDevice> _devices = [];
  bool _scanning = false;
  bool _permissionDenied = false;
  bool _timedOut = false;
  StreamSubscription<List<NearbyDevice>>? _devicesSub;
  StreamSubscription<ReceivedSchedule>? _receivedSub;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _startMesh();
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    _devicesSub?.cancel();
    _receivedSub?.cancel();
    MeshService.instance.stop();
    super.dispose();
  }

  Future<void> _startMesh() async {
    setState(() => _scanning = true);
    final ok = await MeshService.instance.start();
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _permissionDenied = true;
        _scanning = false;
      });
      return;
    }
    _devicesSub = MeshService.instance.devicesStream.listen(
      (devices) {
        if (mounted) setState(() => _devices = devices);
      },
      onError: (_) {
        if (mounted && _devices.isEmpty) {
          setState(() {
            _timedOut = true;
            _scanning = false;
          });
        }
      },
    );
    _receivedSub = MeshService.instance.receivedStream.listen((received) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Schedule received from ${received.fromDisplayName}!',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
    if (mounted) setState(() => _scanning = false);
  }

  String get _subtitle {
    if (_permissionDenied) return 'Permission required';
    if (_scanning) return 'Scanning for students...';
    if (_timedOut && _devices.isEmpty) return 'No students found nearby';
    if (_devices.isEmpty) return 'Searching...';
    return '${_devices.length} student${_devices.length == 1 ? '' : 's'} nearby';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nearby Students',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _subtitle,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _permissionDenied
            ? _buildPermissionDenied()
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildRadarSection()),
        if (_timedOut && _devices.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(),
          )
        else if (_devices.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => NearbyUserCard(
                  device: _devices[i],
                  onTransfer: () => MeshService.instance
                      .requestTransfer(_devices[i].endpointId),
                ),
                childCount: _devices.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRadarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _radarCtrl,
              builder: (context, child) => CustomPaint(
                painter: RadarPainter(progress: _radarCtrl.value),
                size: const Size(120, 120),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _scanning ? 'Scanning...' : _subtitle,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassmorphicCard(
            child: Column(
              children: [
                const Icon(Icons.sensors_off_rounded,
                    size: 48, color: AppColors.textTertiary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No students nearby',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Make sure nearby friends also have BreakCount open to discover each other.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassmorphicCard(
            child: Column(
              children: [
                const Icon(Icons.bluetooth_disabled_rounded,
                    size: 48, color: AppColors.warning),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Permissions needed',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Bluetooth and Location permissions are required to find nearby students.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => openAppSettings(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    'Open Settings',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                    ),
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
