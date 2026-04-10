import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/constants.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

// ── Entry detail bottom sheet ─────────────────────────────────────────────────

class EntryDetailSheet extends StatefulWidget {
  final ScheduleEntry entry;
  final Subject subject;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const EntryDetailSheet({
    super.key,
    required this.entry,
    required this.subject,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<EntryDetailSheet> createState() => _EntryDetailSheetState();
}

class _EntryDetailSheetState extends State<EntryDetailSheet> {
  bool _notifyEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotifState();
  }

  void _loadNotifState() {
    final raw = StorageService.getString(StorageKeys.classNotifications) ?? '';
    final ids = raw.isEmpty ? <String>[] : raw.split(',');
    setState(() => _notifyEnabled = ids.contains(widget.entry.id));
  }

  Future<void> _toggleNotification(bool value) async {
    final raw = StorageService.getString(StorageKeys.classNotifications) ?? '';
    final ids = raw.isEmpty ? <String>[] : raw.split(',').toList();
    if (value) {
      if (!ids.contains(widget.entry.id)) ids.add(widget.entry.id);
      await NotificationService.scheduleClassNotification(
        widget.entry.id,
        widget.subject.name,
        widget.entry.dayOfWeek,
        widget.entry.startTime.hour,
        widget.entry.startTime.minute,
      );
    } else {
      ids.remove(widget.entry.id);
      await NotificationService.cancelClassNotification(widget.entry.id);
    }
    await StorageService.saveString(
        StorageKeys.classNotifications, ids.join(','));
    if (mounted) setState(() => _notifyEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.subject.colorValue);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 4, bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color,
                        Color.lerp(color, const Color(0xFFA0714F), 0.5)!
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subject.name,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${widget.entry.startTime.format24h()} – ${widget.entry.endTime.format24h()}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.textSecondary, size: 20),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.surfaceBorder, height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 16, color: AppColors.textTertiary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Notify 10 min before',
                    style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
                Switch(
                  value: _notifyEnabled,
                  onChanged: _toggleNotification,
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            if (widget.subject.teacher != null)
              DetailRow(
                  icon: Icons.person_outline, text: widget.subject.teacher!),
            if (widget.entry.room != null || widget.subject.room != null)
              DetailRow(
                  icon: Icons.room_outlined,
                  text: widget.entry.room ?? widget.subject.room!),
            DetailRow(
                icon: Icons.calendar_today_outlined,
                text: widget.entry.weekType.label),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const DetailRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Text(text,
              style: GoogleFonts.outfit(
                  color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
