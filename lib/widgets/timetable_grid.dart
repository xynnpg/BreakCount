import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../app/constants.dart';

/// Weekly timetable grid — Monday to Friday, time slots as rows.
/// Overlapping entries in the same day are laid out side-by-side (Google
/// Calendar style) so they never render on top of each other.
class TimetableGrid extends StatelessWidget {
  final Schedule schedule;
  final List<Subject> subjects;
  final WeekType currentWeek;
  final Function(ScheduleEntry)? onEntryTap;

  const TimetableGrid({
    super.key,
    required this.schedule,
    required this.subjects,
    required this.currentWeek,
    this.onEntryTap,
  });

  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  static const double _hourHeight = 64.0;
  static const double _startHour = 7.0;
  static const double _endHour = 20.0;
  static const double _labelWidth = 40.0;
  static const double _dayWidth = 82.0;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
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
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  height: (_endHour - _startHour) * _hourHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time labels
                      SizedBox(
                        width: _labelWidth,
                        child: _TimeLabels(
                          startHour: _startHour.toInt(),
                          endHour: _endHour.toInt(),
                          hourHeight: _hourHeight,
                        ),
                      ),
                      // Day columns
                      ...List.generate(5, (i) {
                        final dayEntries =
                            schedule.entriesForDay(i + 1, currentWeek);
                        return _DayColumn(
                          entries: dayEntries,
                          subjects: subjects,
                          isToday: today - 1 == i,
                          startHour: _startHour,
                          hourHeight: _hourHeight,
                          endHour: _endHour,
                          dayWidth: _dayWidth,
                          primary: primary,
                          onEntryTap: onEntryTap,
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
    );
  }
}

// ── Day header ─────────────────────────────────────────────────────────────

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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          isToday ? primary.withAlpha(30) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        days[i],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
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

// ── Time labels ────────────────────────────────────────────────────────────

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
            '${startHour + i}',
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

// ── Overlap layout ─────────────────────────────────────────────────────────

class _EntryLayout {
  final ScheduleEntry entry;
  final int column;
  final int totalColumns;
  const _EntryLayout(
      {required this.entry, required this.column, required this.totalColumns});
}

/// Greedy column assignment for overlapping entries.
/// Returns each entry with its column index and total concurrent columns.
List<_EntryLayout> _computeLayout(List<ScheduleEntry> entries) {
  if (entries.isEmpty) return [];

  final sorted = List.of(entries)
    ..sort((a, b) => a.startTime
        .toFractionalHours()
        .compareTo(b.startTime.toFractionalHours()));

  // columns[i] = end time of last entry in column i
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
      .map((r) => _EntryLayout(
            entry: r.entry,
            column: r.col.clamp(0, total - 1),
            totalColumns: total,
          ))
      .toList();
}

// ── Day column ─────────────────────────────────────────────────────────────

class _DayColumn extends StatelessWidget {
  final List<ScheduleEntry> entries;
  final List<Subject> subjects;
  final bool isToday;
  final double startHour;
  final double hourHeight;
  final double endHour;
  final double dayWidth;
  final Color primary;
  final Function(ScheduleEntry)? onEntryTap;

  const _DayColumn({
    required this.entries,
    required this.subjects,
    required this.isToday,
    required this.startHour,
    required this.hourHeight,
    required this.endHour,
    required this.dayWidth,
    required this.primary,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = (endHour - startHour) * hourHeight;
    final now = DateTime.now();
    final currentHour = now.hour + now.minute / 60.0;
    final indicatorTop = (currentHour - startHour) * hourHeight;

    final layouts = _computeLayout(entries);

    return SizedBox(
      width: dayWidth,
      height: totalHeight,
      child: Stack(
        children: [
          // Today highlight column
          if (isToday)
            Positioned.fill(
              child: Container(
                color: primary.withAlpha(6),
              ),
            ),

          // Hour dividers
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

          // Entries with overlap-aware positioning
          ...layouts.map((layout) {
            final entry = layout.entry;
            final top =
                (entry.startTime.toFractionalHours() - startHour) * hourHeight;
            final height = (entry.endTime.toFractionalHours() -
                    entry.startTime.toFractionalHours()) *
                hourHeight;
            Subject? subject;
            try {
              subject = subjects.firstWhere((s) => s.id == entry.subjectId);
            } catch (_) {}

            // Lane positioning within the day column
            const padding = 2.0;
            final laneWidth =
                (dayWidth - padding * (layout.totalColumns + 1)) /
                    layout.totalColumns;
            final left = padding + layout.column * (laneWidth + padding);
            final width = laneWidth;

            return Positioned(
              top: top.clamp(0.0, totalHeight - 24),
              left: left,
              width: width,
              height: height.clamp(22, totalHeight),
              child: _EntryBlock(
                entry: entry,
                subject: subject,
                isNarrow: layout.totalColumns > 1,
                onTap:
                    onEntryTap != null ? () => onEntryTap!(entry) : null,
              ),
            );
          }),

          // Current time indicator
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
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: primary.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Entry block ────────────────────────────────────────────────────────────

class _EntryBlock extends StatelessWidget {
  final ScheduleEntry entry;
  final Subject? subject;
  final bool isNarrow;
  final VoidCallback? onTap;

  const _EntryBlock({
    required this.entry,
    required this.subject,
    required this.isNarrow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = subject != null
        ? Color(subject!.colorValue)
        : Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: color.withAlpha(28),
          borderRadius: BorderRadius.circular(5),
          border: Border(
            left: BorderSide(color: color, width: 3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject?.name ?? '?',
              style: GoogleFonts.outfit(
                fontSize: isNarrow ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            if (!isNarrow && entry.room != null)
              Text(
                entry.room!,
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  color: color.withAlpha(180),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}
