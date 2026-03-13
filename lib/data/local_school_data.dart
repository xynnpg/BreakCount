import '../models/school_year.dart';
import 'local_school_data_core.dart';
import 'local_school_data_ext_a.dart';
import 'local_school_data_ext_b.dart';

/// Locally bundled, verified school year data for 2025-2026.
///
/// Data is split across three helper files:
///   - local_school_data_core.dart   → original 11 countries
///   - local_school_data_ext_a.dart  → extended: Australia → Lithuania
///   - local_school_data_ext_b.dart  → extended: Luxembourg → Switzerland
///
/// Countries not listed here fall back to the OpenHolidays API.
class LocalSchoolData {
  /// Returns a [SchoolYear] for the given country name, or null if not bundled.
  static SchoolYear? forCountry(String country) {
    return LocalDataCore.forCountry(country) ??
        LocalDataExtA.forCountry(country) ??
        LocalDataExtB.forCountry(country);
  }
}
