import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app/constants.dart';

/// Bottom sheet for Google Drive Backup & Restore.
class BackupSheet extends StatelessWidget {
  final bool signedIn;
  final String? email;
  final DateTime? lastBackupTime;
  final bool busy;
  final String? errorMessage;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final VoidCallback onBackup;
  final VoidCallback onRestore;

  const BackupSheet({
    super.key,
    required this.signedIn,
    this.email,
    this.lastBackupTime,
    required this.busy,
    this.errorMessage,
    required this.onSignIn,
    required this.onSignOut,
    required this.onBackup,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Google Drive Backup',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your schedule, exams, and settings are saved to your private app data folder in Google Drive.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),

          // Error banner
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.error,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          if (signedIn) ...[
            _InfoRow(
                icon: Icons.account_circle_outlined,
                text: email ?? 'Signed in'),
            if (lastBackupTime != null) ...[
              const SizedBox(height: 6),
              _InfoRow(
                icon: Icons.history_rounded,
                text:
                    'Last backup: ${DateFormat('d MMM yyyy, HH:mm').format(lastBackupTime!)}',
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Backup Now',
                    icon: Icons.cloud_upload_outlined,
                    primary: true,
                    loading: busy,
                    onTap: onBackup,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Restore',
                    icon: Icons.cloud_download_outlined,
                    primary: false,
                    loading: busy,
                    onTap: onRestore,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: busy ? null : onSignOut,
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.outfit(
                      color: AppColors.textTertiary, fontSize: 13),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: busy ? null : onSignIn,
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.login_rounded, size: 18),
                label: Text(
                  'Sign in with Google',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final bool loading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12));
    final indicator = const SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
          strokeWidth: 2, color: Colors.white),
    );

    return SizedBox(
      height: 46,
      child: primary
          ? FilledButton.icon(
              onPressed: loading ? null : onTap,
              icon: loading ? indicator : Icon(icon, size: 16),
              label: Text(label,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: shape,
              ),
            )
          : OutlinedButton.icon(
              onPressed: loading ? null : onTap,
              icon: Icon(icon, size: 16),
              label: Text(label,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.surfaceBorder),
                shape: shape,
              ),
            ),
    );
  }
}
