import 'dart:convert';
import '../app/constants.dart';

class Subject {
  final String id;
  final String name;
  final int colorValue;
  final String? teacher;
  final String? room;
  final String? notes;

  const Subject({
    required this.id,
    required this.name,
    required this.colorValue,
    this.teacher,
    this.room,
    this.notes,
  });

  static int defaultColor(int index) =>
      AppColors.subjectColors[index % AppColors.subjectColors.length];

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['color_value'] as int,
      teacher: json['teacher'] as String?,
      room: json['room'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color_value': colorValue,
        'teacher': teacher,
        'room': room,
        'notes': notes,
      };

  String toJsonString() => jsonEncode(toJson());

  factory Subject.fromJsonString(String jsonString) =>
      Subject.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  Subject copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? teacher,
    String? room,
    String? notes,
  }) =>
      Subject(
        id: id ?? this.id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        teacher: teacher ?? this.teacher,
        room: room ?? this.room,
        notes: notes ?? this.notes,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Subject(id: $id, name: $name)';
}
