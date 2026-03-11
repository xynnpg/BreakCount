import '../models/school_year.dart';

/// Locally bundled, verified school year data for 2025-2026.
/// These dates are sourced from each country's Ministry of Education.
/// Countries not listed here fall back to OpenHolidays API.
///
/// Romania  — Ordinul MEN (Ministerul Educației Naționale)
/// France   — Ministère de l'Éducation nationale (Zone B – Paris/Centre)
/// Germany  — KMK standing conference, Bayern reference
/// Italy    — MIUR official calendar
/// Japan    — MEXT standard school year
/// Canada   — Ontario Ministry of Education reference
/// Mexico   — SEP calendar 2025-2026
/// Poland   — MEN (Ministerul Edukacji Narodowej)
/// Turkey   — MEB (Millî Eğitim Bakanlığı)
/// UK       — England, DfE
/// USA      — Typical public school calendar
class LocalSchoolData {
  /// Returns a [SchoolYear] for the given country name, or null if not bundled.
  static SchoolYear? forCountry(String country) {
    switch (country) {
      case 'Romania':
        return _romania();
      case 'France':
        return _france();
      case 'Germany':
        return _germany();
      case 'Italy':
        return _italy();
      case 'Japan':
        return _japan();
      case 'Canada':
        return _canada();
      case 'Mexico':
        return _mexico();
      case 'Poland':
        return _poland();
      case 'Turkey':
        return _turkey();
      case 'United Kingdom':
        return _unitedKingdom();
      case 'Usa':
        return _usa();
      default:
        return null;
    }
  }

