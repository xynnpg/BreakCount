import '../models/school_profile.dart';
import '../services/subject_importance_service.dart';
import 'school_profiles_data_ext.dart';

const List<SchoolProfile> kSchoolProfiles = [
  // ── Romania ──────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'ro_teoretic_uman',
    displayName: 'Teoretic — Uman',
    country: 'romania',
    overrides: {
      'limba română': SubjectImportance.critical,
      'limba romana': SubjectImportance.critical,
      'lb. română': SubjectImportance.critical,
      'lb română': SubjectImportance.critical,
      'lb. romana': SubjectImportance.critical,
      'lb romana': SubjectImportance.critical,
      'istorie': SubjectImportance.critical,
      'filozofie': SubjectImportance.critical,
      'filosofie': SubjectImportance.critical,
      'psihologie': SubjectImportance.high,
      'sociologie': SubjectImportance.high,
      'logică': SubjectImportance.high,
      'logica': SubjectImportance.high,
      'matematică': SubjectImportance.high,
      'matematica': SubjectImportance.high,
      'fizică': SubjectImportance.medium,
      'fizica': SubjectImportance.medium,
    },
  ),
  SchoolProfile(
    id: 'ro_teoretic_real',
    displayName: 'Teoretic — Științe',
    country: 'romania',
    overrides: {
      'matematică': SubjectImportance.critical,
      'matematica': SubjectImportance.critical,
      'fizică': SubjectImportance.critical,
      'fizica': SubjectImportance.critical,
      'chimie': SubjectImportance.critical,
      'biologie': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'ro_mate_info',
    displayName: 'Teoretic — Mate-Informatică',
    country: 'romania',
    overrides: {
      'matematică': SubjectImportance.critical,
      'matematica': SubjectImportance.critical,
      'informatică': SubjectImportance.critical,
      'informatica': SubjectImportance.critical,
      'fizică': SubjectImportance.high,
      'fizica': SubjectImportance.high,
      'chimie': SubjectImportance.medium,
    },
  ),
  SchoolProfile(
    id: 'ro_tehnologic',
    displayName: 'Tehnologic',
    country: 'romania',
    overrides: {
      'tic': SubjectImportance.critical,
      'economie aplicată': SubjectImportance.critical,
      'economie aplicata': SubjectImportance.critical,
      'economie': SubjectImportance.high,
      'informatică': SubjectImportance.high,
      'informatica': SubjectImportance.high,
      'matematică': SubjectImportance.high,
      'matematica': SubjectImportance.high,
      'fizică': SubjectImportance.medium,
      'fizica': SubjectImportance.medium,
    },
  ),
  SchoolProfile(
    id: 'ro_vocational',
    displayName: 'Vocațional',
    country: 'romania',
    overrides: {
      'muzică': SubjectImportance.critical,
      'muzica': SubjectImportance.critical,
      'desen': SubjectImportance.critical,
      'educație fizică': SubjectImportance.critical,
      'educatie fizica': SubjectImportance.critical,
      'ed. fiz.': SubjectImportance.critical,
      'ed fiz': SubjectImportance.critical,
      'religie': SubjectImportance.high,
    },
  ),

  // ── France ────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'fr_generale',
    displayName: 'Voie générale',
    country: 'france',
    overrides: {
      'mathématiques': SubjectImportance.critical,
      'mathematiques': SubjectImportance.critical,
      'français': SubjectImportance.critical,
      'francais': SubjectImportance.critical,
      'philosophie': SubjectImportance.high,
      'anglais': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'fr_scientifique',
    displayName: 'Voie générale — Sciences',
    country: 'france',
    overrides: {
      'mathématiques': SubjectImportance.critical,
      'mathematiques': SubjectImportance.critical,
      'physique-chimie': SubjectImportance.critical,
      'physique': SubjectImportance.critical,
      'svt': SubjectImportance.critical,
      'informatique': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'fr_technologique',
    displayName: 'Voie technologique',
    country: 'france',
    overrides: {
      'mathématiques': SubjectImportance.high,
      'mathematiques': SubjectImportance.high,
      'informatique': SubjectImportance.critical,
    },
  ),
  SchoolProfile(
    id: 'fr_professionnelle',
    displayName: 'Voie professionnelle',
    country: 'france',
    overrides: {
      'français': SubjectImportance.high,
      'francais': SubjectImportance.high,
      'mathématiques': SubjectImportance.medium,
      'mathematiques': SubjectImportance.medium,
    },
  ),

  // ── Germany ───────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'de_gymnasium',
    displayName: 'Gymnasium',
    country: 'germany',
    overrides: {
      'mathematik': SubjectImportance.critical,
      'mathe': SubjectImportance.critical,
      'deutsch': SubjectImportance.critical,
      'physik': SubjectImportance.critical,
      'englisch': SubjectImportance.high,
      'chemie': SubjectImportance.high,
      'biologie': SubjectImportance.high,
      'informatik': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'de_realschule',
    displayName: 'Realschule',
    country: 'germany',
    overrides: {
      'mathematik': SubjectImportance.critical,
      'mathe': SubjectImportance.critical,
      'deutsch': SubjectImportance.high,
      'englisch': SubjectImportance.high,
      'informatik': SubjectImportance.medium,
    },
  ),
  SchoolProfile(
    id: 'de_hauptschule',
    displayName: 'Hauptschule',
    country: 'germany',
    overrides: {
      'mathematik': SubjectImportance.high,
      'mathe': SubjectImportance.high,
      'deutsch': SubjectImportance.high,
      'englisch': SubjectImportance.medium,
    },
  ),

  // ── United Kingdom ────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'gb_alevels_science',
    displayName: 'A-Levels — Science',
    country: 'united kingdom',
    overrides: {
      'mathematics': SubjectImportance.critical,
      'maths': SubjectImportance.critical,
      'further maths': SubjectImportance.critical,
      'physics': SubjectImportance.critical,
      'chemistry': SubjectImportance.critical,
      'biology': SubjectImportance.high,
      'computer science': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'gb_alevels_humanities',
    displayName: 'A-Levels — Humanities',
    country: 'united kingdom',
    overrides: {
      'english language': SubjectImportance.critical,
      'english literature': SubjectImportance.critical,
      'history': SubjectImportance.critical,
      'geography': SubjectImportance.high,
      'economics': SubjectImportance.high,
      'psychology': SubjectImportance.high,
      'mathematics': SubjectImportance.medium,
      'maths': SubjectImportance.medium,
    },
  ),
  SchoolProfile(
    id: 'gb_gcse',
    displayName: 'GCSE',
    country: 'united kingdom',
    overrides: {
      'mathematics': SubjectImportance.critical,
      'maths': SubjectImportance.critical,
      'english language': SubjectImportance.critical,
      'english literature': SubjectImportance.high,
      'science': SubjectImportance.high,
    },
  ),

  // ── Italy ─────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'it_liceo_scientifico',
    displayName: 'Liceo Scientifico',
    country: 'italy',
    overrides: {
      'matematica': SubjectImportance.critical,
      'fisica': SubjectImportance.critical,
      'chimica': SubjectImportance.high,
      'biologia': SubjectImportance.high,
      'informatica': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'it_liceo_classico',
    displayName: 'Liceo Classico',
    country: 'italy',
    overrides: {
      'italiano': SubjectImportance.critical,
      'storia': SubjectImportance.critical,
      'filosofia': SubjectImportance.critical,
      'latino': SubjectImportance.critical,
      'greco': SubjectImportance.critical,
      'matematica': SubjectImportance.medium,
    },
  ),
  SchoolProfile(
    id: 'it_liceo_linguistico',
    displayName: 'Liceo Linguistico',
    country: 'italy',
    overrides: {
      'italiano': SubjectImportance.critical,
      'inglese': SubjectImportance.critical,
      'storia': SubjectImportance.high,
      'matematica': SubjectImportance.medium,
    },
  ),
  SchoolProfile(
    id: 'it_tecnico',
    displayName: 'Istituto Tecnico',
    country: 'italy',
    overrides: {
      'matematica': SubjectImportance.critical,
      'informatica': SubjectImportance.critical,
      'fisica': SubjectImportance.high,
    },
  ),

  // ── Spain ─────────────────────────────────────────────────────────────────
  SchoolProfile(
    id: 'es_bachillerato_ciencias',
    displayName: 'Bachillerato — Ciencias',
    country: 'spain',
    overrides: {
      'matemáticas': SubjectImportance.critical,
      'matematicas': SubjectImportance.critical,
      'física': SubjectImportance.critical,
      'fisica': SubjectImportance.critical,
      'química': SubjectImportance.critical,
      'quimica': SubjectImportance.critical,
      'biología': SubjectImportance.high,
      'biologia': SubjectImportance.high,
    },
  ),
  SchoolProfile(
    id: 'es_bachillerato_humanidades',
    displayName: 'Bachillerato — Humanidades',
    country: 'spain',
    overrides: {
      'lengua': SubjectImportance.critical,
      'historia': SubjectImportance.critical,
      'geografía': SubjectImportance.critical,
      'filosofía': SubjectImportance.critical,
      'latín': SubjectImportance.high,
      'matematicas': SubjectImportance.medium,
      'matemáticas': SubjectImportance.medium,
    },
  ),
  SchoolProfile(
    id: 'es_fp',
    displayName: 'Formación Profesional',
    country: 'spain',
    overrides: {
      'informática': SubjectImportance.critical,
      'informatica': SubjectImportance.critical,
      'matematicas': SubjectImportance.medium,
      'matemáticas': SubjectImportance.medium,
    },
  ),

  ...kSchoolProfilesExt,
];
