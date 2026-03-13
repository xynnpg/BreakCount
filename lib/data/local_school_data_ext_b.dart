import '../models/school_year.dart';

/// Extended bundled country data – second half (Luxembourg → Switzerland).
/// Countries: Luxembourg, Netherlands, Norway, Portugal, Slovakia,
///            Slovenia, Spain, Sweden, Switzerland
///
/// Luxembourg — Ministère de l'Éducation nationale
/// Netherlands— Ministerie van Onderwijs, Cultuur en Wetenschap (Central region)
/// Norway     — Oslo municipality reference
/// Portugal   — Ministério da Educação
/// Slovakia   — Ministerstvo školstva (Bratislava region)
/// Slovenia   — Ministrstvo za vzgojo in izobraževanje (Central Slovenia)
/// Spain      — Comunidad de Madrid
/// Sweden     — City of Stockholm compulsory school
/// Switzerland— Canton of Zurich
class LocalDataExtB {
  static SchoolYear? forCountry(String country) {
    switch (country) {
      case 'Luxembourg':
        return _luxembourg();
      case 'Netherlands':
        return _netherlands();
      case 'Norway':
        return _norway();
      case 'Portugal':
        return _portugal();
      case 'Slovakia':
        return _slovakia();
      case 'Slovenia':
        return _slovenia();
      case 'Spain':
        return _spain();
      case 'Sweden':
        return _sweden();
      case 'Switzerland':
        return _switzerland();
      default:
        return null;
    }
  }

