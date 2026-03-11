import 'dart:convert';

enum WeekType { a, b, both }

extension WeekTypeExt on WeekType {
  String get label {
    switch (this) {
      case WeekType.a:
        return 'Week A';
      case WeekType.b:
        return 'Week B';
      case WeekType.both:
        return 'Every Week';
    }
  }

  String get jsonValue {
    switch (this) {
      case WeekType.a:
        return 'a';
      case WeekType.b:
        return 'b';
      case WeekType.both:
        return 'both';
    }
  }

  static WeekType fromString(String value) {
    switch (value) {
      case 'a':
        return WeekType.a;
      case 'b':
        return WeekType.b;
      default:
        return WeekType.both;
    }
  }
}

class ScheduleTime {
  final int hour;
  final int minute;

  const ScheduleTime({required this.hour, required this.minute});

  String format24h() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String format12h() {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  double toFractionalHours() => hour + minute / 60.0;

  bool isBefore(ScheduleTime other) {
    if (hour != other.hour) return hour < other.hour;
    return minute < other.minute;
  }

  bool isAfter(ScheduleTime other) => other.isBefore(this);

  factory ScheduleTime.fromJson(Map<String, dynamic> json) => ScheduleTime(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      );

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleTime && hour == other.hour && minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

class ScheduleEntry {
  final String id;
  final String subjectId;
  final int dayOfWeek; // 1=Monday, 5=Friday
  final ScheduleTime startTime;
  final ScheduleTime endTime;
  final WeekType weekType;
  final String? room;

  const ScheduleEntry({
    required this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.weekType,
    this.room,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      startTime: ScheduleTime.fromJson(
          json['start_time'] as Map<String, dynamic>),
      endTime: ScheduleTime.fromJson(json['end_time'] as Map<String, dynamic>),
      weekType: WeekTypeExt.fromString(json['week_type'] as String),
      room: json['room'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject_id': subjectId,
        'day_of_week': dayOfWeek,
        'start_time': startTime.toJson(),
        'end_time': endTime.toJson(),
        'week_type': weekType.jsonValue,
        'room': room,
      };

  ScheduleEntry copyWith({
    String? id,
    String? subjectId,
    int? dayOfWeek,
    ScheduleTime? startTime,
    ScheduleTime? endTime,
    WeekType? weekType,
    String? room,
  }) =>
      ScheduleEntry(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        weekType: weekType ?? this.weekType,
        room: room ?? this.room,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Schedule {
  final List<ScheduleEntry> entries;
  final bool useAlternatingWeeks;

  const Schedule({
    required this.entries,
    this.useAlternatingWeeks = false,
  });

  const Schedule.empty()
      : entries = const [],
        useAlternatingWeeks = false;

  List<ScheduleEntry> entriesForDay(int dayOfWeek, WeekType currentWeek) {
    return entries.where((e) {
      if (e.dayOfWeek != dayOfWeek) return false;
      if (!useAlternatingWeeks) return true;
      return e.weekType == WeekType.both || e.weekType == currentWeek;
    }).toList()
      ..sort((a, b) => a.startTime.toFractionalHours()
          .compareTo(b.startTime.toFractionalHours()));
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      entries: (json['entries'] as List)
          .map((e) => ScheduleEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      useAlternatingWeeks: json['use_alternating_weeks'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'entries': entries.map((e) => e.toJson()).toList(),
        'use_alternating_weeks': useAlternatingWeeks,
      };

  String toJsonString() => jsonEncode(toJson());

  factory Schedule.fromJsonString(String jsonString) =>
      Schedule.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  Schedule copyWith({
    List<ScheduleEntry>? entries,
    bool? useAlternatingWeeks,
  }) =>
      Schedule(
        entries: entries ?? this.entries,
        useAlternatingWeeks: useAlternatingWeeks ?? this.useAlternatingWeeks,
      );
}
