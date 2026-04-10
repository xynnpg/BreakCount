import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../app/constants.dart';

// ── Photo source bottom sheet ─────────────────────────────────────────────────

class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Import Timetable',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'AI will read and extract your schedule.',
                style: GoogleFonts.outfit(
                    fontSize: 13, color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.lg),
              SourceTile(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                sub: 'Point camera at printed timetable',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: AppSpacing.sm),
              SourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                sub: 'Pick a saved image',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: GoogleFonts.outfit(color: AppColors.textTertiary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Source tile ───────────────────────────────────────────────────────────────

class SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const SourceTile({
    super.key,
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                  Text(sub,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Merge dialog ──────────────────────────────────────────────────────────────

class MergeDialog extends StatelessWidget {
  const MergeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Existing schedule found',
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      content: Text(
        'Do you want to add these classes to your existing schedule, or replace everything?',
        style: GoogleFonts.outfit(
            color: AppColors.textSecondary, fontSize: 13, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: Text('Cancel',
              style: GoogleFonts.outfit(color: AppColors.textTertiary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'add'),
          child: Text('Add to existing',
              style: GoogleFonts.outfit(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'replace'),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text('Replace all',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
