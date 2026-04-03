import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../services/backup_service.dart';
import '../services/storage_service.dart';

/// Page 3 of the welcome carousel — Google sign-in / restore.
class WelcomePage3Google extends StatefulWidget {
  final VoidCallback onSkip;
  final void Function(bool hasBackup) onConnected;

  const WelcomePage3Google({
    super.key,
    required this.onSkip,
    required this.onConnected,
  });

  @override
  State<WelcomePage3Google> createState() => _WelcomePage3GoogleState();
}

class _WelcomePage3GoogleState extends State<WelcomePage3Google> {
  bool _loading = false;
  String? _error;

  Future<void> _handleConnect() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final signInResult = await BackupService.signIn();
    if (!mounted) return;

    if (!signInResult.success) {
      setState(() {
        _loading = false;
        _error = signInResult.error;
      });
      return;
    }

    final restoreResult = await BackupService.restore();
    if (!mounted) return;

    setState(() => _loading = false);

    if (restoreResult.success) {
      await StorageService.saveBool(StorageKeys.isOnboarded, true);
      widget.onConnected(true);
    } else if (restoreResult.error?.contains('No backup') == true) {
      widget.onConnected(false);
    } else {
      setState(() => _error = restoreResult.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.cloud_outlined,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Back up & restore.',
            style: GoogleFonts.outfit(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -1.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Connect Google to restore your schedule, exams, and settings — or start fresh and back up later.',
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: AppColors.error, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _loading ? null : _handleConnect,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.login_rounded, size: 18),
              label: Text(
                'Connect with Google',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _loading ? null : widget.onSkip,
              child: Text(
                'Skip for now',
                style: GoogleFonts.outfit(
                    color: AppColors.textTertiary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
