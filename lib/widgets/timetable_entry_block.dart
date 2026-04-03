import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/schedule.dart';
import '../models/subject.dart';

// ── Overlap layout ──────────────────────────────────────────────────────────

class EntryLayout {
  final ScheduleEntry entry;
  final int column;
  final int totalColumns;
  const EntryLayout({
    required this.entry,
    required this.column,
    required this.totalColumns,
  });
}

/// Greedy column assignment for overlapping entries.
List<EntryLayout> computeLayout(List<ScheduleEntry> entries) {
  if (entries.isEmpty) return [];
  final sorted = List.of(entries)
    ..sort((a, b) => a.startTime
        .toFractionalHours()
        .compareTo(b.startTime.toFractionalHours()));
  final columnEnds = <double>[];
  final rawLayouts = <({ScheduleEntry entry, int col})>[];

  for (final entry in sorted) {
    final start = entry.startTime.toFractionalHours();
    final end = entry.endTime.toFractionalHours();
    int col = 0;
    while (col < columnEnds.length && columnEnds[col] > start + 0.01) {
      col++;
    }
    if (col == columnEnds.length) {
      columnEnds.add(end);
    } else {
      columnEnds[col] = end;
    }
    rawLayouts.add((entry: entry, col: col));
  }

  final total = columnEnds.length.clamp(1, 3);
  return rawLayouts
      .map((r) => EntryLayout(
            entry: r.entry,
            column: r.col.clamp(0, total - 1),
            totalColumns: total,
          ))
      .toList();
}

// ── Day column ──────────────────────────────────────────────────────────────

class TimetableDayColumn extends StatelessWidget {
  final List<ScheduleEntry> entries;
  final List<Subject> subjects;
  final bool isToday;
  final double startHour;
  final double hourHeight;
  final double endHour;
  final double dayWidth;
  final Color primary;
  final Function(ScheduleEntry)? onEntryTap;
  // Drag state
  final String? draggingEntryId;
  final int? dragTargetHour;
  final bool isDragTargetDay;
  final Function(ScheduleEntry, Offset)? onEntryLongPressStart;
  final Function(Offset)? onEntryLongPressMove;
  final Function(Offset)? onEntryLongPressEnd;
  final VoidCallback? onEntryLongPressCancel;

