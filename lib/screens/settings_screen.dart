import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/constants.dart';
import '../app/routes.dart';
import '../services/storage_service.dart';
import '../services/school_data_service.dart';
import '../services/schedule_service.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';
import '../services/break_notification_service.dart';
import '../services/backup_service.dart';
import '../models/school_year.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/backup_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  String _country = '';
  DateTime? _lastUpdated;
  bool _notificationsEnabled = true;
  bool _breakNotificationsEnabled = true;
  bool _refreshing = false;
  String _aiApiKey = '';
  bool _backupSignedIn = false;
  String? _backupEmail;
  DateTime? _lastBackupTime;
  bool _backupBusy = false;
  String? _backupError;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _country =
          StorageService.getString(StorageKeys.selectedCountry) ?? 'Not set';
      _lastUpdated = SchoolDataService.lastUpdated();
      _notificationsEnabled =
          StorageService.getBool(StorageKeys.notificationsEnabled) ?? true;
      _breakNotificationsEnabled =
          StorageService.getBool(StorageKeys.breakNotificationsEnabled) ?? true;
      _aiApiKey = StorageService.getString(StorageKeys.aiApiKey) ?? '';
    });
    _loadBackupState();
  }

  Future<void> _loadBackupState() async {
    final signedIn = await BackupService.isSignedIn();
    final email = await BackupService.currentUserEmail();
    final lastBackupRaw =
        StorageService.getString(StorageKeys.lastBackupTime);
    final lastBackup =
        lastBackupRaw != null ? DateTime.tryParse(lastBackupRaw) : null;
    if (mounted) {
      setState(() {
        _backupSignedIn = signedIn;
        _backupEmail = email;
        _lastBackupTime = lastBackup;
      });
    }
  }

  Future<void> _editAiApiKey() async {
    final controller = TextEditingController(text: _aiApiKey);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste your Groq API key (starts with gsk_) from console.groq.com for unlimited scans. Leave empty to use the free built-in proxy (5 scans/day).',
              style: GoogleFonts.outfit(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.55),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              obscureText: true,
              style:
                  GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'gsk_…',
                hintStyle: GoogleFonts.outfit(color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.outfit(color: AppColors.textTertiary))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: Text('Save',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (result == null || !mounted) return;
    await StorageService.saveString(StorageKeys.aiApiKey, result);
    setState(() => _aiApiKey = result);
  }

  Future<void> _refreshData() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    await SchoolDataService.fetchAndCache(_country);
    if (mounted) {
      setState(() {
        _refreshing = false;
        _lastUpdated = SchoolDataService.lastUpdated();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('School calendar updated', style: GoogleFonts.outfit()),
        ),
      );
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: Text(
          'This will delete your schedule, reminders, and cached school data.',
          style: GoogleFonts.outfit(
              color: AppColors.textSecondary, height: 1.55),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Clear All',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await StorageService.clearAll();
    await ScheduleService.clearAll();
    await ReminderService.clearAll();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, Routes.welcome, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── School Calendar ──────────────────────────────────────
                    _SectionLabel('School Calendar'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsRow(
                            icon: Icons.public_outlined,
                            label: 'Country',
                            trailing: Text(
                              '${countryFlag(_country)} $_country',
                              style: GoogleFonts.outfit(
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            ),
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, Routes.countrySelection);
                              _load();
                            },
                          ),
                          _RowDivider(),
                          _SettingsRow(
                            icon: Icons.refresh_rounded,
                            label: 'Refresh School Data',
                            subtitle: _lastUpdated != null
                                ? 'Updated ${DateFormat('d MMM yyyy').format(_lastUpdated!)}'
                                : 'Never updated',
                            trailing: _refreshing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary),
                                  )
                                : const Icon(Icons.chevron_right,
                                    color: AppColors.textTertiary, size: 20),
                            onTap: _refreshData,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Reminders ────────────────────────────────────────────
                    _SectionLabel('Reminders'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsRow(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            trailing: Switch(
                              value: _notificationsEnabled,
                              onChanged: (v) async {
                                if (v) {
                                  await NotificationService.requestPermissions();
                                }
                                await StorageService.saveBool(
                                    StorageKeys.notificationsEnabled, v);
                                setState(() => _notificationsEnabled = v);
                              },
                            ),
                          ),
                          _RowDivider(),
                          _SettingsRow(
                            icon: Icons.event_outlined,
                            label: 'Break Notifications',
                            subtitle: 'Alerts 1 day before breaks start and end',
                            trailing: Switch(
                              value: _breakNotificationsEnabled,
                              onChanged: (v) async {
                                await StorageService.saveBool(
                                    StorageKeys.breakNotificationsEnabled, v);
                                setState(() => _breakNotificationsEnabled = v);
                                final SchoolYear? sy =
                                    SchoolDataService.getCached();
                                if (sy != null) {
                                  if (v) {
                                    await BreakNotificationService
                                        .scheduleBreakNotifications(sy);
                                  } else {
                                    await BreakNotificationService
                                        .cancelBreakNotifications(sy);
                                  }
                                }
                              },
                            ),
                          ),
                          _RowDivider(),
                          _SettingsRow(
                            icon: Icons.list_alt_outlined,
                            label: 'View Reminders',
                            trailing: const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary, size: 20),
                            onTap: () =>
                                Navigator.pushNamed(context, Routes.reminders),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── AI Features ──────────────────────────────────────────
                    _SectionLabel('AI Features'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: _SettingsRow(
                        icon: Icons.auto_awesome_outlined,
                        label: 'Groq API Key (optional)',
                        subtitle: _aiApiKey.isEmpty
                            ? 'Not set — needed for photo scan'
                            : 'Key saved (${_aiApiKey.length} chars)',
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.textTertiary, size: 20),
                        onTap: _editAiApiKey,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Statistics ────────────────────────────────────────────
                    _SectionLabel('Statistics'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: _SettingsRow(
                        icon: Icons.bar_chart_rounded,
                        label: 'Statistics',
                        subtitle: 'School year progress & insights',
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.textTertiary, size: 20),
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.stats),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Backup & Restore ──────────────────────────────────────
                    _SectionLabel('Backup & Restore'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: _SettingsRow(
                        icon: Icons.backup_outlined,
                        label: 'Google Drive Backup',
                        subtitle: _backupSignedIn
                            ? (_lastBackupTime != null
                                ? 'Last backup: ${DateFormat('d MMM yyyy').format(_lastBackupTime!)}'
                                : _backupEmail ?? 'Signed in')
                            : 'Not signed in',
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.textTertiary, size: 20),
                        onTap: _showBackupSheet,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Data ─────────────────────────────────────────────────
                    _SectionLabel('Data'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: _SettingsRow(
                        icon: Icons.delete_outline,
                        label: 'Clear All Data',
                        labelColor: AppColors.error,
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.textTertiary, size: 20),
                        onTap: _clearAllData,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Support ───────────────────────────────────────────────
                    _SectionLabel('Support'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: _SettingsRow(
                        icon: Icons.coffee_rounded,
                        label: 'Buy Me a Coffee',
                        subtitle: 'Support BreakCount development',
                        trailing: const Icon(Icons.open_in_new,
                            color: AppColors.textTertiary, size: 18),
                        onTap: () => launchUrl(
                          Uri.parse('https://buymeacoffee.com/xynnpg'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    _buildAbout(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBackupSheet() async {
    setState(() => _backupError = null);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => BackupSheet(
          signedIn: _backupSignedIn,
          email: _backupEmail,
          lastBackupTime: _lastBackupTime,
          busy: _backupBusy,
          errorMessage: _backupError,
          onSignIn: () async {
            setSheet(() => _backupBusy = true);
            setState(() => _backupBusy = true);
            final nav = Navigator.of(ctx);
            final result = await BackupService.signIn();
            await _loadBackupState();
            if (mounted) {
              setState(() {
                _backupBusy = false;
                _backupError = result.success ? null : result.error;
              });
              setSheet(() {
                _backupBusy = false;
                _backupError = result.success ? null : result.error;
              });
              if (result.success) nav.pop();
            }
          },
          onSignOut: () async {
            final nav = Navigator.of(ctx);
            await BackupService.signOut();
            await _loadBackupState();
            if (mounted) nav.pop();
          },
          onBackup: () async {
            setSheet(() => _backupBusy = true);
            setState(() => _backupBusy = true);
            final nav = Navigator.of(ctx);
            final messenger = ScaffoldMessenger.of(context);
            final result = await BackupService.backup();
            await _loadBackupState();
            if (mounted) {
              setState(() {
                _backupBusy = false;
                _backupError = result.success ? null : result.error;
              });
              setSheet(() {
                _backupBusy = false;
                _backupError = result.success ? null : result.error;
              });
              if (result.success) {
                nav.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Backup complete',
                        style: GoogleFonts.outfit()),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            }
          },
          onRestore: () async {
            setSheet(() => _backupBusy = true);
            setState(() => _backupBusy = true);
            final nav = Navigator.of(ctx);
            final messenger = ScaffoldMessenger.of(context);
            final result = await BackupService.restore();
            if (mounted) {
              setState(() {
                _backupBusy = false;
                _backupError = result.success ? null : result.error;
              });
              setSheet(() {
                _backupBusy = false;
                _backupError = result.success ? null : result.error;
              });
              if (result.success) {
                nav.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Restore complete',
                        style: GoogleFonts.outfit()),
                    backgroundColor: AppColors.success,
                  ),
                );
                _load();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildAbout() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: AppColors.surfaceBorder),
              color: Colors.white,
            ),
            child: Text(
              'BreakCount v1.0',
              style: GoogleFonts.outfit(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'School data: Bundled · OpenHolidays API',
            style: GoogleFonts.outfit(
                color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Shared settings widgets ────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.xs, bottom: AppSpacing.sm, top: 2),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? labelColor;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: labelColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: AppColors.textTertiary),
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 0.5,
      indent: 64,
      endIndent: 0,
      color: AppColors.surfaceBorder,
    );
  }
}
