import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../app/constants.dart';
import 'timetable_entry_block.dart';

/// Weekly timetable grid — Monday to Friday, time slots as rows.
/// Supports true drag-and-drop via long-press: hold → overlay card follows
/// finger → release snaps to X:00–X:50 slot in the target day.
class TimetableGrid extends StatefulWidget {
  final Schedule schedule;
  final List<Subject> subjects;
  final WeekType currentWeek;
  final Function(ScheduleEntry)? onEntryTap;
  final Function(ScheduleEntry, int newDay, ScheduleTime start, ScheduleTime end)?
      onEntryMoved;

  const TimetableGrid({
    super.key,
    required this.schedule,
    required this.subjects,
    required this.currentWeek,
    this.onEntryTap,
    this.onEntryMoved,
  });

  @override
  State<TimetableGrid> createState() => _TimetableGridState();
}

class _TimetableGridState extends State<TimetableGrid> {
  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  static const double _hourHeight = 64.0;
  static const double _startHour = 7.0;
  static const double _endHour = 20.0;
  static const double _labelWidth = 40.0;
  static const double _dayWidth = 82.0;

  ScheduleEntry? _draggingEntry;
  String? _draggingEntryId;
  OverlayEntry? _overlayEntry;
  // ValueNotifier drives overlay position directly — no markNeedsBuild needed.
  final ValueNotifier<Offset> _overlayPosNotifier = ValueNotifier(Offset.zero);
  int _dragTargetHour = 7;
  int _dragTargetDay = 1;