  const TimetableDayColumn({
    super.key,
    required this.entries,
    required this.subjects,
    required this.isToday,
    required this.startHour,
    required this.hourHeight,
    required this.endHour,
    required this.dayWidth,
    required this.primary,
    required this.onEntryTap,
    this.draggingEntryId,
    this.dragTargetHour,
    this.isDragTargetDay = false,
    this.onEntryLongPressStart,
    this.onEntryLongPressMove,
    this.onEntryLongPressEnd,
    this.onEntryLongPressCancel,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = (endHour - startHour) * hourHeight;
    final now = DateTime.now();
    final currentHour = now.hour + now.minute / 60.0;
    final indicatorTop = (currentHour - startHour) * hourHeight;
    final layouts = computeLayout(entries);

    return SizedBox(
      width: dayWidth,
      height: totalHeight,
      child: Stack(
        children: [
          if (isToday)
            Positioned.fill(child: Container(color: primary.withAlpha(6))),

          ...List.generate((endHour - startHour).toInt(), (i) {
            return Positioned(
              top: i * hourHeight,
              left: 0,
              right: 0,
              child: Divider(
                height: 1,
                color: Colors.white.withAlpha(isToday ? 12 : 7),
              ),
            );
          }),

          // Drop target highlight
          if (isDragTargetDay && dragTargetHour != null)
            Positioned(
              top: (dragTargetHour! - startHour) * hourHeight,
              left: 2,
              right: 2,
              height: hourHeight * 50 / 60,
              child: Container(
                decoration: BoxDecoration(
                  color: primary.withAlpha(30),
                  border:
                      Border.all(color: primary.withAlpha(120), width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

          ...layouts.map((layout) {
            final entry = layout.entry;
            final top =
                (entry.startTime.toFractionalHours() - startHour) * hourHeight;
            final height =
                (entry.endTime.toFractionalHours() -
                        entry.startTime.toFractionalHours()) *
                    hourHeight;
            Subject? subject;
            try {
              subject = subjects.firstWhere((s) => s.id == entry.subjectId);
            } catch (_) {}

            const padding = 2.0;
            final laneWidth =
                (dayWidth - padding * (layout.totalColumns + 1)) /
                    layout.totalColumns;
            final left = padding + layout.column * (laneWidth + padding);

            return Positioned(
              top: top.clamp(0.0, totalHeight - 24),
              left: left,
              width: laneWidth,
              height: height.clamp(22, totalHeight),
              child: TimetableEntryBlock(
                entry: entry,
                subject: subject,
                isNarrow: layout.totalColumns > 1,
                isDragging: draggingEntryId == entry.id,
                onTap: onEntryTap != null ? () => onEntryTap!(entry) : null,
                onLongPressStart: onEntryLongPressStart != null
                    ? (pos) => onEntryLongPressStart!(entry, pos)
                    : null,
                onLongPressMove: onEntryLongPressMove,
                onLongPressEnd: onEntryLongPressEnd,
                onLongPressCancel: onEntryLongPressCancel,
              ),
            );
          }),

          if (isToday &&
              currentHour >= startHour &&
              currentHour <= endHour)
            Positioned(
              top: indicatorTop - 1,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: primary, shape: BoxShape.circle),
                  ),
                  Expanded(
                    child: Container(height: 2, color: primary.withAlpha(180)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Entry block ─────────────────────────────────────────────────────────────

class TimetableEntryBlock extends StatefulWidget {
  final ScheduleEntry entry;
  final Subject? subject;
  final bool isNarrow;
  final bool isDragging;
  final VoidCallback? onTap;
  final Function(Offset)? onLongPressStart;
  final Function(Offset)? onLongPressMove;
  final Function(Offset)? onLongPressEnd;
  final VoidCallback? onLongPressCancel;

  const TimetableEntryBlock({
    super.key,
    required this.entry,
    required this.subject,
    required this.isNarrow,
    this.isDragging = false,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressMove,
    this.onLongPressEnd,
    this.onLongPressCancel,
  });

  @override
  State<TimetableEntryBlock> createState() => _TimetableEntryBlockState();
}

class _TimetableEntryBlockState extends State<TimetableEntryBlock> {
  Offset? _downPos;

  @override
  Widget build(BuildContext context) {
    final color = widget.subject != null
        ? Color(widget.subject!.colorValue)
        : Theme.of(context).colorScheme.primary;

    // GestureDetector must be OUTSIDE Opacity so that onLongPressMoveUpdate
    // keeps firing even when isDragging=true makes the block invisible.
    // Opacity(0.0) sets RenderOpacity._alpha=0 which causes hitTest to return
    // false, silently killing all touch events on any child GestureDetector.
    // HitTestBehavior.opaque ensures this widget always passes hit testing.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPressDown: (details) => _downPos = details.globalPosition,
      onLongPressStart: (_) {
        if (widget.onLongPressStart != null && _downPos != null) {
          widget.onLongPressStart!(_downPos!);
        }
      },
      onLongPressMoveUpdate: (details) =>
          widget.onLongPressMove?.call(details.globalPosition),
      onLongPressEnd: (details) =>
          widget.onLongPressEnd?.call(details.globalPosition),
      onLongPressCancel: widget.onLongPressCancel,
      child: Opacity(
        opacity: widget.isDragging ? 0.0 : 1.0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final blockHeight = constraints.maxHeight;
            return Container(
              margin: const EdgeInsets.only(bottom: 1),
              decoration: BoxDecoration(
                color: color.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
                border: Border(left: BorderSide(color: color, width: 3)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (blockHeight > 40)
                    Text(
                      '${widget.entry.startTime.hour.toString().padLeft(2, '0')}:${widget.entry.startTime.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.outfit(
                        fontSize: 8,
                        color: color.withAlpha(160),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  Text(
                    widget.subject?.name ?? '?',
                    style: GoogleFonts.outfit(
                      fontSize: widget.isNarrow ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (!widget.isNarrow && widget.entry.room != null)
                    Row(
                      children: [
                        Icon(Icons.room_outlined,
                            size: 8, color: color.withAlpha(160)),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            widget.entry.room!,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: color.withAlpha(180),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
