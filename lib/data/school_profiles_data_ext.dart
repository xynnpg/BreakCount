import '../models/school_profile.dart';
import '../services/subject_importance_service.dart';

const List<SchoolProfile> kSchoolProfilesExt = [
  // ── Poland ────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'pl_technikum',
    displayName: 'Technikum',
    country: 'poland',
    overrides: {
      'matematyka': SubjectImportance.critical,
      'informatyka': SubjectImportance.critical,
      'fizyka': SubjectImportance.high,
      'język polski': SubjectImportance.high,
      'jezyk polski': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'pl_liceum_ogolne',
    displayName: 'Liceum ogólnokształcące',
    country: 'poland',
    overrides: {
      'matematyka': SubjectImportance.critical,
      'fizyka': SubjectImportance.critical,
      'język polski': SubjectImportance.critical,
      'jezyk polski': SubjectImportance.critical,
      'chemia': SubjectImportance.high,
      'biologia': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'pl_humanistyczne',
    displayName: 'Profil humanistyczny',
    country: 'poland',
    overrides: {
      'język polski': SubjectImportance.critical,
      'jezyk polski': SubjectImportance.critical,
      'historia': SubjectImportance.critical,
      'geografia': SubjectImportance.high,
      'matematyka': SubjectImportance.medium,
    },
  ),

  // ── Netherlands ───────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'nl_vwo',
    displayName: 'VWO',
    country: 'netherlands',
    overrides: {
      'wiskunde': SubjectImportance.critical,
      'nederlands': SubjectImportance.critical,
      'natuurkunde': SubjectImportance.critical,
      'scheikunde': SubjectImportance.high,
      'biologie': SubjectImportance.high,
      'informatica': SubjectImportance.high,
      'engels': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'nl_havo',
    displayName: 'HAVO',
    country: 'netherlands',
    overrides: {
      'wiskunde': SubjectImportance.critical,
      'nederlands': SubjectImportance.high,
      'engels': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'nl_vmbo',
    displayName: 'VMBO',
    country: 'netherlands',
    overrides: {
      'wiskunde': SubjectImportance.high,
      'nederlands': SubjectImportance.high,
    },
  ),

  // ── Belgium ───────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'be_aso',
    displayName: 'ASO — Algemeen secundair',
    country: 'belgium',
    overrides: {
      'wiskunde': SubjectImportance.critical,
      'nederlands': SubjectImportance.critical,
      'wetenschappen': SubjectImportance.high,
      'engels': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'be_tso',
    displayName: 'TSO — Technisch secundair',
    country: 'belgium',
    overrides: {
      'wiskunde': SubjectImportance.critical,
      'informatica': SubjectImportance.critical,
      'techniek': SubjectImportance.critical,
    },
  ),
  SchoolProfile(
    id: 'be_kso',
    displayName: 'KSO — Kunstsecundair',
    country: 'belgium',
    overrides: {
      'kunst': SubjectImportance.critical,
      'muziek': SubjectImportance.critical,
      'drama': SubjectImportance.critical,
    },
  ),

  // ── Austria ───────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'at_ahs',
    displayName: 'AHS — Allgemeinbildende Höhere Schule',
    country: 'austria',
    overrides: {
      'mathematik': SubjectImportance.critical,
      'deutsch': SubjectImportance.critical,
      'englisch': SubjectImportance.high,
      'physik': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'at_bhs',
    displayName: 'BHS — Berufsbildende Höhere Schule',
    country: 'austria',
    overrides: {
      'mathematik': SubjectImportance.critical,
      'informatik': SubjectImportance.critical,
      'betriebswirtschaft': SubjectImportance.high,
    },
  ),

  // ── Sweden ────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'se_na',
    displayName: 'Naturvetenskapsprogrammet',
    country: 'sweden',
    overrides: {
      'matematik': SubjectImportance.critical,
      'fysik': SubjectImportance.critical,
      'kemi': SubjectImportance.critical,
      'biologi': SubjectImportance.high,
      'informationsteknik': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'se_sa',
    displayName: 'Samhällsvetenskapsprogrammet',
    country: 'sweden',
    overrides: {
      'svenska': SubjectImportance.critical,
      'samhällskunskap': SubjectImportance.critical,
      'historia': SubjectImportance.high,
      'matematik': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'se_te',
    displayName: 'Teknikprogrammet',
    country: 'sweden',
    overrides: {
      'matematik': SubjectImportance.critical,
      'teknik': SubjectImportance.critical,
      'fysik': SubjectImportance.high,
      'informationsteknik': SubjectImportance.high,
    },
  ),

  // ── Norway ────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'no_studieforberedende',
    displayName: 'Studieforberedende',
    country: 'norway',
    overrides: {
      'matematikk': SubjectImportance.critical,
      'norsk': SubjectImportance.critical,
      'engelsk': SubjectImportance.high,
      'naturfag': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'no_yrkesfag',
    displayName: 'Yrkesfaglig',
    country: 'norway',
    overrides: {
      'matematikk': SubjectImportance.medium,
      'norsk': SubjectImportance.high,
      'yrkefag': SubjectImportance.critical,
    },
  ),

  // ── Denmark ───────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'dk_stx',
    displayName: 'STX — Gymnasium',
    country: 'denmark',
    overrides: {
      'matematik': SubjectImportance.critical,
      'dansk': SubjectImportance.critical,
      'engelsk': SubjectImportance.high,
      'fysik': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'dk_htx',
    displayName: 'HTX — Teknisk Gymnasium',
    country: 'denmark',
    overrides: {
      'matematik': SubjectImportance.critical,
      'teknologi': SubjectImportance.critical,
      'fysik': SubjectImportance.critical,
      'dansk': SubjectImportance.high,
    },
  ),

  // ── Finland ───────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'fi_lukio_science',
    displayName: 'Lukio — Luonnontiede',
    country: 'finland',
    overrides: {
      'matematiikka': SubjectImportance.critical,
      'fysiikka': SubjectImportance.critical,
      'kemia': SubjectImportance.high,
      'biologia': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'fi_lukio_humanities',
    displayName: 'Lukio — Humanistiset',
    country: 'finland',
    overrides: {
      'äidinkieli': SubjectImportance.critical,
      'historia': SubjectImportance.critical,
      'yhteiskuntaoppi': SubjectImportance.high,
      'matematiikka': SubjectImportance.medium,
    },
  ),

  // ── Czech Republic ────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'cz_gymnazium',
    displayName: 'Gymnázium',
    country: 'czech republic',
    overrides: {
      'matematika': SubjectImportance.critical,
      'čeština': SubjectImportance.critical,
      'ceština': SubjectImportance.critical,
      'fyzika': SubjectImportance.critical,
      'anglický jazyk': SubjectImportance.high,
      'chemie': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'cz_sou',
    displayName: 'Střední odborná škola',
    country: 'czech republic',
    overrides: {
      'matematika': SubjectImportance.high,
      'odborné předměty': SubjectImportance.critical,
    },
  ),

  // ── Slovakia ──────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'sk_gymnazium',
    displayName: 'Gymnázium',
    country: 'slovakia',
    overrides: {
      'matematika': SubjectImportance.critical,
      'slovenský jazyk': SubjectImportance.critical,
      'fyzika': SubjectImportance.high,
      'anglický jazyk': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'sk_odborna',
    displayName: 'Stredná odborná škola',
    country: 'slovakia',
    overrides: {
      'matematika': SubjectImportance.high,
      'odborné predmety': SubjectImportance.critical,
    },
  ),

  // ── Hungary ───────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'hu_gimnazium',
    displayName: 'Gimnázium',
    country: 'hungary',
    overrides: {
      'matematika': SubjectImportance.critical,
      'magyar': SubjectImportance.critical,
      'fizika': SubjectImportance.high,
      'angol': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'hu_szakkozep',
    displayName: 'Szakközépiskola',
    country: 'hungary',
    overrides: {
      'matematika': SubjectImportance.high,
      'szakmai tárgyak': SubjectImportance.critical,
    },
  ),

  // ── Portugal ──────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'pt_ciencias_tecnologias',
    displayName: 'Ciências e Tecnologias',
    country: 'portugal',
    overrides: {
      'matemática': SubjectImportance.critical,
      'matematica': SubjectImportance.critical,
      'física e química': SubjectImportance.critical,
      'biologia e geologia': SubjectImportance.high,
      'informática': SubjectImportance.high,
      'informatica': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'pt_humanidades',
    displayName: 'Línguas e Humanidades',
    country: 'portugal',
    overrides: {
      'português': SubjectImportance.critical,
      'historia': SubjectImportance.critical,
      'filosofia': SubjectImportance.high,
      'matematica': SubjectImportance.medium,
    },
  ),

  // ── Greece ────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'gr_theoritiki',
    displayName: 'Θεωρητική Κατεύθυνση',
    country: 'greece',
    overrides: {
      'αρχαία ελληνικά': SubjectImportance.critical,
      'ιστορία': SubjectImportance.critical,
      'λατινικά': SubjectImportance.critical,
      'νεοελληνική γλώσσα': SubjectImportance.critical,
    },
  ),
  SchoolProfile(
    id: 'gr_thitiki',
    displayName: 'Θετική Κατεύθυνση',
    country: 'greece',
    overrides: {
      'μαθηματικά': SubjectImportance.critical,
      'φυσική': SubjectImportance.critical,
      'χημεία': SubjectImportance.critical,
      'βιολογία': SubjectImportance.high,
    },
  ),

  // ── Croatia ───────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'hr_gimnazija',
    displayName: 'Gimnazija',
    country: 'croatia',
    overrides: {
      'matematika': SubjectImportance.critical,
      'hrvatski jezik': SubjectImportance.critical,
      'engleski jezik': SubjectImportance.high,
      'fizika': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'hr_strukovna',
    displayName: 'Strukovna škola',
    country: 'croatia',
    overrides: {
      'matematika': SubjectImportance.high,
      'strukovni predmeti': SubjectImportance.critical,
    },
  ),

  // ── Slovenia ──────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'si_gimnazija',
    displayName: 'Gimnazija',
    country: 'slovenia',
    overrides: {
      'matematika': SubjectImportance.critical,
      'slovenščina': SubjectImportance.critical,
      'angleščina': SubjectImportance.high,
      'fizika': SubjectImportance.high,
    },
  ),

  // ── Estonia ───────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'ee_reaalsuund',
    displayName: 'Reaalsuund',
    country: 'estonia',
    overrides: {
      'matemaatika': SubjectImportance.critical,
      'füüsika': SubjectImportance.critical,
      'keemia': SubjectImportance.high,
      'informaatika': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'ee_humanitaarsuund',
    displayName: 'Humanitaarsuund',
    country: 'estonia',
    overrides: {
      'eesti keel': SubjectImportance.critical,
      'ajalugu': SubjectImportance.critical,
      'matemaatika': SubjectImportance.medium,
    },
  ),

  // ── Latvia ────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'lv_dabaszinibas',
    displayName: 'Dabaszinātnes',
    country: 'latvia',
    overrides: {
      'matemātika': SubjectImportance.critical,
      'fizika': SubjectImportance.critical,
      'ķīmija': SubjectImportance.high,
      'bioloģija': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'lv_humanitaras',
    displayName: 'Humanitārās zinātnes',
    country: 'latvia',
    overrides: {
      'latviešu valoda': SubjectImportance.critical,
      'vēsture': SubjectImportance.critical,
      'matemātika': SubjectImportance.medium,
    },
  ),

  // ── Lithuania ─────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'lt_gamtos',
    displayName: 'Gamtos mokslai',
    country: 'lithuania',
    overrides: {
      'matematika': SubjectImportance.critical,
      'fizika': SubjectImportance.critical,
      'chemija': SubjectImportance.high,
      'biologija': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'lt_humanitariniai',
    displayName: 'Humanitariniai mokslai',
    country: 'lithuania',
    overrides: {
      'lietuvių kalba': SubjectImportance.critical,
      'istorija': SubjectImportance.critical,
      'matematika': SubjectImportance.medium,
    },
  ),

  // ── Luxembourg ────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'lu_classique',
    displayName: 'Enseignement classique',
    country: 'luxembourg',
    overrides: {
      'mathématiques': SubjectImportance.critical,
      'mathematiques': SubjectImportance.critical,
      'français': SubjectImportance.critical,
      'francais': SubjectImportance.critical,
      'allemand': SubjectImportance.high,
      'anglais': SubjectImportance.high,
    },
  ),

  // ── Switzerland ───────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'ch_matura_science',
    displayName: 'Matura — Naturwissenschaften',
    country: 'switzerland',
    overrides: {
      'mathematik': SubjectImportance.critical,
      'physik': SubjectImportance.critical,
      'chemie': SubjectImportance.critical,
      'biologie': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'ch_matura_humanities',
    displayName: 'Matura — Geisteswissenschaften',
    country: 'switzerland',
    overrides: {
      'deutsch': SubjectImportance.critical,
      'französisch': SubjectImportance.critical,
      'geschichte': SubjectImportance.critical,
      'mathematik': SubjectImportance.medium,
    },
  ),

  // ── Ireland ───────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'ie_leaving_science',
    displayName: 'Leaving Cert — Science',
    country: 'ireland',
    overrides: {
      'mathematics': SubjectImportance.critical,
      'physics': SubjectImportance.critical,
      'chemistry': SubjectImportance.critical,
      'biology': SubjectImportance.high,
      'english': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'ie_leaving_arts',
    displayName: 'Leaving Cert — Arts',
    country: 'ireland',
    overrides: {
      'english': SubjectImportance.critical,
      'history': SubjectImportance.critical,
      'geography': SubjectImportance.high,
      'mathematics': SubjectImportance.high,
    },
  ),

  // ── Turkey ────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'tr_fen',
    displayName: 'Fen Bilimleri',
    country: 'turkey',
    overrides: {
      'matematik': SubjectImportance.critical,
      'fizik': SubjectImportance.critical,
      'kimya': SubjectImportance.critical,
      'biyoloji': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'tr_sosyal',
    displayName: 'Sosyal Bilimler',
    country: 'turkey',
    overrides: {
      'türk dili': SubjectImportance.critical,
      'tarih': SubjectImportance.critical,
      'coğrafya': SubjectImportance.high,
      'matematik': SubjectImportance.medium,
    },
  ),
  SchoolProfile(
    id: 'tr_meslek',
    displayName: 'Mesleki ve Teknik',
    country: 'turkey',
    overrides: {
      'matematik': SubjectImportance.high,
      'meslek dersleri': SubjectImportance.critical,
    },
  ),

  // ── USA ───────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'us_stem',
    displayName: 'STEM Track',
    country: 'usa',
    overrides: {
      'calculus': SubjectImportance.critical,
      'algebra': SubjectImportance.critical,
      'precalculus': SubjectImportance.critical,
      'physics': SubjectImportance.critical,
      'ap physics': SubjectImportance.critical,
      'ap chemistry': SubjectImportance.critical,
      'chemistry': SubjectImportance.critical,
      'computer science': SubjectImportance.critical,
      'biology': SubjectImportance.high,
      'ap biology': SubjectImportance.critical,
      'english': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'us_humanities',
    displayName: 'Humanities Track',
    country: 'usa',
    overrides: {
      'english': SubjectImportance.critical,
      'literature': SubjectImportance.critical,
      'history': SubjectImportance.critical,
      'us history': SubjectImportance.critical,
      'world history': SubjectImportance.critical,
      'economics': SubjectImportance.high,
      'psychology': SubjectImportance.high,
      'calculus': SubjectImportance.medium,
      'algebra': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'us_arts',
    displayName: 'Arts Track',
    country: 'usa',
    overrides: {
      'art': SubjectImportance.critical,
      'music': SubjectImportance.critical,
      'drama': SubjectImportance.critical,
      'english': SubjectImportance.high,
      'algebra': SubjectImportance.medium,
    },
  ),

  // ── Canada ────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'ca_sciences',
    displayName: 'Sciences',
    country: 'canada',
    overrides: {
      'mathematics': SubjectImportance.critical,
      'physics': SubjectImportance.critical,
      'chemistry': SubjectImportance.critical,
      'biology': SubjectImportance.high,
      'computer science': SubjectImportance.high,
      'english': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'ca_arts_humanities',
    displayName: 'Arts & Humanities',
    country: 'canada',
    overrides: {
      'english': SubjectImportance.critical,
      'history': SubjectImportance.critical,
      'geography': SubjectImportance.high,
      'mathematics': SubjectImportance.medium,
    },
  ),

  // ── Australia ─────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'au_stem',
    displayName: 'Science/Technology',
    country: 'australia',
    overrides: {
      'mathematics': SubjectImportance.critical,
      'physics': SubjectImportance.critical,
      'chemistry': SubjectImportance.critical,
      'biology': SubjectImportance.high,
      'computer science': SubjectImportance.high,
      'english': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'au_humanities',
    displayName: 'Humanities',
    country: 'australia',
    overrides: {
      'english': SubjectImportance.critical,
      'history': SubjectImportance.critical,
      'geography': SubjectImportance.high,
      'mathematics': SubjectImportance.medium,
    },
  ),

  // ── Japan ─────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'jp_rika',
    displayName: '理科系 (Rika — Science)',
    country: 'japan',
    overrides: {
      '数学': SubjectImportance.critical,
      '物理': SubjectImportance.critical,
      '化学': SubjectImportance.critical,
      '生物': SubjectImportance.high,
      '英語': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'jp_bunkei',
    displayName: '文科系 (Bunkei — Humanities)',
    country: 'japan',
    overrides: {
      '国語': SubjectImportance.critical,
      '日本史': SubjectImportance.critical,
      '地理': SubjectImportance.high,
      '英語': SubjectImportance.critical,
      '数学': SubjectImportance.medium,
    },
  ),

  // ── Brazil ────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'br_ciencias_natureza',
    displayName: 'Ciências da Natureza',
    country: 'brazil',
    overrides: {
      'matemática': SubjectImportance.critical,
      'matematica': SubjectImportance.critical,
      'física': SubjectImportance.critical,
      'fisica': SubjectImportance.critical,
      'química': SubjectImportance.critical,
      'quimica': SubjectImportance.critical,
      'biologia': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'br_humanas',
    displayName: 'Ciências Humanas',
    country: 'brazil',
    overrides: {
      'português': SubjectImportance.critical,
      'historia': SubjectImportance.critical,
      'geografia': SubjectImportance.critical,
      'filosofia': SubjectImportance.high,
      'matematica': SubjectImportance.medium,
    },
  ),

  // ── Mexico ────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'mx_preparatoria',
    displayName: 'Preparatoria General',
    country: 'mexico',
    overrides: {
      'matemáticas': SubjectImportance.critical,
      'matematicas': SubjectImportance.critical,
      'español': SubjectImportance.critical,
      'física': SubjectImportance.high,
      'fisica': SubjectImportance.high,
      'química': SubjectImportance.high,
      'quimica': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'mx_cet',
    displayName: 'Centro de Estudios Tecnológicos',
    country: 'mexico',
    overrides: {
      'matemáticas': SubjectImportance.critical,
      'matematicas': SubjectImportance.critical,
      'tecnología': SubjectImportance.critical,
      'informatica': SubjectImportance.critical,
    },
  ),
];
