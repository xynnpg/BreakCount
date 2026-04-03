import '../services/subject_importance_service.dart';

class SchoolProfile {
  final String id;
  final String displayName;
  final String country; // lowercase, matches StorageKeys.selectedCountry
  final Map<String, SubjectImportance> overrides;

  const SchoolProfile({
    required this.id,
    required this.displayName,
    required this.country,
    this.overrides = const {},
  });
}
