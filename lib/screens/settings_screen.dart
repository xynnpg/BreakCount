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
import '../data/school_profiles_data.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/backup_sheet.dart';
import '../services/achievement_service.dart';
import '../services/widget_service.dart';
import 'settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  String _country = '';
  String? _schoolProfileId;
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
  String _autoBackup = 'off';
  String _widgetPersona = 'hype';

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
      _schoolProfileId =
          StorageService.getString(StorageKeys.schoolProfile);
      _lastUpdated = SchoolDataService.lastUpdated();
      _notificationsEnabled =
          StorageService.getBool(StorageKeys.notificationsEnabled) ?? true;
      _breakNotificationsEnabled =
          StorageService.getBool(StorageKeys.breakNotificationsEnabled) ?? true;
      _aiApiKey = StorageService.getString(StorageKeys.aiApiKey) ?? '';
      _autoBackup = StorageService.getString(StorageKeys.autoBackup) ?? 'off';
      _widgetPersona =
          StorageService.getString(StorageKeys.widgetPersona) ?? 'hype';
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

  Future<void> _selectProfile() async {
    final countryKey = _country.toLowerCase();
    final profiles = kSchoolProfiles
        .where((p) => p.country == countryKey)
        .toList();
    if (profiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No profiles available for $_country',
              style: GoogleFonts.outfit()),
        ),
      );
      return;
    }
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceBorder,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'School Profile',
              style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 4, AppSpacing.lg, 24),
            itemCount: profiles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (_, i) {
              final p = profiles[i];
              final selected = _schoolProfileId == p.id;
              return InkWell(
                onTap: () {
                  StorageService.saveString(
                      StorageKeys.schoolProfile, p.id);
                  setState(() => _schoolProfileId = p.id);
                  Navigator.pop(ctx);
                },
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryLight
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: selected
                        ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.displayName,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_rounded,
                            color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showPersonaPicker() async {
    final options = [
      ('hype', 'Hype', '🔥', 'LET\'S GO only 14 days!!!'),
      ('chill', 'Chill', '😎', 'eh, 14 days'),
      ('dramatic', 'Dramatic', '😭', 'I CANNOT 14 MORE DAYS'),
      ('sarcastic', 'Sarcastic', '🙄', '14 days. Cool. Fine. Whatever.'),
    ];
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceBorder,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text('Widget Personality',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text('How the home screen widget talks to you',
                style: GoogleFonts.outfit(
                    fontSize: 12, color: AppColors.textTertiary)),
          ),
          const SizedBox(height: 8),
          ...options.map((o) {
            final selected = _widgetPersona == o.$1;
            return InkWell(
              onTap: () {
                StorageService.saveString(StorageKeys.widgetPersona, o.$1);
                setState(() => _widgetPersona = o.$1);
                WidgetService.update();
                Navigator.pop(ctx);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: 12),
                child: Row(
                  children: [
                    Text(o.$3,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.$2,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              )),
                          Text('"${o.$4}"',
                              style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 18),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _setAutoBackup(String value) async {
    await StorageService.saveString(StorageKeys.autoBackup, value);
    setState(() => _autoBackup = value);
  }

  Future<void> _showAutoBackupPicker() async {
    final options = [
      ('off', 'Off', 'Manual backup only'),
      ('daily', 'Daily', 'Backs up once every 24 hours'),
      ('weekly', 'Weekly', 'Backs up once every 7 days'),
      ('monthly', 'Monthly', 'Backs up once every 30 days'),
    ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceBorder,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text('Auto-backup',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 8),
          ...options.map((o) {
            final selected = _autoBackup == o.$1;
            return InkWell(
              onTap: () {
                _setAutoBackup(o.$1);
                Navigator.pop(ctx);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.$2,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              )),
                          Text(o.$3,
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 18),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
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
                    SettingsSectionLabel('School Calendar'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SettingsRow(
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
                          const SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.school_outlined,
                            label: 'School Profile',
                            subtitle: () {
                              if (_schoolProfileId == null) {
                                return 'Not set — affects subject importance';
                              }
                              try {
                                final p = kSchoolProfiles.firstWhere(
                                    (p) => p.id == _schoolProfileId);
                                return p.displayName;
                              } catch (_) {
                                return 'Not set';
                              }
                            }(),
                            trailing: const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary, size: 20),
                            onTap: _selectProfile,
                          ),
                          const SettingsRowDivider(),
                          SettingsRow(
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
                    SettingsSectionLabel('Reminders'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SettingsRow(
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
                          const SettingsRowDivider(),
                          SettingsRow(
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
                          const SettingsRowDivider(),
                          SettingsRow(
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
                    SettingsSectionLabel('AI Features'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SettingsRow(
                            icon: Icons.auto_awesome_outlined,
                            label: 'Groq API Key (optional)',
                            subtitle: _aiApiKey.isEmpty
                                ? 'Not set — needed for photo scan'
                                : 'Key saved (${_aiApiKey.length} chars)',
                            trailing: const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary, size: 20),
                            onTap: _editAiApiKey,
                          ),
                          const SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.widgets_outlined,
                            label: 'Widget Personality',
                            subtitle: switch (_widgetPersona) {
                              'chill' => 'Chill 😎',
                              'dramatic' => 'Dramatic 😭',
                              'sarcastic' => 'Sarcastic 🙄',
                              _ => 'Hype 🔥',
                            },
                            trailing: const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary, size: 20),
                            onTap: _showPersonaPicker,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Statistics & Achievements ──────────────────────────────
                    SettingsSectionLabel('Statistics'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SettingsRow(
                            icon: Icons.bar_chart_rounded,
                            label: 'Statistics',
                            subtitle: 'School year progress & insights',
                            trailing: const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary, size: 20),
                            onTap: () =>
                                Navigator.pushNamed(context, Routes.stats),
                          ),
                          const SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.emoji_events_rounded,
                            label: 'Achievements',
                            subtitle: () {
                              final count = AchievementService.allUnlocks.length;
                              const total = 25;
                              return '$count / $total unlocked';
                            }(),
                            trailing: const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary, size: 20),
                            onTap: () =>
                                Navigator.pushNamed(context, Routes.achievements),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Backup & Restore ──────────────────────────────────────
                    SettingsSectionLabel('Backup & Restore'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SettingsRow(
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
                          const SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.schedule_outlined,
                            label: 'Auto-backup',
                            subtitle: switch (_autoBackup) {
                              'daily' => 'Daily',
                              'weekly' => 'Weekly',
                              'monthly' => 'Monthly',
                              _ => 'Off',
                            },
                            trailing: const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary, size: 20),
                            onTap: _showAutoBackupPicker,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Data ─────────────────────────────────────────────────
                    SettingsSectionLabel('Data'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: SettingsRow(
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
                    SettingsSectionLabel('Support'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SettingsRow(
                            icon: Icons.code_rounded,
                            label: 'GitHub',
                            subtitle: 'View source & report issues',
                            trailing: const Icon(Icons.open_in_new,
                                color: AppColors.textTertiary, size: 18),
                            onTap: () => launchUrl(
                              Uri.parse('https://github.com/xynnpg/breakcount'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                          const SettingsRowDivider(),
                          SettingsRow(
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
                        ],
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
              boxShadow: const [AppElevation.low],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.coffee_rounded,
                    size: 12, color: AppColors.primary),
                const SizedBox(width: 5),
                Text(
                  'BreakCount v2.0.1',
                  style: GoogleFonts.outfit(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
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

