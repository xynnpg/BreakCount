import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/constants.dart';
import '../models/nearby_device.dart';

/// The slide-up panel that shows nearby students.
class DeviceListPanel extends StatelessWidget {
  final double slideProgress; // 0 = fully hidden, 1 = fully visible
  final List<NearbyDevice> devices;
  final bool connecting;
  final VoidCallback onDismiss;
  final void Function(NearbyDevice device) onCopy;
  final double panelHeight;

  const DeviceListPanel({
    super.key,
    required this.slideProgress,
    required this.devices,
    required this.connecting,
    required this.onDismiss,
    required this.onCopy,
    this.panelHeight = 320,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Transform.translate(
        offset: Offset(0, (1 - slideProgress) * panelHeight),
        child: Container(
          height: panelHeight,
          decoration: const BoxDecoration(
            color: Color(0xFF14141F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0x336F4E37), width: 1),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x44FFFFFF),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.sensors_rounded,
                          color: AppColors.primary, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Nearby Students',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (!connecting)
                      GestureDetector(
                        onTap: onDismiss,
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white38, size: 22),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (devices.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_tethering_rounded,
                            color: Colors.white24, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          'Scanning for nearby students…',
                          style: GoogleFonts.outfit(
                              color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    itemCount: devices.length,
                    itemBuilder: (_, i) => DeviceCard(
                      device: devices[i],
                      onCopy: () => onCopy(devices[i]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final NearbyDevice device;
  final VoidCallback onCopy;

  const DeviceCard({super.key, required this.device, required this.onCopy});

  static const _cardBg = Color(0xFF1C1C2E);
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
              color: AppColors.primary.withValues(alpha:0.12),
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
          color: AppColors.primary.withValues(alpha:0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.primary.withValues(alpha:0.4), width: 1),
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
