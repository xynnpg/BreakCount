import 'dart:convert';

enum ExamType { quiz, midterm, finalExam, presentation, other }

extension ExamTypeExt on ExamType {
  String get label {
    switch (this) {
      case ExamType.quiz:
        return 'Quiz';
      case ExamType.midterm:
        return 'Midterm';
      case ExamType.finalExam:
        return 'Final Exam';
      case ExamType.presentation:
        return 'Presentation';
      case ExamType.other:
        return 'Other';
    }
  }

  String get jsonValue => name;

  static ExamType fromString(String value) {
    return ExamType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExamType.other,
    );
  }
}

class Exam {
  final String id;
  final String title;
  final ExamType type;
  final DateTime date;
  final String? subjectId;
  final String? subjectName;
  final String? room;
  final String? notes;

  const Exam({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    this.subjectId,
    this.subjectName,
    this.room,
    this.notes,
  });

  bool get isPast => DateTime.now().isAfter(date);
  bool get isUpcoming => !isPast;

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as String,
      title: json['title'] as String,
      type: ExamTypeExt.fromString(json['type'] as String),
      date: DateTime.parse(json['date'] as String),
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String?,
      room: json['room'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.jsonValue,
        'date': date.toIso8601String(),
        'subject_id': subjectId,
        'subject_name': subjectName,
        'room': room,
        'notes': notes,
      };

  String toJsonString() => jsonEncode(toJson());

  factory Exam.fromJsonString(String s) =>
      Exam.fromJson(jsonDecode(s) as Map<String, dynamic>);

  Exam copyWith({
    String? id,
    String? title,
    ExamType? type,
    DateTime? date,
    String? subjectId,
    String? subjectName,
    String? room,
    String? notes,
  }) =>
      Exam(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        date: date ?? this.date,
        subjectId: subjectId ?? this.subjectId,
        subjectName: subjectName ?? this.subjectName,
        room: room ?? this.room,
        notes: notes ?? this.notes,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exam && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
