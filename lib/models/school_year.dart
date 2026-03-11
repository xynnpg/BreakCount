import 'dart:convert';

class SchoolBreak {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  const SchoolBreak({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(endDate.add(const Duration(days: 1)));
  }

  bool get isPast => DateTime.now().isAfter(endDate);
  bool get isFuture => DateTime.now().isBefore(startDate);
  int get durationDays => endDate.difference(startDate).inDays + 1;

  factory SchoolBreak.fromJson(Map<String, dynamic> json) {
    return SchoolBreak(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      };

  SchoolBreak copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      SchoolBreak(
        id: id ?? this.id,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolBreak && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Semester {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  const Semester({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  double get progress {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return 1;
    final total = endDate.difference(startDate).inSeconds;
    final elapsed = now.difference(startDate).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      };

  Semester copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      Semester(
        id: id ?? this.id,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Semester && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SchoolYear {
  final String country;
  final String academicYear;
  final DateTime startDate;
  final DateTime endDate;
  final List<Semester> semesters;
  final List<SchoolBreak> breaks;
  final DateTime cachedAt;

  const SchoolYear({
    required this.country,
    required this.academicYear,
    required this.startDate,
    required this.endDate,
    required this.semesters,
    required this.breaks,
    required this.cachedAt,
  });

  double get yearProgress {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return 1;
    final total = endDate.difference(startDate).inSeconds;
    final elapsed = now.difference(startDate).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  List<SchoolBreak> get futureBreaks =>
      breaks.where((b) => !b.isPast).toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  SchoolBreak? get nextBreak {
    final now = DateTime.now();
    try {
      return breaks
          .where((b) => b.startDate.isAfter(now) || b.isActive)
          .reduce((a, b) => a.startDate.isBefore(b.startDate) ? a : b);
    } catch (_) {
      return null;
    }
  }

  Semester? get currentSemester {
    try {
      return semesters.firstWhere((s) => s.isCurrent);
    } catch (_) {
      return null;
    }
  }

  factory SchoolYear.fromJson(Map<String, dynamic> json) {
    return SchoolYear(
      country: json['country'] as String,
      academicYear: json['academic_year'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      semesters: (json['semesters'] as List)
          .map((s) => Semester.fromJson(s as Map<String, dynamic>))
          .toList(),
      breaks: (json['breaks'] as List)
          .map((b) => SchoolBreak.fromJson(b as Map<String, dynamic>))
          .toList(),
      cachedAt: DateTime.parse(json['cached_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'country': country,
        'academic_year': academicYear,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'semesters': semesters.map((s) => s.toJson()).toList(),
        'breaks': breaks.map((b) => b.toJson()).toList(),
        'cached_at': cachedAt.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory SchoolYear.fromJsonString(String jsonString) {
    return SchoolYear.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  SchoolYear copyWith({
    String? country,
    String? academicYear,
    DateTime? startDate,
    DateTime? endDate,
    List<Semester>? semesters,
    List<SchoolBreak>? breaks,
    DateTime? cachedAt,
  }) =>
      SchoolYear(
        country: country ?? this.country,
        academicYear: academicYear ?? this.academicYear,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        semesters: semesters ?? this.semesters,
        breaks: breaks ?? this.breaks,
        cachedAt: cachedAt ?? this.cachedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolYear &&
          runtimeType == other.runtimeType &&
          country == other.country &&
          academicYear == other.academicYear;

  @override
  int get hashCode => country.hashCode ^ academicYear.hashCode;
}