  // ── Luxembourg ─────────────────────────────────────────────────────────────
  // Source: Ministère de l'Éducation nationale, de l'Enfance et de la Jeunesse
  static SchoolYear _luxembourg() {
    return SchoolYear(
      country: 'Luxembourg',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 15),
      endDate: DateTime(2026, 7, 15),
      semesters: [
        Semester(
          id: 'lu_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 15),
          endDate: DateTime(2026, 1, 16),
        ),
        Semester(
          id: 'lu_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 1, 19),
          endDate: DateTime(2026, 7, 15),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'lu_toussaint',
          name: 'All Saints Break',
          startDate: DateTime(2025, 11, 1),
          endDate: DateTime(2025, 11, 9),
        ),
        SchoolBreak(
          id: 'lu_noel',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2026, 1, 4),
        ),
        SchoolBreak(
          id: 'lu_carnaval',
          name: 'Carnival Break',
          startDate: DateTime(2026, 2, 14),
          endDate: DateTime(2026, 2, 22),
        ),
        SchoolBreak(
          id: 'lu_paques',
          name: 'Easter Break',
          startDate: DateTime(2026, 3, 28),
          endDate: DateTime(2026, 4, 12),
        ),
        SchoolBreak(
          id: 'lu_pentecote',
          name: 'Whitsun Break',
          startDate: DateTime(2026, 5, 23),
          endDate: DateTime(2026, 5, 31),
        ),
        SchoolBreak(
          id: 'lu_ete',
          name: 'Summer Break',
          startDate: DateTime(2026, 7, 16),
          endDate: DateTime(2026, 9, 13),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Netherlands (Central region reference) ────────────────────────────────
  // Source: Ministerie van OCW – schoolvakanties 2025-2026 (government.nl)
  static SchoolYear _netherlands() {
    return SchoolYear(
      country: 'Netherlands',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 8, 25),
      endDate: DateTime(2026, 7, 17),
      semesters: [
        Semester(
          id: 'nl_s1',
          name: 'Autumn Semester',
          startDate: DateTime(2025, 8, 25),
          endDate: DateTime(2025, 12, 19),
        ),
        Semester(
          id: 'nl_s2',
          name: 'Spring Semester',
          startDate: DateTime(2026, 1, 5),
          endDate: DateTime(2026, 7, 17),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'nl_herfst',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 18),
          endDate: DateTime(2025, 10, 26),
        ),
        SchoolBreak(
          id: 'nl_kerst',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2026, 1, 4),
        ),
        SchoolBreak(
          id: 'nl_voorjaar',
          name: 'Spring Break',
          startDate: DateTime(2026, 2, 21),
          endDate: DateTime(2026, 3, 1),
        ),
        SchoolBreak(
          id: 'nl_mei',
          name: 'May Break',
          startDate: DateTime(2026, 4, 25),
          endDate: DateTime(2026, 5, 3),
        ),
        SchoolBreak(
          id: 'nl_zomer',
          name: 'Summer Break',
          startDate: DateTime(2026, 7, 18),
          endDate: DateTime(2026, 8, 30),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Norway (Oslo municipality reference) ──────────────────────────────────
  // Source: Oslo commune school calendar 2025-2026
  static SchoolYear _norway() {
    return SchoolYear(
      country: 'Norway',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 8, 18),
      endDate: DateTime(2026, 6, 19),
      semesters: [
        Semester(
          id: 'no_s1',
          name: 'Autumn Semester',
          startDate: DateTime(2025, 8, 18),
          endDate: DateTime(2025, 12, 19),
        ),
        Semester(
          id: 'no_s2',
          name: 'Spring Semester',
          startDate: DateTime(2026, 1, 5),
          endDate: DateTime(2026, 6, 19),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'no_host',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 6),
          endDate: DateTime(2025, 10, 10),
        ),
        SchoolBreak(
          id: 'no_jul',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2026, 1, 4),
        ),
        SchoolBreak(
          id: 'no_vinter',
          name: 'Winter Break',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 20),
        ),
        SchoolBreak(
          id: 'no_paaske',
          name: 'Easter Break',
          startDate: DateTime(2026, 3, 30),
          endDate: DateTime(2026, 4, 7),
        ),
        SchoolBreak(
          id: 'no_sommer',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 20),
          endDate: DateTime(2026, 8, 17),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Portugal ───────────────────────────────────────────────────────────────
  // Source: Ministério da Educação – Despacho normativo, ano letivo 2025-2026
  static SchoolYear _portugal() {
    return SchoolYear(
      country: 'Portugal',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 11),
      endDate: DateTime(2026, 6, 12),
      semesters: [
        Semester(
          id: 'pt_t1',
          name: 'First Term',
          startDate: DateTime(2025, 9, 11),
          endDate: DateTime(2025, 12, 15),
        ),
        Semester(
          id: 'pt_t2',
          name: 'Second Term',
          startDate: DateTime(2026, 1, 6),
          endDate: DateTime(2026, 3, 29),
        ),
        Semester(
          id: 'pt_t3',
          name: 'Third Term',
          startDate: DateTime(2026, 4, 13),
          endDate: DateTime(2026, 6, 12),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'pt_todos_santos',
          name: 'All Saints Day',
          startDate: DateTime(2025, 11, 1),
          endDate: DateTime(2025, 11, 1),
        ),
        SchoolBreak(
          id: 'pt_natal',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 16),
          endDate: DateTime(2026, 1, 5),
        ),
        SchoolBreak(
          id: 'pt_carnaval',
          name: 'Carnival Break',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 18),
        ),
        SchoolBreak(
          id: 'pt_pascoa',
          name: 'Easter Break',
          startDate: DateTime(2026, 3, 30),
          endDate: DateTime(2026, 4, 12),
        ),
        SchoolBreak(
          id: 'pt_verao',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 13),
          endDate: DateTime(2026, 9, 10),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Slovakia (Bratislava region reference) ────────────────────────────────
  // Source: Ministerstvo školstva, vedy, výskumu a športu SR
  static SchoolYear _slovakia() {
    return SchoolYear(
      country: 'Slovakia',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 2),
      endDate: DateTime(2026, 6, 30),
      semesters: [
        Semester(
          id: 'sk_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 2),
          endDate: DateTime(2026, 1, 30),
        ),
        Semester(
          id: 'sk_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 6, 30),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'sk_jesen',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 30),
          endDate: DateTime(2025, 10, 31),
        ),
        SchoolBreak(
          id: 'sk_vianoce',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 7),
        ),
        SchoolBreak(
          id: 'sk_jarny',
          name: 'Spring Break',
          startDate: DateTime(2026, 2, 16),
          endDate: DateTime(2026, 2, 20),
        ),
        SchoolBreak(
          id: 'sk_velka_noc',
          name: 'Easter Break',
          startDate: DateTime(2026, 4, 2),
          endDate: DateTime(2026, 4, 7),
        ),
        SchoolBreak(
          id: 'sk_leto',
          name: 'Summer Break',
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 8, 31),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Slovenia (Central Slovenia reference) ─────────────────────────────────
  // Source: Ministrstvo za vzgojo in izobraževanje – šolski leto 2025-2026
  static SchoolYear _slovenia() {
    return SchoolYear(
      country: 'Slovenia',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 6, 24),
      semesters: [
        Semester(
          id: 'si_s1',
          name: 'First Semester',
          startDate: DateTime(2025, 9, 1),
          endDate: DateTime(2026, 1, 30),
        ),
        Semester(
          id: 'si_s2',
          name: 'Second Semester',
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 6, 24),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'si_jesen',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 27),
          endDate: DateTime(2025, 10, 31),
        ),
        SchoolBreak(
          id: 'si_bozic',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 25),
          endDate: DateTime(2026, 1, 2),
        ),
        SchoolBreak(
          id: 'si_zima',
          name: 'Winter Break',
          startDate: DateTime(2026, 2, 23),
          endDate: DateTime(2026, 2, 27),
        ),
        SchoolBreak(
          id: 'si_velika_noc',
          name: 'Easter Break',
          startDate: DateTime(2026, 4, 3),
          endDate: DateTime(2026, 4, 7),
        ),
        SchoolBreak(
          id: 'si_poletje',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 26),
          endDate: DateTime(2026, 8, 31),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Spain (Comunidad de Madrid) ────────────────────────────────────────────
  // Source: Consejería de Educación, Comunidad de Madrid – curso 2025-2026
  static SchoolYear _spain() {
    return SchoolYear(
      country: 'Spain',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 9, 8),
      endDate: DateTime(2026, 6, 19),
      semesters: [
        Semester(
          id: 'es_t1',
          name: 'First Term',
          startDate: DateTime(2025, 9, 8),
          endDate: DateTime(2025, 12, 19),
        ),
        Semester(
          id: 'es_t2',
          name: 'Second Term',
          startDate: DateTime(2026, 1, 8),
          endDate: DateTime(2026, 3, 26),
        ),
        Semester(
          id: 'es_t3',
          name: 'Third Term',
          startDate: DateTime(2026, 4, 7),
          endDate: DateTime(2026, 6, 19),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'es_todos_santos',
          name: 'All Saints Break',
          startDate: DateTime(2025, 10, 31),
          endDate: DateTime(2025, 11, 3),
        ),
        SchoolBreak(
          id: 'es_navidad',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 7),
        ),
        SchoolBreak(
          id: 'es_semana_santa',
          name: 'Easter Break',
          startDate: DateTime(2026, 3, 27),
          endDate: DateTime(2026, 4, 6),
        ),
        SchoolBreak(
          id: 'es_verano',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 20),
          endDate: DateTime(2026, 9, 7),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Sweden (Stockholm municipality reference) ─────────────────────────────
  // Source: City of Stockholm – school terms and vacation periods 2025-2026
  static SchoolYear _sweden() {
    return SchoolYear(
      country: 'Sweden',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 8, 19),
      endDate: DateTime(2026, 6, 12),
      semesters: [
        Semester(
          id: 'se_s1',
          name: 'Autumn Term',
          startDate: DateTime(2025, 8, 19),
          endDate: DateTime(2025, 12, 19),
        ),
        Semester(
          id: 'se_s2',
          name: 'Spring Term',
          startDate: DateTime(2026, 1, 12),
          endDate: DateTime(2026, 6, 12),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'se_host',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 27),
          endDate: DateTime(2025, 10, 31),
        ),
        SchoolBreak(
          id: 'se_jul',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2026, 1, 11),
        ),
        SchoolBreak(
          id: 'se_sportlov',
          name: 'Sportlov (Winter Break)',
          startDate: DateTime(2026, 2, 23),
          endDate: DateTime(2026, 2, 27),
        ),
        SchoolBreak(
          id: 'se_pask',
          name: 'Easter Break',
          startDate: DateTime(2026, 4, 3),
          endDate: DateTime(2026, 4, 10),
        ),
        SchoolBreak(
          id: 'se_sommar',
          name: 'Summer Break',
          startDate: DateTime(2026, 6, 13),
          endDate: DateTime(2026, 8, 16),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }

  // ── Switzerland (Canton of Zurich) ─────────────────────────────────────────
  // Source: Bildungsdirektion des Kantons Zürich – Schulferien 2025-2026
  static SchoolYear _switzerland() {
    return SchoolYear(
      country: 'Switzerland',
      academicYear: '2025-2026',
      startDate: DateTime(2025, 8, 18),
      endDate: DateTime(2026, 7, 10),
      semesters: [
        Semester(
          id: 'ch_s1',
          name: 'Autumn Semester',
          startDate: DateTime(2025, 8, 18),
          endDate: DateTime(2026, 1, 30),
        ),
        Semester(
          id: 'ch_s2',
          name: 'Spring Semester',
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 7, 10),
        ),
      ],
      breaks: [
        SchoolBreak(
          id: 'ch_herbst',
          name: 'Autumn Break',
          startDate: DateTime(2025, 10, 5),
          endDate: DateTime(2025, 10, 17),
        ),
        SchoolBreak(
          id: 'ch_weihnachten',
          name: 'Christmas Break',
          startDate: DateTime(2025, 12, 22),
          endDate: DateTime(2026, 1, 3),
        ),
        SchoolBreak(
          id: 'ch_sport',
          name: 'Sport Break',
          startDate: DateTime(2026, 2, 9),
          endDate: DateTime(2026, 2, 20),
        ),
        SchoolBreak(
          id: 'ch_fruehling',
          name: 'Spring Break',
          startDate: DateTime(2026, 4, 20),
          endDate: DateTime(2026, 5, 2),
        ),
        SchoolBreak(
          id: 'ch_sommer',
          name: 'Summer Break',
          startDate: DateTime(2026, 7, 13),
          endDate: DateTime(2026, 8, 15),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1),
    );
  }
}
