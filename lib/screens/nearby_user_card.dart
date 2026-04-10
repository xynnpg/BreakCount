import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/nearby_device.dart';
import '../widgets/glassmorphic_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final (emoji, label) =
        _personaDisplay[device.persona] ?? ('🔥', 'Hype');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _buildInfo(emoji, label)),
            const SizedBox(width: AppSpacing.sm),
            _buildAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildInfo(String emoji, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          device.displayName,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$emoji  $label',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${device.subjectCount} subjects · ${device.entryCount} classes',
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildAction() {
    switch (device.status) {
      case NearbyDeviceStatus.discovered:
        return OutlinedButton(
          onPressed: onTransfer,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1),
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
        );
      case NearbyDeviceStatus.connecting:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
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