  // ── Romania ────────────────────────────────────────────────────────────────
  // Source: Ordinul MEN nr. 3637/2025 – structura anului școlar 2025-2026
  static SchoolYear _romania() {
    return SchoolYear(
      country: 'Romania',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 8),
      endDate: DateTime(2026, 6, 19),
      semesters: [
        Semester(
          id: 'ro_s1',
          name: 'Semestrul I',
          startDate: DateTime(2025, 9, 8),
          endDate: DateTime(2026, 1, 30),
        ),
        Semester(
          id: 'ro_s2',
          name: 'Semestrul II',
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 6, 19),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'ro_toamna',
          name: 'Vacanță de toamnă',
          startDate: DateTime(2025, 10, 25),
          endDate: DateTime(2025, 11, 2),
        ),
        SchoolBreak(
          id: 'ro_iarna',
          name: 'Vacanță de iarnă',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2026, 1, 11),
        ),
        SchoolBreak(
          id: 'ro_intersem',
          name: 'Vacanță intersemestrială',
          startDate: DateTime(2026, 1, 31),
          endDate: DateTime(2026, 2, 1),
        ),
        SchoolBreak(
          id: 'ro_primavara',
          name: 'Vacanță de primăvară',
          startDate: DateTime(2026, 4, 4),
          endDate: DateTime(2026, 4, 19),
        ),
        SchoolBreak(
          id: 'ro_vara',
          name: 'Vacanță de vară',
          startDate: DateTime(2026, 6, 20),
          endDate: DateTime(2026, 9, 7),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── France (Zone B – Paris/Île-de-France) ──────────────────────────────────
  // Source: Ministère de l'Éducation nationale, calendrier scolaire 2025-2026
  static SchoolYear _france() {
    return SchoolYear(
      country: 'France',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 2),
      endDate: DateTime(2026, 7, 4),
      semesters: [
        Semester(
          id: 'fr_s1',
          name: 'Trimestre 1',
          startDate: DateTime(2025, 9, 2),
          endDate: DateTime(2025, 12, 19),
        ),
        Semester(
          id: 'fr_s2',
          name: 'Trimestre 2',
          startDate: DateTime(2026, 1, 6),
          endDate: DateTime(2026, 4, 3),
        ),
        Semester(
          id: 'fr_s3',
          name: 'Trimestre 3',
          startDate: DateTime(2026, 4, 20),
          endDate: DateTime(2026, 7, 4),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'fr_toussaint',
          name: 'Vacances de la Toussaint',
          startDate: DateTime(2025, 10, 18),
          endDate: DateTime(2025, 11, 3),
        ),
        SchoolBreak(
          id: 'fr_noel',
          name: 'Vacances de Noël',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2026, 1, 5),
        ),
        SchoolBreak(
          id: 'fr_hiver',
          name: 'Vacances d\'hiver',
          startDate: DateTime(2026, 2, 14),
          endDate: DateTime(2026, 3, 2),
        ),
        SchoolBreak(
          id: 'fr_printemps',
          name: 'Vacances de printemps',
          startDate: DateTime(2026, 4, 4),
          endDate: DateTime(2026, 4, 20),
        ),
        SchoolBreak(
          id: 'fr_ete',
          name: 'Grandes vacances',
          startDate: DateTime(2026, 7, 4),
          endDate: DateTime(2026, 9, 1),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Germany (Bayern / Bavaria) ─────────────────────────────────────────────
  // Source: Bayerisches Staatsministerium für Unterricht und Kultus
  static SchoolYear _germany() {
    return SchoolYear(
      country: 'Germany',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 10),
      endDate: DateTime(2026, 7, 31),
      semesters: [
        Semester(
          id: 'de_s1',
          name: 'Erstes Halbjahr',
          startDate: DateTime(2025, 9, 10),
          endDate: DateTime(2026, 2, 6),
        ),
        Semester(
          id: 'de_s2',
          name: 'Zweites Halbjahr',
          startDate: DateTime(2026, 2, 9),
          endDate: DateTime(2026, 7, 31),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'de_herbst',
          name: 'Herbstferien',
          startDate: DateTime(2025, 11, 1),
          endDate: DateTime(2025, 11, 8),
        ),
        SchoolBreak(
          id: 'de_weihnachten',
          name: 'Weihnachtsferien',
          startDate: DateTime(2025, 12, 24),
          endDate: DateTime(2026, 1, 6),
        ),
        SchoolBreak(
          id: 'de_fasching',
          name: 'Faschingsferien',
          startDate: DateTime(2026, 3, 2),
          endDate: DateTime(2026, 3, 6),
        ),
        SchoolBreak(
          id: 'de_ostern',
          name: 'Osterferien',
          startDate: DateTime(2026, 4, 7),
          endDate: DateTime(2026, 4, 17),
        ),
        SchoolBreak(
          id: 'de_pfingsten',
          name: 'Pfingstferien',
          startDate: DateTime(2026, 6, 2),
          endDate: DateTime(2026, 6, 12),
        ),
        SchoolBreak(
          id: 'de_sommer',
          name: 'Sommerferien',
          startDate: DateTime(2026, 7, 31),
          endDate: DateTime(2026, 9, 11),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Italy ──────────────────────────────────────────────────────────────────
  // Source: MIUR (Ministero dell'Istruzione) – calendar 2025-2026
  static SchoolYear _italy() {
    return SchoolYear(
      country: 'Italy',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 10),
      endDate: DateTime(2026, 6, 13),
      semesters: [
        Semester(
          id: 'it_s1',
          name: 'Primo quadrimestre',
          startDate: DateTime(2025, 9, 10),
          endDate: DateTime(2026, 1, 31),
        ),
        Semester(
          id: 'it_s2',
          name: 'Secondo quadrimestre',
          startDate: DateTime(2026, 2, 1),
          endDate: DateTime(2026, 6, 13),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'it_tutti_santi',
          name: 'Tutti i Santi',
          startDate: DateTime(2025, 11, 1),
          endDate: DateTime(2025, 11, 2),
        ),
        SchoolBreak(
          id: 'it_natale',
          name: 'Vacanze di Natale',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 7),
        ),
        SchoolBreak(
          id: 'it_carnevale',
          name: 'Carnevale',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 17),
        ),
        SchoolBreak(
          id: 'it_pasqua',
          name: 'Vacanze di Pasqua',
          startDate: DateTime(2026, 4, 2),
          endDate: DateTime(2026, 4, 8),
        ),
        SchoolBreak(
          id: 'it_estate',
          name: 'Vacanze estive',
          startDate: DateTime(2026, 6, 14),
          endDate: DateTime(2026, 9, 9),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Japan ──────────────────────────────────────────────────────────────────
  // Source: MEXT – Japanese academic year starts in April
  // 2025-2026 year: April 2025 – March 2026
  static SchoolYear _japan() {
    return SchoolYear(
      country: 'Japan',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 4, 7),
      endDate: DateTime(2026, 3, 20),
      semesters: [
        Semester(
          id: 'jp_s1',
          name: '1学期 (First Term)',
          startDate: DateTime(2025, 4, 7),
          endDate: DateTime(2025, 7, 18),
        ),
        Semester(
          id: 'jp_s2',
          name: '2学期 (Second Term)',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2025, 12, 25),
        ),
        Semester(
          id: 'jp_s3',
          name: '3学期 (Third Term)',
          startDate: DateTime(2026, 1, 8),
          endDate: DateTime(2026, 3, 20),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'jp_natsu',
          name: '夏休み (Summer Break)',
          startDate: DateTime(2025, 7, 19),
          endDate: DateTime(2025, 8, 31),
        ),
        SchoolBreak(
          id: 'jp_fuyu',
          name: '冬休み (Winter Break)',
          startDate: DateTime(2025, 12, 26),
          endDate: DateTime(2026, 1, 7),
        ),
        SchoolBreak(
          id: 'jp_haru',
          name: '春休み (Spring Break)',
          startDate: DateTime(2026, 3, 21),
          endDate: DateTime(2026, 4, 6),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Canada (Ontario) ───────────────────────────────────────────────────────
  // Source: Ontario Ministry of Education
  static SchoolYear _canada() {
    return SchoolYear(
      country: 'Canada',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 2),
      endDate: DateTime(2026, 6, 26),
      semesters: [
        Semester(
          id: 'ca_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 2),
          endDate: DateTime(2026, 1, 30),
        ),
        Semester(
          id: 'ca_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 6, 26),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'ca_thanksgiving',
          name: 'Thanksgiving Break',
          startDate: DateTime(2025, 10, 13),
          endDate: DateTime(2025, 10, 13),
        ),
        SchoolBreak(
          id: 'ca_christmas',
          name: 'Winter Break',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 2),
        ),
        SchoolBreak(
          id: 'ca_family',
          name: 'Family Day Break',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 16),
        ),
        SchoolBreak(
          id: 'ca_march',
          name: 'March Break',
          startDate: DateTime(2026, 3, 16),
          endDate: DateTime(2026, 3, 20),
        ),
        SchoolBreak(
          id: 'ca_easter',
          name: 'Easter Break',
          startDate: DateTime(2026, 4, 3),
          endDate: DateTime(2026, 4, 6),
        ),
        SchoolBreak(
          id: 'ca_victoria',
          name: 'Victoria Day',
          startDate: DateTime(2026, 5, 18),
          endDate: DateTime(2026, 5, 18),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Mexico ─────────────────────────────────────────────────────────────────
  // Source: SEP (Secretaría de Educación Pública) calendario escolar 2025-2026
  static SchoolYear _mexico() {
    return SchoolYear(
      country: 'Mexico',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 8, 25),
      endDate: DateTime(2026, 7, 3),
      semesters: [
        Semester(
          id: 'mx_s1',
          name: 'Primer Semestre',
          startDate: DateTime(2025, 8, 25),
          endDate: DateTime(2026, 1, 23),
        ),
        Semester(
          id: 'mx_s2',
          name: 'Segundo Semestre',
          startDate: DateTime(2026, 1, 26),
          endDate: DateTime(2026, 7, 3),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'mx_independencia',
          name: 'Día de la Independencia',
          startDate: DateTime(2025, 9, 15),
          endDate: DateTime(2025, 9, 16),
        ),
        SchoolBreak(
          id: 'mx_navidad',
          name: 'Vacaciones de Navidad',
          startDate: DateTime(2025, 12, 19),
          endDate: DateTime(2026, 1, 5),
        ),
        SchoolBreak(
          id: 'mx_primavera',
          name: 'Vacaciones de Primavera',
          startDate: DateTime(2026, 3, 30),
          endDate: DateTime(2026, 4, 10),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Poland ─────────────────────────────────────────────────────────────────
  // Source: MEN – Rozporządzenie Ministra Edukacji Narodowej
  static SchoolYear _poland() {
    return SchoolYear(
      country: 'Poland',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 6, 26),
      semesters: [
        Semester(
          id: 'pl_s1',
          name: 'Semestr I',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2026, 1, 23),
        ),
        Semester(
          id: 'pl_s2',
          name: 'Semestr II',
          startDate: DateTime(2026, 1, 26),
          endDate: DateTime(2026, 6, 26),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'pl_wszystkich_swietych',
          name: 'Wszystkich Świętych',
          startDate: DateTime(2025, 10, 31),
          endDate: DateTime(2025, 11, 4),
        ),
        SchoolBreak(
          id: 'pl_boze_narodzenie',
          name: 'Ferie zimowe (świąteczne)',
          startDate: DateTime(2025, 12, 23),
          endDate: DateTime(2026, 1, 2),
        ),
        SchoolBreak(
          id: 'pl_ferie_zimowe',
          name: 'Ferie zimowe',
          startDate: DateTime(2026, 1, 26),
          endDate: DateTime(2026, 2, 8),
        ),
        SchoolBreak(
          id: 'pl_wielkanoc',
          name: 'Przerwa wielkanocna',
          startDate: DateTime(2026, 4, 2),
          endDate: DateTime(2026, 4, 8),
        ),
        SchoolBreak(
          id: 'pl_majowka',
          name: 'Majówka',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 4),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Turkey ─────────────────────────────────────────────────────────────────
  // Source: MEB (Millî Eğitim Bakanlığı) – 2025-2026 okul takvimi
  static SchoolYear _turkey() {
    return SchoolYear(
      country: 'Turkey',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 15),
      endDate: DateTime(2026, 6, 12),
      semesters: [
        Semester(
          id: 'tr_s1',
          name: '1. Dönem',
          startDate: DateTime(2025, 9, 15),
          endDate: DateTime(2026, 1, 16),
        ),
        Semester(
          id: 'tr_s2',
          name: '2. Dönem',
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 6, 12),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'tr_cumhuriyet',
          name: 'Cumhuriyet Bayramı',
          startDate: DateTime(2025, 10, 29),
          endDate: DateTime(2025, 10, 29),
        ),
        SchoolBreak(
          id: 'tr_yari_yil',
          name: 'Yarı Yıl Tatili',
          startDate: DateTime(2026, 1, 17),
          endDate: DateTime(2026, 2, 1),
        ),
        SchoolBreak(
          id: 'tr_nisan',
          name: 'Ulusal Egemenlik ve Çocuk Bayramı',
          startDate: DateTime(2026, 4, 23),
          endDate: DateTime(2026, 4, 23),
        ),
        SchoolBreak(
          id: 'tr_emek',
          name: 'Emek ve Dayanışma Günü',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 1),
        ),
        SchoolBreak(
          id: 'tr_ataturk',
          name: 'Atatürk\'ü Anma, Gençlik ve Spor Bayramı',
          startDate: DateTime(2026, 5, 19),
          endDate: DateTime(2026, 5, 19),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── United Kingdom (England) ───────────────────────────────────────────────
  // Source: UK Department for Education – academic year 2025-2026
  static SchoolYear _unitedKingdom() {
    return SchoolYear(
      country: 'United Kingdom',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 3),
      endDate: DateTime(2026, 7, 22),
      semesters: [
        Semester(
          id: 'gb_t1',
          name: 'Autumn Term',
          startDate: DateTime(2025, 9, 3),
          endDate: DateTime(2025, 12, 19),
        ),
        Semester(
          id: 'gb_t2',
          name: 'Spring Term',
          startDate: DateTime(2026, 1, 6),
          endDate: DateTime(2026, 3, 27),
        ),
        Semester(
          id: 'gb_t3',
          name: 'Summer Term',
          startDate: DateTime(2026, 4, 14),
          endDate: DateTime(2026, 7, 22),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'gb_autumn_half',
          name: 'Autumn Half Term',
          startDate: DateTime(2025, 10, 27),
          endDate: DateTime(2025, 10, 31),
        ),
        SchoolBreak(
          id: 'gb_christmas',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2026, 1, 2),
        ),
        SchoolBreak(
          id: 'gb_spring_half',
          name: 'Spring Half Term',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 20),
        ),
        SchoolBreak(
          id: 'gb_easter',
          name: 'Easter Break',
          startDate: DateTime(2026, 4, 3),
          endDate: DateTime(2026, 4, 17),
        ),
        SchoolBreak(
          id: 'gb_summer_half',
          name: 'Summer Half Term',
          startDate: DateTime(2026, 5, 25),
          endDate: DateTime(2026, 5, 29),
        ),
        SchoolBreak(
          id: 'gb_summer',
          name: 'Summer Holidays',
          startDate: DateTime(2026, 7, 23),
          endDate: DateTime(2026, 9, 2),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── USA (typical public school – Northeast reference) ─────────────────────
  // Source: typical Northeast US school district calendar 2025-2026
  static SchoolYear _usa() {
    return SchoolYear(
      country: 'Usa',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 2),
      endDate: DateTime(2026, 6, 18),
      semesters: [
        Semester(
          id: 'us_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 2),
          endDate: DateTime(2026, 1, 16),
        ),
        Semester(
          id: 'us_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 1, 19),
          endDate: DateTime(2026, 6, 18),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'us_columbus',
          name: 'Columbus Day / Indigenous Peoples Day',
          startDate: DateTime(2025, 10, 13),
          endDate: DateTime(2025, 10, 13),
        ),
        SchoolBreak(
          id: 'us_thanksgiving',
          name: 'Thanksgiving Break',
          startDate: DateTime(2025, 11, 26),
          endDate: DateTime(2025, 11, 28),
        ),
        SchoolBreak(
          id: 'us_christmas',
          name: 'Winter Break',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 2),
        ),
        SchoolBreak(
          id: 'us_mlk',
          name: 'MLK Day',
          startDate: DateTime(2026, 1, 19),
          endDate: DateTime(2026, 1, 19),
        ),
        SchoolBreak(
          id: 'us_presidents',
          name: 'Presidents Day',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 16),
        ),
        SchoolBreak(
          id: 'us_spring',
          name: 'Spring Break',
          startDate: DateTime(2026, 3, 23),
          endDate: DateTime(2026, 3, 27),
        ),
        SchoolBreak(
          id: 'us_memorial',
          name: 'Memorial Day',
          startDate: DateTime(2026, 5, 25),
          endDate: DateTime(2026, 5, 25),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }
}
