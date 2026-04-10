import '../models/school_year.dart';

/// Extended bundled country data – first half (Australia → Lithuania).
/// Countries: Australia, Austria, Belgium, Brazil, Croatia,
///            Czech Republic, Denmark, Estonia, Finland, Greece,
///            Hungary, Ireland, Latvia, Lithuania
///
/// Australia  — NSW Department of Education
/// Austria    — BMBWF (Bundesministerium für Bildung, Wissenschaft und Forschung)
/// Belgium    — Vlaamse Gemeenschap (Flemish Community)
/// Brazil     — São Paulo state public school calendar
/// Croatia    — Ministarstvo znanosti, obrazovanja i mladih
/// Czech Rep. — MŠMT (Ministerstvo školství, mládeže a tělovýchovy)
/// Denmark    — Ministeriet for Børn og Undervisning (Copenhagen reference)
/// Estonia    — Haridus- ja Noorteamet
/// Finland    — OPH / City of Helsinki reference
/// Greece     — Ministry of Education and Religious Affairs
/// Hungary    — Government of Hungary
/// Ireland    — Department of Education and Youth
/// Latvia     — Izglītības un zinātnes ministrija
/// Lithuania  — Švietimo, mokslo ir sporto ministerija
class LocalDataExtA {
  static SchoolYear? forCountry(String country) {
    switch (country) {
      case 'Australia':
        return _australia();
      case 'Austria':
        return _austria();
      case 'Belgium':
        return _belgium();
      case 'Brazil':
        return _brazil();
      case 'Croatia':
        return _croatia();
      case 'Czech Republic':
        return _czechRepublic();
      case 'Denmark':
        return _denmark();
      case 'Estonia':
        return _estonia();
      case 'Finland':
        return _finland();
      case 'Greece':
        return _greece();
      case 'Hungary':
        return _hungary();
      case 'Ireland':
        return _ireland();
      case 'Latvia':
        return _latvia();
      case 'Lithuania':
        return _lithuania();
      default:
        return null;
    }
  }

