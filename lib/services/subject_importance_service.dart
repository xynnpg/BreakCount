enum SubjectImportance { low, medium, high, critical }

extension SubjectImportanceExt on SubjectImportance {
  String get label {
    switch (this) {
      case SubjectImportance.critical:
        return 'CRITICAL';
      case SubjectImportance.high:
        return 'HIGH';
      case SubjectImportance.medium:
        return 'MEDIUM';
      case SubjectImportance.low:
        return 'LOW';
    }
  }
}

class SubjectImportanceService {
  /// Returns the importance level for a subject name in a given country.
  /// Falls back to generic English names if the country is not specifically mapped.
  static SubjectImportance getImportance(String subjectName, String country) {
    final key = subjectName.toLowerCase().trim();
    final countryKey = country.toLowerCase().trim();

    final countryMap = _countryMaps[countryKey];
    if (countryMap != null) {
      final result = countryMap[key];
      if (result != null) return result;
    }

    // Fall through to generic names
    return _generic[key] ?? SubjectImportance.medium;
  }

  static const Map<String, Map<String, SubjectImportance>> _countryMaps = {
    'romania': {
      // Critical — baccalaureate / national exam subjects
      'matematică': SubjectImportance.critical,
      'matematica': SubjectImportance.critical,
      'fizică': SubjectImportance.critical,
      'fizica': SubjectImportance.critical,
      'limba română': SubjectImportance.critical,
      'limba romana': SubjectImportance.critical,
      'lb. română': SubjectImportance.critical,
      'lb română': SubjectImportance.critical,
      'lb. romana': SubjectImportance.critical,
      'lb romana': SubjectImportance.critical,
      // High
      'chimie': SubjectImportance.high,
      'biologie': SubjectImportance.high,
      'informatică': SubjectImportance.high,
      'informatica': SubjectImportance.high,
      'limba engleză': SubjectImportance.high,
      'limba engleza': SubjectImportance.high,
      'lb. engleză': SubjectImportance.high,
      'lb engleză': SubjectImportance.high,
      'lb engleza': SubjectImportance.high,
      // Medium
      'geografie': SubjectImportance.medium,
      'istorie': SubjectImportance.medium,
      'psihologie': SubjectImportance.medium,
      'economie aplicată': SubjectImportance.medium,
      'economie aplicata': SubjectImportance.medium,
      'economie': SubjectImportance.medium,
      'tic': SubjectImportance.medium,
      'sociologie': SubjectImportance.medium,
      'filozofie': SubjectImportance.medium,
      'logică': SubjectImportance.medium,
      'logica': SubjectImportance.medium,
      'limba franceză': SubjectImportance.medium,
      'limba franceza': SubjectImportance.medium,
      'lb. franceză': SubjectImportance.medium,
      'limba germană': SubjectImportance.medium,
      'limba germana': SubjectImportance.medium,
      'lb. germană': SubjectImportance.medium,
      // Low
      'religie': SubjectImportance.low,
      'muzică': SubjectImportance.low,
      'muzica': SubjectImportance.low,
      'desen': SubjectImportance.low,
      'educație fizică': SubjectImportance.low,
      'educatie fizica': SubjectImportance.low,
      'ed. fiz.': SubjectImportance.low,
      'ed fiz': SubjectImportance.low,
      'dirigenție': SubjectImportance.low,
      'dirigentie': SubjectImportance.low,
    },
    'france': {
      'mathématiques': SubjectImportance.critical,
      'mathematiques': SubjectImportance.critical,
      'maths': SubjectImportance.critical,
      'physique-chimie': SubjectImportance.critical,
      'physique': SubjectImportance.critical,
      'chimie': SubjectImportance.high,
      'biologie': SubjectImportance.high,
      'svt': SubjectImportance.high,
      'français': SubjectImportance.critical,
      'francais': SubjectImportance.critical,
      'anglais': SubjectImportance.high,
      'histoire-géographie': SubjectImportance.medium,
      'histoire': SubjectImportance.medium,
      'géographie': SubjectImportance.medium,
      'philosophie': SubjectImportance.medium,
      'informatique': SubjectImportance.high,
      'eps': SubjectImportance.low,
      'arts plastiques': SubjectImportance.low,
      'musique': SubjectImportance.low,
    },
    'germany': {
      'mathematik': SubjectImportance.critical,
      'mathe': SubjectImportance.critical,
      'physik': SubjectImportance.critical,
      'chemie': SubjectImportance.high,
      'biologie': SubjectImportance.high,
      'informatik': SubjectImportance.high,
      'deutsch': SubjectImportance.critical,
      'englisch': SubjectImportance.high,
      'geschichte': SubjectImportance.medium,
      'geographie': SubjectImportance.medium,
      'sozialkunde': SubjectImportance.medium,
      'ethik': SubjectImportance.medium,
      'sport': SubjectImportance.low,
      'musik': SubjectImportance.low,
      'kunst': SubjectImportance.low,
      'religion': SubjectImportance.low,
    },
    'poland': {
      'matematyka': SubjectImportance.critical,
      'fizyka': SubjectImportance.critical,
      'chemia': SubjectImportance.high,
      'biologia': SubjectImportance.high,
      'informatyka': SubjectImportance.high,
      'język polski': SubjectImportance.critical,
      'jezyk polski': SubjectImportance.critical,
      'język angielski': SubjectImportance.high,
      'historia': SubjectImportance.medium,
      'geografia': SubjectImportance.medium,
      'wf': SubjectImportance.low,
      'muzyka': SubjectImportance.low,
      'plastyka': SubjectImportance.low,
      'religia': SubjectImportance.low,
    },
    'italy': {
      'matematica': SubjectImportance.critical,
      'fisica': SubjectImportance.critical,
      'chimica': SubjectImportance.high,
      'biologia': SubjectImportance.high,
      'informatica': SubjectImportance.high,
      'italiano': SubjectImportance.critical,
      'inglese': SubjectImportance.high,
      'storia': SubjectImportance.medium,
      'geografia': SubjectImportance.medium,
      'filosofia': SubjectImportance.medium,
      'ed. fisica': SubjectImportance.low,
      'musica': SubjectImportance.low,
      'arte': SubjectImportance.low,
      'religione': SubjectImportance.low,
    },
    'spain': {
      'matemáticas': SubjectImportance.critical,
      'matematicas': SubjectImportance.critical,
      'física': SubjectImportance.critical,
      'fisica': SubjectImportance.critical,
      'química': SubjectImportance.high,
      'quimica': SubjectImportance.high,
      'biología': SubjectImportance.high,
      'biologia': SubjectImportance.high,
      'informática': SubjectImportance.high,
      'informatica': SubjectImportance.high,
      'lengua': SubjectImportance.critical,
      'inglés': SubjectImportance.high,
      'ingles': SubjectImportance.high,
      'historia': SubjectImportance.medium,
      'geografía': SubjectImportance.medium,
      'filosofía': SubjectImportance.medium,
      'educación física': SubjectImportance.low,
      'musica': SubjectImportance.low,
      'religión': SubjectImportance.low,
    },
    'united kingdom': {
      'mathematics': SubjectImportance.critical,
      'maths': SubjectImportance.critical,
      'further maths': SubjectImportance.critical,
      'physics': SubjectImportance.critical,
      'chemistry': SubjectImportance.high,
      'biology': SubjectImportance.high,
      'computer science': SubjectImportance.high,
      'english language': SubjectImportance.critical,
      'english literature': SubjectImportance.high,
      'history': SubjectImportance.medium,
      'geography': SubjectImportance.medium,
      'economics': SubjectImportance.medium,
      'psychology': SubjectImportance.medium,
      'pe': SubjectImportance.low,
      'art': SubjectImportance.low,
      'music': SubjectImportance.low,
      'drama': SubjectImportance.low,
      'rs': SubjectImportance.low,
    },
    'usa': {
      'algebra': SubjectImportance.critical,
      'calculus': SubjectImportance.critical,
      'precalculus': SubjectImportance.critical,
      'geometry': SubjectImportance.high,
      'statistics': SubjectImportance.high,
      'physics': SubjectImportance.critical,
      'chemistry': SubjectImportance.high,
      'biology': SubjectImportance.high,
      'ap biology': SubjectImportance.critical,
      'ap chemistry': SubjectImportance.critical,
      'ap physics': SubjectImportance.critical,
      'english': SubjectImportance.critical,
      'literature': SubjectImportance.high,
      'computer science': SubjectImportance.high,
      'history': SubjectImportance.medium,
      'us history': SubjectImportance.medium,
      'world history': SubjectImportance.medium,
      'economics': SubjectImportance.medium,
      'psychology': SubjectImportance.medium,
      'pe': SubjectImportance.low,
      'art': SubjectImportance.low,
      'music': SubjectImportance.low,
      'drama': SubjectImportance.low,
    },
  };

  static const Map<String, SubjectImportance> _generic = {
    'mathematics': SubjectImportance.critical,
    'math': SubjectImportance.critical,
    'maths': SubjectImportance.critical,
    'physics': SubjectImportance.critical,
    'chemistry': SubjectImportance.high,
    'biology': SubjectImportance.high,
    'computer science': SubjectImportance.high,
    'informatics': SubjectImportance.high,
    'english': SubjectImportance.high,
    'literature': SubjectImportance.high,
    'history': SubjectImportance.medium,
    'geography': SubjectImportance.medium,
    'economics': SubjectImportance.medium,
    'psychology': SubjectImportance.medium,
    'philosophy': SubjectImportance.medium,
    'sociology': SubjectImportance.medium,
    'religion': SubjectImportance.low,
    'music': SubjectImportance.low,
    'art': SubjectImportance.low,
    'drawing': SubjectImportance.low,
    'physical education': SubjectImportance.low,
    'pe': SubjectImportance.low,
    'sport': SubjectImportance.low,
    'homeroom': SubjectImportance.low,
    'drama': SubjectImportance.low,
  };
}
