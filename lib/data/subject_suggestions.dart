/// Canonical subject names in native language per country.
// ignore_for_file: lines_longer_than_80_chars
const Map<String, List<String>> subjectSuggestionsByCountry = {
  'default': ['Math', 'English', 'Science', 'History', 'Geography', 'Art', 'Music', 'PE', 'Computer Science', 'Biology', 'Chemistry', 'Physics', 'Literature', 'Philosophy', 'Economics'],
  'Australia': ['Mathematics', 'English', 'Science', 'History', 'Geography', 'PE', 'Art', 'Music', 'Computing', 'Biology', 'Chemistry', 'Physics', 'Economics', 'Legal Studies', 'Health'],
  'Austria': ['Mathematik', 'Deutsch', 'Englisch', 'Physik', 'Chemie', 'Biologie', 'Geschichte', 'Geographie', 'Sport', 'Kunst', 'Musik', 'Informatik', 'Religion', 'Philosophie', 'Latein'],
  'Belgium': ['Mathématiques', 'Français', 'Physique', 'Chimie', 'Biologie', 'Histoire', 'Géographie', 'Anglais', 'EPS', 'Arts', 'Musique', 'Informatique', 'Philosophie', 'Néerlandais', 'Latin'],
  'Brazil': ['Matemática', 'Português', 'Física', 'Química', 'Biologia', 'História', 'Geografia', 'Inglês', 'Ed. Física', 'Arte', 'Informática', 'Filosofia', 'Sociologia', 'Redação', 'Espanhol'],
  'Canada': ['Math', 'English', 'French', 'Science', 'History', 'Geography', 'PE', 'Art', 'Music', 'Computing', 'Biology', 'Chemistry', 'Physics', 'Civics', 'Economics'],
  'Croatia': ['Matematika', 'Hrvatski', 'Engleski', 'Fizika', 'Kemija', 'Biologija', 'Povijest', 'Geografija', 'TZK', 'Likovna kultura', 'Glazbena kultura', 'Informatika', 'Vjeronauk', 'Etika', 'Kemija i fizika'],
  'Czech Republic': ['Matematika', 'Čeština', 'Angličtina', 'Fyzika', 'Chemie', 'Biologie', 'Dějepis', 'Zeměpis', 'Tělesná výchova', 'Výtvarná výchova', 'Hudební výchova', 'Informatika', 'OV', 'Němčina', 'Zeměpis'],
  'Denmark': ['Matematik', 'Dansk', 'Engelsk', 'Fysik/kemi', 'Biologi', 'Historie', 'Geografi', 'Idræt', 'Billedkunst', 'Musik', 'Samfundsfag', 'Naturfag', 'Tysk', 'Fransk', 'Kristendom'],
  'Estonia': ['Matemaatika', 'Eesti keel', 'Inglise keel', 'Füüsika', 'Keemia', 'Bioloogia', 'Ajalugu', 'Geograafia', 'Kehaline kasvatus', 'Kunst', 'Muusika', 'Informaatika', 'Ühiskonnaõpetus', 'Vene keel', 'Saksa keel'],
  'Finland': ['Matematiikka', 'Äidinkieli', 'Englanti', 'Fysiikka', 'Kemia', 'Biologia', 'Historia', 'Maantiede', 'Liikunta', 'Kuvataide', 'Musiikki', 'Tietotekniikka', 'Yhteiskuntaoppi', 'Uskonto', 'Terveystieto'],
  'France': ['Maths', 'Français', 'Physique-Chimie', 'SVT', 'Histoire-Géo', 'Anglais', 'EPS', 'Arts plastiques', 'Musique', 'Informatique', 'Philosophie', 'Économie', 'Latin', 'Espagnol', 'Allemand'],
  'Germany': ['Mathematik', 'Deutsch', 'Englisch', 'Physik', 'Chemie', 'Biologie', 'Geschichte', 'Geographie', 'Sport', 'Kunst', 'Musik', 'Informatik', 'Religion', 'Philosophie', 'Latein'],
  'Greece': ['Μαθηματικά', 'Νέα Ελληνικά', 'Αγγλικά', 'Φυσική', 'Χημεία', 'Βιολογία', 'Ιστορία', 'Γεωγραφία', 'Φυσική Αγωγή', 'Εικαστικά', 'Μουσική', 'Πληροφορική', 'Θρησκευτικά', 'Γαλλικά', 'Κοινωνιολογία'],
  'Hungary': ['Matematika', 'Magyar', 'Angol', 'Fizika', 'Kémia', 'Biológia', 'Történelem', 'Földrajz', 'Testnevelés', 'Rajz', 'Ének-zene', 'Informatika', 'Erkölcstan', 'Természettudomány', 'Irodalom'],
  'Ireland': ['Mathematics', 'English', 'Irish', 'Science', 'History', 'Geography', 'PE', 'Art', 'Music', 'Business', 'RE', 'French', 'Chemistry', 'Biology', 'Physics'],
  'Italy': ['Matematica', 'Italiano', 'Fisica', 'Chimica', 'Biologia', 'Storia', 'Geografia', 'Inglese', 'Ed. Fisica', 'Arte', 'Musica', 'Informatica', 'Filosofia', 'Latino', 'Scienze Naturali'],
  'Japan': ['数学', '国語', '英語', '理科', '社会', '体育', '美術', '音楽', '技術・家庭', '道徳', '保健', '情報', '物理', '化学', '生物'],
  'Latvia': ['Matemātika', 'Latviešu', 'Angļu valoda', 'Fizika', 'Ķīmija', 'Bioloģija', 'Vēsture', 'Ģeogrāfija', 'Sports', 'Vizuālā māksla', 'Mūzika', 'Informātika', 'Sociālās zinātnes', 'Krievu valoda', 'Vācu valoda'],
  'Lithuania': ['Matematika', 'Lietuvių', 'Anglų', 'Fizika', 'Chemija', 'Biologija', 'Istorija', 'Geografija', 'Kūno kultūra', 'Dailė', 'Muzika', 'Informacinės technologijos', 'Tikybą', 'Pilietiškumas', 'Chemija'],
  'Luxembourg': ['Mathématiques', 'Français', 'Allemand', 'Luxembourgeois', 'Physique', 'Chimie', 'Biologie', 'Histoire', 'Géographie', 'EPS', 'Arts', 'Musique', 'Informatique', 'Anglais', 'Latin'],
  'Mexico': ['Matemáticas', 'Español', 'Física', 'Química', 'Biología', 'Historia', 'Geografía', 'Inglés', 'Ed. Física', 'Arte', 'Informática', 'Filosofía', 'Formación Cívica', 'Tecnología', 'Economía'],
  'Netherlands': ['Wiskunde', 'Nederlands', 'Natuurkunde', 'Scheikunde', 'Biologie', 'Geschiedenis', 'Aardrijkskunde', 'Engels', 'Lichamelijke Opvoeding', 'Tekenen', 'Muziek', 'Informatica', 'Maatschappijleer', 'Frans', 'Duits'],
  'Norway': ['Matematikk', 'Norsk', 'Engelsk', 'Fysikk', 'Kjemi', 'Biologi', 'Historie', 'Geografi', 'Idrett', 'Kunst og håndverk', 'Musikk', 'Informatikk', 'Samfunnsfag', 'Naturfag', 'Religionskunskap'],
  'Poland': ['Matematyka', 'Polski', 'Angielski', 'Fizyka', 'Chemia', 'Biologia', 'Historia', 'Geografia', 'WF', 'Plastyka', 'Muzyka', 'Informatyka', 'Religia', 'WOS', 'Niemcki'],
  'Portugal': ['Matemática', 'Português', 'Inglês', 'Físico-Química', 'Biologia', 'História', 'Geografia', 'Ed. Física', 'Ed. Visual', 'Música', 'TIC', 'Filosofia', 'Ciências Naturais', 'Espanhol', 'Economia'],
  'Romania': ['Română', 'Matematică', 'Fizică', 'Chimie', 'Biologie', 'Informatică', 'Geografie', 'Istorie', 'Engleză', 'Franceză', 'Ed. Fizică', 'Religie', 'Logică', 'Economie', 'Desen'],
  'Slovakia': ['Matematika', 'Slovenčina', 'Angličtina', 'Fyzika', 'Chémia', 'Biológia', 'Dejepis', 'Zemepis', 'Telesná výchova', 'Výtvarná výchova', 'Hudobná výchova', 'Informatika', 'Náboženstvo', 'Nemčina', 'Dejepis'],
  'Slovenia': ['Matematika', 'Slovenščina', 'Angleščina', 'Fizika', 'Kemija', 'Biologija', 'Zgodovina', 'Geografija', 'Športna vzgoja', 'Likovna umetnost', 'Glasba', 'Informatika', 'Domovinska vzgoja', 'Etika', 'Kemija'],
  'Spain': ['Matemáticas', 'Lengua Castellana', 'Inglés', 'Física', 'Química', 'Biología', 'Historia', 'Geografía', 'Ed. Física', 'Plástica', 'Música', 'Informática', 'Filosofía', 'Economía', 'Francés'],
  'Sweden': ['Matematik', 'Svenska', 'Engelska', 'Fysik', 'Kemi', 'Biologi', 'Historia', 'Geografi', 'Idrott', 'Bild', 'Musik', 'Datavetenskap', 'Samhällskunskap', 'Religionskunskap', 'Tyska'],
  'Switzerland': ['Mathematik', 'Deutsch', 'Englisch', 'Physik', 'Chemie', 'Biologie', 'Geschichte', 'Geographie', 'Sport', 'Bildnerisches Gestalten', 'Musik', 'Informatik', 'Ethik', 'Französisch', 'Latein'],
  'Turkey': ['Matematik', 'Türkçe', 'İngilizce', 'Fizik', 'Kimya', 'Biyoloji', 'Tarih', 'Coğrafya', 'Beden Eğitimi', 'Görsel Sanatlar', 'Müzik', 'Bilişim', 'Felsefe', 'Fen Bilgisi', 'Din Kültürü'],
  'United Kingdom': ['Maths', 'English', 'Science', 'History', 'Geography', 'Art & Design', 'Music', 'PE', 'Computing', 'Biology', 'Chemistry', 'Physics', 'French', 'Spanish', 'Religious Studies'],
  'Usa': ['Algebra', 'English', 'US History', 'Science', 'PE', 'Art', 'Music', 'Computer Science', 'Biology', 'Chemistry', 'Physics', 'World History', 'Government', 'Economics', 'Spanish'],
};

