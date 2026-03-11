import 'dart:convert';

enum ReminderType { test, exam, assignment, breakStarts, breakEnds, custom }

extension ReminderTypeExt on ReminderType {
  String get label {
    switch (this) {
      case ReminderType.test:
        return 'Test';
      case ReminderType.exam:
        return 'Exam';
      case ReminderType.assignment:
        return 'Assignment';
      case ReminderType.breakStarts:
        return 'Break Starts';
      case ReminderType.breakEnds:
        return 'Break Ends';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  String get jsonValue => name;

  static ReminderType fromString(String value) {
    return ReminderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReminderType.custom,
    );
  }
}

enum AlertTiming {
  oneDayBefore,
  twoDaysBefore,
  twoHoursBefore,
  morningOf,
  custom,
}

extension AlertTimingExt on AlertTiming {
  String get label {
    switch (this) {
      case AlertTiming.oneDayBefore:
        return '1 day before';
      case AlertTiming.twoDaysBefore:
        return '2 days before';
      case AlertTiming.twoHoursBefore:
        return '2 hours before';
      case AlertTiming.morningOf:
        return 'Morning of (8 AM)';
      case AlertTiming.custom:
        return 'Custom time';
    }
  }

  String get jsonValue => name;

  static AlertTiming fromString(String value) {
    return AlertTiming.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AlertTiming.custom,
    );
  }

  /// Returns the actual notification DateTime based on the event DateTime.
  DateTime computeNotificationTime(DateTime eventDate) {
    switch (this) {
      case AlertTiming.oneDayBefore:
        return eventDate.subtract(const Duration(days: 1));
      case AlertTiming.twoDaysBefore:
        return eventDate.subtract(const Duration(days: 2));
      case AlertTiming.twoHoursBefore:
        return eventDate.subtract(const Duration(hours: 2));
      case AlertTiming.morningOf:
        return DateTime(eventDate.year, eventDate.month, eventDate.day, 8);
      case AlertTiming.custom:
        return eventDate;
    }
  }
}

class Reminder {
  final String id;
  final String title;
  final ReminderType type;
  final DateTime eventDate;
  final AlertTiming alertTiming;
  final String? subjectId;
  final String? notes;
  final bool isCompleted;

  const Reminder({
    required this.id,
    required this.title,
    required this.type,
    required this.eventDate,
    required this.alertTiming,
    this.subjectId,
    this.notes,
    this.isCompleted = false,
  });

  DateTime get notificationTime => alertTiming.computeNotificationTime(eventDate);
  bool get isPast => DateTime.now().isAfter(eventDate);
  bool get isUpcoming => !isPast && !isCompleted;

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      type: ReminderTypeExt.fromString(json['type'] as String),
      eventDate: DateTime.parse(json['event_date'] as String),
      alertTiming: AlertTimingExt.fromString(json['alert_timing'] as String),
      subjectId: json['subject_id'] as String?,
      notes: json['notes'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.jsonValue,
        'event_date': eventDate.toIso8601String(),
        'alert_timing': alertTiming.jsonValue,
        'subject_id': subjectId,
        'notes': notes,
        'is_completed': isCompleted,
      };

  String toJsonString() => jsonEncode(toJson());

  factory Reminder.fromJsonString(String s) =>
      Reminder.fromJson(jsonDecode(s) as Map<String, dynamic>);

  Reminder copyWith({
    String? id,
    String? title,
    ReminderType? type,
    DateTime? eventDate,
    AlertTiming? alertTiming,
    String? subjectId,
    String? notes,
    bool? isCompleted,
  }) =>
      Reminder(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        eventDate: eventDate ?? this.eventDate,
        alertTiming: alertTiming ?? this.alertTiming,
        subjectId: subjectId ?? this.subjectId,
        notes: notes ?? this.notes,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reminder && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
