import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/constants.dart';
import '../app/routes.dart';
import '../app/theme_preset.dart';
import '../services/storage_service.dart';
import '../services/school_data_service.dart';
import '../services/schedule_service.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';
import '../services/break_notification_service.dart';
import '../services/backup_service.dart';
import '../services/live_activity_service.dart';
import '../models/school_year.dart';
import '../data/school_profiles_data.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/backup_sheet.dart';
import '../widgets/theme_picker_grid.dart';
import '../services/achievement_service.dart';
import '../services/streak_service.dart';
import '../services/persona_service.dart';
import '../data/achievements_data.dart';
import '../data/personas_data.dart';
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
  bool _liveActivityEnabled = false;
  bool _liveActivityAvailable = false;
  int _versionTapCount = 0;

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
      _liveActivityEnabled =
          StorageService.getBool(StorageKeys.liveActivityEnabled) ?? false;
    });
    _loadBackupState();
    _loadLiveActivityAvailability();
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

  Future<void> _loadLiveActivityAvailability() async {
    final available = await LiveActivityService.isAvailable();
    if (mounted) setState(() => _liveActivityAvailable = available);
  }

  Widget _buildLiveActivityRow() {
    if (!_liveActivityAvailable) return const SizedBox.shrink();
    return SettingsRow(
      icon: Icons.lock_clock_outlined,
      label: 'Lock-screen countdown',
      subtitle: 'Android 14+ persistent notification',
      trailing: Switch(
        value: _liveActivityEnabled,
        onChanged: (v) async {
          if (v) {
            final ok = await LiveActivityService.start();
            if (ok) setState(() => _liveActivityEnabled = true);
          } else {
            await LiveActivityService.stop();
            setState(() => _liveActivityEnabled = false);
          }
        },
      ),
    );
  }

  Future<void> _editAiApiKey() async {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: _aiApiKey);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('AI API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste your Groq API key (starts with gsk_) from console.groq.com for unlimited scans. Leave empty to use the free built-in proxy (5 scans/day).',
              style: GoogleFonts.outfit(
                  color: theme.colorScheme.onSurface.withAlpha(180), fontSize: 13, height: 1.55),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              obscureText: true,
              style:
                  GoogleFonts.outfit(color: theme.colorScheme.onSurface, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'gsk_…',
                hintStyle: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withAlpha(120)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withAlpha(120)))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style:
                  TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
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
    final theme = Theme.of(context);
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
      backgroundColor: theme.colorScheme.surface,
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
              color: theme.dividerTheme.color ?? AppColors.surfaceBorder,
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
                color: theme.colorScheme.onSurface,
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
                        ? theme.colorScheme.primary.withAlpha(20)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: selected
                        ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3))
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
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check_rounded,
                            color: theme.colorScheme.primary, size: 18),
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
    await Navigator.pushNamed(context, Routes.personaPicker);
    setState(() {
      _widgetPersona = PersonaService.instance.current.id;
    });
  }
  Future<void> _setAutoBackup(String value) async {
    await StorageService.saveString(StorageKeys.autoBackup, value);
    setState(() => _autoBackup = value);
  }

  Future<void> _showAutoBackupPicker() async {
    final theme = Theme.of(context);
    final options = [
      ('off', 'Off', 'Manual backup only'),
      ('daily', 'Daily', 'Backs up once every 24 hours'),
      ('weekly', 'Weekly', 'Backs up once every 7 days'),
      ('monthly', 'Monthly', 'Backs up once every 30 days'),
    ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
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
              color: theme.dividerTheme.color ?? AppColors.surfaceBorder,
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
                    color: theme.colorScheme.onSurface)),
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
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              )),
                          Text(o.$3,
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withAlpha(120))),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_rounded,
                          color: theme.colorScheme.primary, size: 18),
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
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear all data?'),
        content: Text(
          'This will delete your schedule, reminders, and cached school data.',
          style: GoogleFonts.outfit(
              color: theme.colorScheme.onSurface.withAlpha(180), height: 1.55),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withAlpha(120))),
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              // bottom: false — we handle bottom clearance ourselves below.
              // SafeArea only knows about the system nav bar, not the
              // floating LimelightNavBar (~84 px). Using bottom:true here
              // would leave content hidden behind the custom nav bar.
              bottom: false,
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
                        color: theme.colorScheme.onSurface,
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
                                  color: theme.colorScheme.onSurface.withAlpha(180),
                                  fontSize: 13),
                            ),
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, Routes.countrySelection);
                              _load();
                            },
                          ),
                          SettingsRowDivider(),
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
                            trailing: Icon(Icons.chevron_right,
                                color: theme.colorScheme.onSurface.withAlpha(120), size: 20),
                            onTap: _selectProfile,
                          ),
                          SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.refresh_rounded,
                            label: 'Refresh School Data',
                            subtitle: _lastUpdated != null
                                ? 'Updated ${DateFormat('d MMM yyyy').format(_lastUpdated!)}'
                                : 'Never updated',
                            trailing: _refreshing
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.primary),
                                  )
                                : Icon(Icons.chevron_right,
                                    color: theme.colorScheme.onSurface.withAlpha(120), size: 20),
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
                                  unawaited(AchievementService.onNotificationToggled('general'));
                                }
                                await StorageService.saveBool(
                                    StorageKeys.notificationsEnabled, v);
                                setState(() => _notificationsEnabled = v);
                              },
                            ),
                          ),
                          SettingsRowDivider(),
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
                                if (v) unawaited(AchievementService.onNotificationToggled('break'));
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
                          SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.list_alt_outlined,
                            label: 'View Reminders',
                            trailing: Icon(Icons.chevron_right,
                                color: theme.colorScheme.onSurface.withAlpha(120), size: 20),
                            onTap: () =>
                                Navigator.pushNamed(context, Routes.reminders),
                          ),
                          SettingsRowDivider(),
                          _buildLiveActivityRow(),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Appearance ──────────────────────────────────────────
                    SettingsSectionLabel('Appearance'),
                    GlassmorphicCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.palette_outlined,
                                  size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Theme',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              ValueListenableBuilder<ThemePreset>(
                                valueListenable: AppThemeController.notifier,
                                builder: (ctx, current, _) => Text(
                                  '${current.emoji} ${current.name}',
                                  style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withAlpha(120)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const ThemePickerGrid(),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Vibe & Social ───────────────────────────────────────
                    SettingsSectionLabel('Vibe & Social'),
                    GlassmorphicCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SettingsRow(
                            icon: Icons.sensors_rounded,
                            label: 'Vibe Beacon',
                            subtitle:
                                'Show nearby students matching your persona (Bluetooth, opt-in)',
                            trailing: Switch(
                              value: StorageService.getBool(
                                      StorageKeys.vibeBeaconEnabled) ??
                                  false,
                              onChanged: (v) async {
                                await StorageService.saveBool(
                                    StorageKeys.vibeBeaconEnabled, v);
                                setState(() {});
                              },
                            ),
                          ),
                          SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.auto_awesome_rounded,
                            label: 'AI Weekly Recap',
                            subtitle: () {
                              final hasKey = (StorageService.getString(
                                          StorageKeys.groqApiKey) ??
                                      '')
                                  .isNotEmpty;
                              if (!hasKey) {
                                return 'Add a Groq key below to enable.';
                              }
                              return 'Sunday 19:00 notification, persona-tuned one-liner';
                            }(),
                            trailing: Switch(
                              value: StorageService.getBool(
                                      StorageKeys.personalizedRecapEnabled) ??
                                  true,
                              onChanged: (v) async {
                                await StorageService.saveBool(
                                    StorageKeys.personalizedRecapEnabled, v);
                                setState(() {});
                              },
                            ),
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
                            trailing: Icon(Icons.chevron_right,
                                color: theme.colorScheme.onSurface.withAlpha(120), size: 20),
                            onTap: _editAiApiKey,
                          ),
                          SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.widgets_outlined,
                            label: 'Persona',
                            subtitle: () {
                              final p = personaById(_widgetPersona);
                              final total = kPersonas.length;
                              final unlocked =
                                  PersonaService.instance.unlockedPersonas.length;
                              return '${p.name} ${p.emoji} · $unlocked / $total unlocked';
                            }(),
                            trailing: Icon(Icons.chevron_right,
                                color: theme.colorScheme.onSurface.withAlpha(120), size: 20),
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
                            trailing: Icon(Icons.chevron_right,
                                color: theme.colorScheme.onSurface.withAlpha(120), size: 20),
                            onTap: () =>
                                Navigator.pushNamed(context, Routes.stats),
                          ),
                          SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.emoji_events_rounded,
                            label: 'Achievements',
                            subtitle: () {
                              final count = AchievementService.allUnlocks.length;
                              final total = kAchievements.length;
                              return '$count / $total unlocked';
                            }(),
                            trailing: Icon(Icons.chevron_right,
                                color: theme.colorScheme.onSurface.withAlpha(120), size: 20),
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
                            trailing: Icon(Icons.chevron_right,
                                color: theme.colorScheme.onSurface.withAlpha(120), size: 20),
                            onTap: _showBackupSheet,
                          ),
                          SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.schedule_outlined,
                            label: 'Auto-backup',
                            subtitle: switch (_autoBackup) {
                              'daily' => 'Daily',
                              'weekly' => 'Weekly',
                              'monthly' => 'Monthly',
                              _ => 'Off',
                            },
                            trailing: Icon(Icons.chevron_right,
                                color: theme.colorScheme.onSurface.withAlpha(120), size: 20),
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
                        trailing: Icon(Icons.chevron_right,
                            color: theme.colorScheme.onSurface.withAlpha(120), size: 20),
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
                            trailing: Icon(Icons.open_in_new,
                                color: theme.colorScheme.onSurface.withAlpha(120), size: 18),
                            onTap: () => launchUrl(
                              Uri.parse('https://github.com/xynnpg/breakcount'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                          SettingsRowDivider(),
                          SettingsRow(
                            icon: Icons.coffee_rounded,
                            label: 'Buy Me a Coffee',
                            subtitle: 'Support BreakCount development',
                            trailing: Icon(Icons.open_in_new,
                                color: theme.colorScheme.onSurface.withAlpha(120), size: 18),
                            onTap: () => launchUrl(
                              Uri.parse('https://buymeacoffee.com/xynnpg'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Dev Tools (gated behind you_are_a_dev achievement) ─
                    if (AchievementService.isUnlocked('you_are_a_dev')) ...[
                      SettingsSectionLabel('Dev Tools'),
                      GlassmorphicCard(
                        padding: EdgeInsets.zero,
                        child: SettingsRow(
                          icon: Icons.all_inclusive_rounded,
                          label: 'Unlock Everything',
                          subtitle: 'Unlock all achievements, themes & personas',
                          onTap: _unlockEverything,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    _buildAbout(),
                    // Dynamic bottom clearance: LimelightNavBar height (64px)
                    // + its vertical padding (8+12=20px) + system bottom inset.
                    // This ensures content is never hidden behind the nav bar
                    // regardless of device (notch phones, gesture nav, etc).
                    SizedBox(
                      height: 84 +
                          MediaQuery.of(context).padding.bottom,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockEverything() async {
    // Force streak to 365 — satisfies every streak-gated theme/persona.
    // Mirror StreakService internals since debugSet is test-only.
    await StorageService.saveInt('streak_current', 365);
    await StorageService.saveInt('streak_longest', 365);
    StreakService.currentNotifier.value = 365;
    StreakService.longestNotifier.value = 365;
    // Unlock every achievement.
    for (final a in kAchievements) {
      await AchievementService.unlock(a.id);
    }
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 All achievements, themes & personas unlocked!')),
      );
    }
  }

  Future<void> _showBackupSheet() async {
    final theme = Theme.of(context);
    setState(() => _backupError = null);
    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
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
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onLongPress: () async {
              if (AchievementService.isUnlocked('you_are_a_dev')) return;
              setState(() => _versionTapCount++);
              if (_versionTapCount >= 7) {
                await AchievementService.unlock('you_are_a_dev');
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🖥️ Dev mode unlocked!',
                          style: GoogleFonts.outfit()),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, Routes.changelog),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: theme.dividerTheme.color ?? AppColors.surfaceBorder),
                  color: theme.colorScheme.surface,
                  boxShadow: const [AppElevation.low],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.coffee_rounded,
                        size: 12, color: theme.colorScheme.primary),
                    const SizedBox(width: 5),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (ctx, snap) {
                        final version = snap.data?.version ?? '2.1.0';
                        return Text(
                          'BreakCount v$version',
                          style: GoogleFonts.outfit(
                              color: theme.colorScheme.onSurface.withAlpha(120),
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'School data: Bundled · OpenHolidays API',
            style: GoogleFonts.outfit(
                color: theme.colorScheme.onSurface.withAlpha(120), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