// Country-specific aliases for AI output → canonical display name.
// Keys are lowercased raw names → canonical form.
const Map<String, Map<String, String>> _aliases = {
  'Romania': {
    'limba română': 'Română', 'lb. română': 'Română', 'lb română': 'Română',
    'lb rom': 'Română', 'romana': 'Română',
    'educație fizică': 'Ed. Fizică', 'educaţie fizică': 'Ed. Fizică',
    'ed fiz': 'Ed. Fizică', 'ed. fiz': 'Ed. Fizică', 'educatie fizica': 'Ed. Fizică',
    'limba engleză': 'Engleză', 'lb engleză': 'Engleză', 'lb en': 'Engleză',
    'lb engl': 'Engleză', 'lb. en': 'Engleză',
    'limba franceză': 'Franceză', 'lb franceză': 'Franceză', 'lb fr': 'Franceză',
    'matematica': 'Matematică', 'informatica': 'Informatică', 'fizica': 'Fizică',
  },
  'Germany': {
    'erdkunde': 'Geographie', 'gemeinschaftskunde': 'Wirtschaft',
    'sozialkunde': 'Philosophie', 'ev. religion': 'Religion', 'kath. religion': 'Religion',
  },
  'France': {
    'svt': 'SVT', 'eps': 'EPS', 'nsi': 'Informatique', 'hggsp': 'Histoire-Géo',
    'llce': 'Anglais', 'hist-géo': 'Histoire-Géo', 'hist geo': 'Histoire-Géo',
    'phys-chim': 'Physique-Chimie', 'physique chimie': 'Physique-Chimie',
  },
};

List<String> getSuggestionsForCountry(String country) {
  return subjectSuggestionsByCountry[country] ??
      subjectSuggestionsByCountry['default']!;
}

/// Maps a raw AI-output subject name to the canonical display name for [country].
String canonicalizeSubject(String rawName, String country) {
  final lowerRaw = rawName.toLowerCase().trim();

  // 1. Country-specific aliases
  final alias = _aliases[country]?[lowerRaw];
  if (alias != null) return alias;

  final suggestions = getSuggestionsForCountry(country);

  // 2. Case-insensitive exact match
  for (final s in suggestions) {
    if (s.toLowerCase() == lowerRaw) return s;
  }

  // 3. Canonical name is contained in raw (e.g. "română" in "limba română")
  for (final s in suggestions) {
    if (lowerRaw.contains(s.toLowerCase())) return s;
  }

  // 4. Raw is contained in canonical (partial match, min 4 chars)
  if (lowerRaw.length >= 4) {
    for (final s in suggestions) {
      if (s.toLowerCase().contains(lowerRaw)) return s;
    }
  }

  return rawName;
}