  final ScrollController _hScrollCtrl = ScrollController();
  final ScrollController _vScrollCtrl = ScrollController();
  final GlobalKey _gridKey = GlobalKey();

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayPosNotifier.dispose();
    _hScrollCtrl.dispose();
    _vScrollCtrl.dispose();
    super.dispose();
  }

  void _startDrag(ScheduleEntry entry, Offset initialPos) {
    HapticFeedback.mediumImpact();
    _computeTargetSlot(initialPos);
    _overlayPosNotifier.value = initialPos;
    setState(() {
      _draggingEntry = entry;
      _draggingEntryId = entry.id;
    });
    _overlayEntry = OverlayEntry(builder: (_) => _buildOverlay());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateDrag(Offset globalPos) {
    _computeTargetSlot(globalPos);
    _overlayPosNotifier.value = globalPos;
    _overlayEntry?.markNeedsBuild();
    if (mounted) setState(() {});
  }

  void _endDrag(Offset globalPos) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    final entry = _draggingEntry;
    final day = _dragTargetDay;
    final hour = _dragTargetHour;
    setState(() {
      _draggingEntry = null;
      _draggingEntryId = null;
    });
    if (entry != null) {
      final start = ScheduleTime(hour: hour, minute: 0);
      final end = ScheduleTime(hour: hour, minute: 50);
      widget.onEntryMoved?.call(entry, day, start, end);
    }
  }

  void _cancelDrag() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _draggingEntry = null;
      _draggingEntryId = null;
    });
  }

  // Pure computation — no setState, safe to call mid-gesture.
  void _computeTargetSlot(Offset globalPos) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final origin = box.localToGlobal(Offset.zero);
    final localX = globalPos.dx - origin.dx;
    final localY = globalPos.dy - origin.dy;
    _dragTargetHour =
        ((localY / _hourHeight) + _startHour).floor().clamp(7, 19);
    _dragTargetDay =
        ((localX - _labelWidth) / _dayWidth).floor().clamp(0, 4) + 1;
  }

  Widget _buildOverlay() {
    final entry = _draggingEntry;
    if (entry == null) return const SizedBox.shrink();
    Subject? subject;
    try {
      subject = widget.subjects.firstWhere((s) => s.id == entry.subjectId);
    } catch (_) {}
    final color =
        subject != null ? Color(subject.colorValue) : AppColors.primary;

    return ValueListenableBuilder<Offset>(
      valueListenable: _overlayPosNotifier,
      builder: (_, offset, child) => Positioned(
        left: offset.dx - (_dayWidth - 4) / 2,
        top: (offset.dy - 20).clamp(0.0, double.infinity),
        width: _dayWidth - 4,
        child: child!,
      ),
      child: IgnorePointer(
        child: RepaintBoundary(
          child: Material(
            color: Colors.transparent,
            child: Transform.scale(
              scale: 1.06,
              child: Container(
                height: _hourHeight * 50 / 60,
                decoration: BoxDecoration(
                  color: color.withAlpha(60),
                  borderRadius: BorderRadius.circular(8),
                  border: Border(left: BorderSide(color: color, width: 3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                child: Text(
                  subject?.name ?? '?',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday;
    final primary = Theme.of(context).colorScheme.primary;
    final isDragging = _draggingEntry != null;

    // Listener drives move/up/cancel at the raw pointer level — completely
    // independent of the gesture arena and child Opacity states. This
    // guarantees _updateDrag is called on every pointer move during a drag
    // even if per-block onLongPressMoveUpdate fails to fire.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (event) {
        if (_draggingEntry != null) _updateDrag(event.position);
      },
      onPointerUp: (event) {
        if (_draggingEntry != null) _endDrag(event.position);
      },
      onPointerCancel: (_) {
        if (_draggingEntry != null) _cancelDrag();
      },
      child: SingleChildScrollView(
      controller: _hScrollCtrl,
      scrollDirection: Axis.horizontal,
      physics: isDragging
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      child: SizedBox(
        width: _labelWidth + 5 * _dayWidth,
        child: Column(
          children: [
            _DayHeader(
              days: _days,
              todayIndex: today - 1,
              primary: primary,
              labelWidth: _labelWidth,
              dayWidth: _dayWidth,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _vScrollCtrl,
                physics: isDragging
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                child: SizedBox(
                  key: _gridKey,
                  height: (_endHour - _startHour) * _hourHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: _labelWidth,
                        child: _TimeLabels(
                          startHour: _startHour.toInt(),
                          endHour: _endHour.toInt(),
                          hourHeight: _hourHeight,
                        ),
                      ),
                      ...List.generate(5, (i) {
                        final dayEntries = widget.schedule
                            .entriesForDay(i + 1, widget.currentWeek);
                        return TimetableDayColumn(
                          entries: dayEntries,
                          subjects: widget.subjects,
                          isToday: today - 1 == i,
                          startHour: _startHour,
                          hourHeight: _hourHeight,
                          endHour: _endHour,
                          dayWidth: _dayWidth,
                          primary: primary,
                          onEntryTap: widget.onEntryTap,
                          draggingEntryId: _draggingEntryId,
                          dragTargetHour:
                              _dragTargetDay == i + 1 ? _dragTargetHour : null,
                          isDragTargetDay:
                              _dragTargetDay == i + 1 && isDragging,
                          onEntryLongPressStart: (entry, pos) =>
                              _startDrag(entry, pos),
                          onEntryLongPressMove: _updateDrag,
                          onEntryLongPressEnd: _endDrag,
                          onEntryLongPressCancel: _cancelDrag,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ), // closes Listener child (SingleChildScrollView)
    ); // closes Listener
  }
}

// ── Day header ──────────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  final List<String> days;
  final int todayIndex;
  final Color primary;
  final double labelWidth;
  final double dayWidth;

  const _DayHeader({
    required this.days,
    required this.todayIndex,
    required this.primary,
    required this.labelWidth,
    required this.dayWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: labelWidth),
        ...List.generate(5, (i) {
          final isToday = i == todayIndex;
          return SizedBox(
            width: dayWidth,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isToday
                        ? primary.withAlpha(80)
                        : Colors.white.withAlpha(12),
                    width: isToday ? 2 : 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isToday
                          ? primary.withAlpha(30)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        days[i],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w400,
                          color: isToday ? primary : AppColors.textTertiary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Time labels ─────────────────────────────────────────────────────────────

class _TimeLabels extends StatelessWidget {
  final int startHour;
  final int endHour;
  final double hourHeight;

  const _TimeLabels({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(endHour - startHour, (i) {
        return Positioned(
          top: i * hourHeight - 8,
          left: 0,
          right: 4,
          child: Text(
            (startHour + i).toString().padLeft(2, '0'),
            textAlign: TextAlign.right,
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w300,
            ),
          ),
        );
      }),
    );
  }
}