  // ── Australia (NSW – Eastern Division) ────────────────────────────────────
  // Source: NSW Department of Education – term dates 2025 & 2026
  static SchoolYear _australia() {
    return SchoolYear(
      country: 'Australia',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 7, 22),
      endDate: DateTime(2026, 7, 5),
      semesters: [
        Semester(
          id: 'au_t3_2025',
          name: 'Term 3 (2025)',
          startDate: DateTime(2025, 7, 22),
          endDate: DateTime(2025, 9, 26),
        ),
        Semester(
          id: 'au_t4_2025',
          name: 'Term 4 (2025)',
          startDate: DateTime(2025, 10, 14),
          endDate: DateTime(2025, 12, 19),
        ),
        Semester(
          id: 'au_t1_2026',
          name: 'Term 1 (2026)',
          startDate: DateTime(2026, 1, 30),
          endDate: DateTime(2026, 4, 12),
        ),
        Semester(
          id: 'au_t2_2026',
          name: 'Term 2 (2026)',
          startDate: DateTime(2026, 4, 29),
          endDate: DateTime(2026, 7, 5),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'au_spring_2025',
          name: 'Spring Holidays',
          startDate: DateTime(2025, 9, 29),
          endDate: DateTime(2025, 10, 10),
        ),
        SchoolBreak(
          id: 'au_summer',
          name: 'Summer Holidays',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 26),
        ),
        SchoolBreak(
          id: 'au_autumn',
          name: 'Autumn Holidays',
          startDate: DateTime(2026, 4, 13),
          endDate: DateTime(2026, 4, 26),
        ),
        SchoolBreak(
          id: 'au_winter',
          name: 'Winter Holidays',
          startDate: DateTime(2026, 7, 6),
          endDate: DateTime(2026, 7, 19),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Austria (Vienna reference) ─────────────────────────────────────────────
  // Source: BMBWF Bundesministerium für Bildung, Wissenschaft und Forschung
  static SchoolYear _austria() {
    return SchoolYear(
      country: 'Austria',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 6, 27),
      semesters: [
        Semester(
          id: 'at_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2026, 2, 6),
        ),
        Semester(
          id: 'at_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 2, 9),
          endDate: DateTime(2026, 6, 27),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'at_herbst',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 27),
          endDate: DateTime(2025, 10, 31),
        ),
        SchoolBreak(
          id: 'at_weihnachten',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 24),
          endDate: DateTime(2026, 1, 6),
        ),
        SchoolBreak(
          id: 'at_semester',
          name: 'Semester Break',
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 2, 7),
        ),
        SchoolBreak(
          id: 'at_ostern',
          name: 'Easter Break',
          startDate: DateTime(2026, 4, 2),
          endDate: DateTime(2026, 4, 11),
        ),
        SchoolBreak(
          id: 'at_pfingsten',
          name: 'Whitsun Break',
          startDate: DateTime(2026, 5, 26),
          endDate: DateTime(2026, 5, 26),
        ),
        SchoolBreak(
          id: 'at_sommer',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 28),
          endDate: DateTime(2026, 8, 31),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Belgium (Flemish Community) ────────────────────────────────────────────
  // Source: Vlaamse overheid – schoolvakantie 2025-2026 (vlaanderen.be)
  static SchoolYear _belgium() {
    return SchoolYear(
      country: 'Belgium',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 6, 30),
      semesters: [
        Semester(
          id: 'be_t1',
          name: 'Term 1',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2025, 12, 19),
        ),
        Semester(
          id: 'be_t2',
          name: 'Term 2',
          startDate: DateTime(2026, 1, 5),
          endDate: DateTime(2026, 4, 3),
        ),
        Semester(
          id: 'be_t3',
          name: 'Term 3',
          startDate: DateTime(2026, 4, 20),
          endDate: DateTime(2026, 6, 30),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'be_herfst',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 27),
          endDate: DateTime(2025, 11, 2),
        ),
        SchoolBreak(
          id: 'be_kerst',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 2),
        ),
        SchoolBreak(
          id: 'be_krokus',
          name: 'Carnival Break',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 20),
        ),
        SchoolBreak(
          id: 'be_pasen',
          name: 'Easter Break',
          startDate: DateTime(2026, 4, 6),
          endDate: DateTime(2026, 4, 19),
        ),
        SchoolBreak(
          id: 'be_zomer',
          name: 'Summer Break',
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 8, 31),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Brazil (São Paulo state public schools) ────────────────────────────────
  // Source: Secretaria da Educação do Estado de São Paulo
  static SchoolYear _brazil() {
    return SchoolYear(
      country: 'Brazil',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 2, 5),
      endDate: DateTime(2025, 12, 16),
      semesters: [
        Semester(
          id: 'br_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 2, 5),
          endDate: DateTime(2025, 7, 4),
        ),
        Semester(
          id: 'br_s2',
          name: 'Second Semester',
          startDate: DateTime(2025, 7, 28),
          endDate: DateTime(2025, 12, 16),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'br_carnaval',
          name: 'Carnival Break',
          startDate: DateTime(2025, 3, 3),
          endDate: DateTime(2025, 3, 5),
        ),
        SchoolBreak(
          id: 'br_tiradentes',
          name: 'Tiradentes Day',
          startDate: DateTime(2025, 4, 21),
          endDate: DateTime(2025, 4, 21),
        ),
        SchoolBreak(
          id: 'br_julio',
          name: 'July Recess',
          startDate: DateTime(2025, 7, 7),
          endDate: DateTime(2025, 7, 25),
        ),
        SchoolBreak(
          id: 'br_independencia',
          name: 'Independence Day',
          startDate: DateTime(2025, 9, 7),
          endDate: DateTime(2025, 9, 7),
        ),
        SchoolBreak(
          id: 'br_finados',
          name: 'All Souls Day',
          startDate: DateTime(2025, 11, 2),
          endDate: DateTime(2025, 11, 2),
        ),
        SchoolBreak(
          id: 'br_verao',
          name: 'Summer Break',
          startDate: DateTime(2025, 12, 17),
          endDate: DateTime(2026, 2, 4),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Croatia ────────────────────────────────────────────────────────────────
  // Source: Ministarstvo znanosti, obrazovanja i mladih – školski kalendar 2025-2026
  static SchoolYear _croatia() {
    return SchoolYear(
      country: 'Croatia',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 8),
      endDate: DateTime(2026, 6, 12),
      semesters: [
        Semester(
          id: 'hr_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 8),
          endDate: DateTime(2026, 1, 16),
        ),
        Semester(
          id: 'hr_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 1, 19),
          endDate: DateTime(2026, 6, 12),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'hr_svi_sveti',
          name: 'All Saints Day',
          startDate: DateTime(2025, 11, 1),
          endDate: DateTime(2025, 11, 1),
        ),
        SchoolBreak(
          id: 'hr_zima',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 24),
          endDate: DateTime(2026, 1, 9),
        ),
        SchoolBreak(
          id: 'hr_proljetni',
          name: 'Spring Break',
          startDate: DateTime(2026, 3, 30),
          endDate: DateTime(2026, 4, 6),
        ),
        SchoolBreak(
          id: 'hr_ljeto',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 15),
          endDate: DateTime(2026, 9, 7),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Czech Republic ─────────────────────────────────────────────────────────
  // Source: MŠMT (Ministerstvo školství, mládeže a tělovýchovy)
  static SchoolYear _czechRepublic() {
    return SchoolYear(
      country: 'Czech Republic',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 6, 30),
      semesters: [
        Semester(
          id: 'cz_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2026, 1, 30),
        ),
        Semester(
          id: 'cz_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 6, 30),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'cz_podzimni',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 25),
          endDate: DateTime(2025, 10, 29),
        ),
        SchoolBreak(
          id: 'cz_vanoce',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 2),
        ),
        SchoolBreak(
          id: 'cz_pololetni',
          name: 'Mid-Year Break',
          startDate: DateTime(2026, 1, 30),
          endDate: DateTime(2026, 1, 30),
        ),
        SchoolBreak(
          id: 'cz_jarni',
          name: 'Spring Break',
          startDate: DateTime(2026, 2, 23),
          endDate: DateTime(2026, 3, 1),
        ),
        SchoolBreak(
          id: 'cz_velikonoce',
          name: 'Easter Break',
          startDate: DateTime(2026, 4, 2),
          endDate: DateTime(2026, 4, 2),
        ),
        SchoolBreak(
          id: 'cz_leto',
          name: 'Summer Break',
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 8, 31),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Denmark (Copenhagen reference) ────────────────────────────────────────
  // Source: Ministeriet for Børn og Undervisning; municipal calendar
  static SchoolYear _denmark() {
    return SchoolYear(
      country: 'Denmark',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 8, 11),
      endDate: DateTime(2026, 6, 26),
      semesters: [
        Semester(
          id: 'dk_s1',
          name: 'Autumn Semester',
          startDate: DateTime(2025, 8, 11),
          endDate: DateTime(2025, 12, 19),
        ),
        Semester(
          id: 'dk_s2',
          name: 'Spring Semester',
          startDate: DateTime(2026, 1, 5),
          endDate: DateTime(2026, 6, 26),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'dk_efteraar',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 13),
          endDate: DateTime(2025, 10, 19),
        ),
        SchoolBreak(
          id: 'dk_jul',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2026, 1, 4),
        ),
        SchoolBreak(
          id: 'dk_vinter',
          name: 'Winter Break',
          startDate: DateTime(2026, 2, 7),
          endDate: DateTime(2026, 2, 15),
        ),
        SchoolBreak(
          id: 'dk_paaske',
          name: 'Easter Break',
          startDate: DateTime(2026, 3, 28),
          endDate: DateTime(2026, 4, 6),
        ),
        SchoolBreak(
          id: 'dk_kristi',
          name: 'Ascension Break',
          startDate: DateTime(2026, 5, 14),
          endDate: DateTime(2026, 5, 15),
        ),
        SchoolBreak(
          id: 'dk_sommer',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 27),
          endDate: DateTime(2026, 8, 9),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Estonia ────────────────────────────────────────────────────────────────
  // Source: Haridus- ja Noorteamet (Estonian Education and Youth Authority)
  static SchoolYear _estonia() {
    return SchoolYear(
      country: 'Estonia',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 6, 9),
      semesters: [
        Semester(
          id: 'ee_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2026, 1, 16),
        ),
        Semester(
          id: 'ee_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 1, 19),
          endDate: DateTime(2026, 6, 9),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'ee_sugis',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 20),
          endDate: DateTime(2025, 10, 26),
        ),
        SchoolBreak(
          id: 'ee_joulud',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 4),
        ),
        SchoolBreak(
          id: 'ee_talv',
          name: 'Winter Break',
          startDate: DateTime(2026, 2, 23),
          endDate: DateTime(2026, 3, 1),
        ),
        SchoolBreak(
          id: 'ee_kevad',
          name: 'Spring Break',
          startDate: DateTime(2026, 4, 13),
          endDate: DateTime(2026, 4, 19),
        ),
        SchoolBreak(
          id: 'ee_suvi',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 10),
          endDate: DateTime(2026, 8, 31),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Finland (Helsinki reference) ───────────────────────────────────────────
  // Source: City of Helsinki Education Division – school year 2025-2026
  static SchoolYear _finland() {
    return SchoolYear(
      country: 'Finland',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 8, 7),
      endDate: DateTime(2026, 5, 30),
      semesters: [
        Semester(
          id: 'fi_s1',
          name: 'Autumn Term',
          startDate: DateTime(2025, 8, 7),
          endDate: DateTime(2025, 12, 20),
        ),
        Semester(
          id: 'fi_s2',
          name: 'Spring Term',
          startDate: DateTime(2026, 1, 7),
          endDate: DateTime(2026, 5, 30),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'fi_syysloma',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 13),
          endDate: DateTime(2025, 10, 17),
        ),
        SchoolBreak(
          id: 'fi_joulu',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 6),
        ),
        SchoolBreak(
          id: 'fi_talviloma',
          name: 'Winter Break',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 20),
        ),
        SchoolBreak(
          id: 'fi_piainen',
          name: 'Easter Break',
          startDate: DateTime(2026, 4, 2),
          endDate: DateTime(2026, 4, 6),
        ),
        SchoolBreak(
          id: 'fi_kesaloma',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 1),
          endDate: DateTime(2026, 8, 6),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Greece ─────────────────────────────────────────────────────────────────
  // Source: Ministry of Education and Religious Affairs – 2025-2026
  static SchoolYear _greece() {
    return SchoolYear(
      country: 'Greece',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 11),
      endDate: DateTime(2026, 6, 19),
      semesters: [
        Semester(
          id: 'gr_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 11),
          endDate: DateTime(2026, 1, 23),
        ),
        Semester(
          id: 'gr_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 1, 26),
          endDate: DateTime(2026, 6, 19),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'gr_28oktovriou',
          name: 'National Day (Ohi Day)',
          startDate: DateTime(2025, 10, 28),
          endDate: DateTime(2025, 10, 28),
        ),
        SchoolBreak(
          id: 'gr_xristougenna',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 24),
          endDate: DateTime(2026, 1, 6),
        ),
        SchoolBreak(
          id: 'gr_apokries',
          name: 'Carnival Break',
          startDate: DateTime(2026, 2, 23),
          endDate: DateTime(2026, 2, 23),
        ),
        SchoolBreak(
          id: 'gr_25martiou',
          name: 'National Day (Independence)',
          startDate: DateTime(2026, 3, 25),
          endDate: DateTime(2026, 3, 25),
        ),
        SchoolBreak(
          id: 'gr_pasxa',
          name: 'Easter Break',
          startDate: DateTime(2026, 4, 17),
          endDate: DateTime(2026, 4, 26),
        ),
        SchoolBreak(
          id: 'gr_kalokeri',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 20),
          endDate: DateTime(2026, 9, 10),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Hungary ────────────────────────────────────────────────────────────────
  // Source: Government of Hungary – school calendar 2025-2026
  static SchoolYear _hungary() {
    return SchoolYear(
      country: 'Hungary',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 6, 19),
      semesters: [
        Semester(
          id: 'hu_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2026, 1, 30),
        ),
        Semester(
          id: 'hu_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 6, 19),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'hu_osz',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 23),
          endDate: DateTime(2025, 10, 31),
        ),
        SchoolBreak(
          id: 'hu_karacsony',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2026, 1, 4),
        ),
        SchoolBreak(
          id: 'hu_tel',
          name: 'Spring Break',
          startDate: DateTime(2026, 4, 2),
          endDate: DateTime(2026, 4, 12),
        ),
        SchoolBreak(
          id: 'hu_nyar',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 20),
          endDate: DateTime(2026, 8, 31),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Ireland ────────────────────────────────────────────────────────────────
  // Source: Department of Education and Youth – school year 2025-2026
  static SchoolYear _ireland() {
    return SchoolYear(
      country: 'Ireland',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 6, 30),
      semesters: [
        Semester(
          id: 'ie_t1',
          name: 'Autumn Term',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2025, 12, 19),
        ),
        Semester(
          id: 'ie_t2',
          name: 'Spring Term',
          startDate: DateTime(2026, 1, 5),
          endDate: DateTime(2026, 3, 27),
        ),
        Semester(
          id: 'ie_t3',
          name: 'Summer Term',
          startDate: DateTime(2026, 4, 13),
          endDate: DateTime(2026, 6, 30),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'ie_oct',
          name: 'October Mid-Term',
          startDate: DateTime(2025, 10, 27),
          endDate: DateTime(2025, 10, 31),
        ),
        SchoolBreak(
          id: 'ie_christmas',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2026, 1, 2),
        ),
        SchoolBreak(
          id: 'ie_feb',
          name: 'February Mid-Term',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 20),
        ),
        SchoolBreak(
          id: 'ie_easter',
          name: 'Easter Break',
          startDate: DateTime(2026, 3, 28),
          endDate: DateTime(2026, 4, 12),
        ),
        SchoolBreak(
          id: 'ie_summer',
          name: 'Summer Break',
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 8, 31),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Latvia ─────────────────────────────────────────────────────────────────
  // Source: Izglītības un zinātnes ministrija – school year 2025-2026
  static SchoolYear _latvia() {
    return SchoolYear(
      country: 'Latvia',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 6, 9),
      semesters: [
        Semester(
          id: 'lv_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2026, 1, 16),
        ),
        Semester(
          id: 'lv_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 1, 19),
          endDate: DateTime(2026, 6, 9),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'lv_rudens',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 27),
          endDate: DateTime(2025, 11, 2),
        ),
        SchoolBreak(
          id: 'lv_ziemas',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 1),
        ),
        SchoolBreak(
          id: 'lv_ziemas2',
          name: 'Winter Break',
          startDate: DateTime(2026, 2, 23),
          endDate: DateTime(2026, 3, 1),
        ),
        SchoolBreak(
          id: 'lv_pavasaris',
          name: 'Spring Break',
          startDate: DateTime(2026, 3, 30),
          endDate: DateTime(2026, 4, 6),
        ),
        SchoolBreak(
          id: 'lv_vasara',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 10),
          endDate: DateTime(2026, 8, 31),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Lithuania ──────────────────────────────────────────────────────────────
  // Source: Švietimo, mokslo ir sporto ministerija – school year 2025-2026
  static SchoolYear _lithuania() {
    return SchoolYear(
      country: 'Lithuania',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 6, 12),
      semesters: [
        Semester(
          id: 'lt_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2026, 1, 30),
        ),
        Semester(
          id: 'lt_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 6, 12),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'lt_ruduo',
          name: 'Autumn Break',
          startDate: DateTime(2025, 11, 1),
          endDate: DateTime(2025, 11, 7),
        ),
        SchoolBreak(
          id: 'lt_kaledos',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 24),
          endDate: DateTime(2026, 1, 5),
        ),
        SchoolBreak(
          id: 'lt_ziem',
          name: 'Winter Break',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 20),
        ),
        SchoolBreak(
          id: 'lt_pavasaris',
          name: 'Spring Break',
          startDate: DateTime(2026, 4, 2),
          endDate: DateTime(2026, 4, 10),
        ),
        SchoolBreak(
          id: 'lt_vasara',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 13),
          endDate: DateTime(2026, 8, 31),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }
}
