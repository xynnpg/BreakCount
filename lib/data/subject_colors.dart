import '../app/constants.dart';

/// Returns a difficulty-based color (int) for a subject name.
/// Uses keyword matching so it works across all languages.
int subjectDifficultyColor(String subjectName) {
  final n = subjectName.toLowerCase().trim();
  if (_isPE(n)) return 0xFF43A047;
  if (_isPhysics(n)) return 0xFFE53935;
  if (_isChemistry(n)) return 0xFFFF5722;
  if (_isMath(n)) return 0xFFFF6D00;
  if (_isCS(n)) return 0xFF7C3AED;
  if (_isBiology(n)) return 0xFF2E7D32;
  if (_isNativeLang(n)) return 0xFF1565C0;
  if (_isForeignLang(n)) return 0xFF1E88E5;
  if (_isHistory(n)) return 0xFF795548;
  if (_isGeography(n)) return 0xFF00897B;
  if (_isArt(n)) return 0xFFE91E63;
  if (_isMusic(n)) return 0xFFAB47BC;
  if (_isReligion(n)) return 0xFFFFB300;
  if (_isPhilosophy(n)) return 0xFF6A1B9A;
  if (_isEconomics(n)) return 0xFF0288D1;
  return AppColors.subjectColors[n.hashCode.abs() % AppColors.subjectColors.length];
}

bool _isPE(String n) =>
    n == 'sport' || n == 'pe' || n == 'wf' || n == 'tzk' ||
    (n.contains('fiz') && (n.contains('ed') || n.contains('educaț') || n.contains('educaţ'))) ||
    n.contains('physical ed') || n.contains('idræt') || n.contains('idrott') ||
    n.contains('liikunta') || n.contains('tjelesna') || n.contains('testnev') ||
    n.contains('beden eğit') || n.contains('kehaline') || n.contains('kūno') ||
    n.contains('éducation phys') || n.contains('educação física') ||
    n.contains('educación física') || n.contains('lichamelijke') ||
    n.contains('sportna vzgoja') || n.contains('φυσική αγωγή') ||
    n.contains('telesná') || n.contains('idrett') || n.contains('krop');

bool _isPhysics(String n) =>
    n == 'fizică' || n == 'physik' || n == 'physics' || n == 'physique' ||
    n == 'fisica' || n == 'física' || n == 'fysiikka' || n == 'fyzika' ||
    n == 'fizika' || n == 'fysikk' || n == 'fysik' || n == 'φυσική' ||
    n == 'físico-química' || n == 'fizik' || n == 'fen bilgisi' ||
    (n.startsWith('phys') && !n.contains('ed'));

bool _isChemistry(String n) =>
    n.contains('chim') || n.contains('chem') || n.contains('kemi') ||
    n.contains('kimya') || n.contains('keemia') || n.contains('χημ') ||
    n.contains('scheik');

bool _isMath(String n) =>
    n.startsWith('mat') || n.startsWith('wisk') || n == 'algebra' ||
    n == 'maths' || n == 'math' || n == 'mathe' || n == 'μαθηματικά';

bool _isCS(String n) =>
    n.contains('informat') || n.contains('comput') || n.contains('bilgi') ||
    n.contains('bilişim') || n == 'it' || n == 'ict' || n == 'tic' ||
    n.contains('πληροφορική') || (n.startsWith('tec') && n.length < 6);

bool _isBiology(String n) =>
    n.contains('biol') || n.contains('biyol') || n.contains('bioloog') ||
    n.contains('βιολ') || n.contains('life sc');

bool _isNativeLang(String n) {
  const natives = [
    'română', 'deutsch', 'français', 'polski', 'türkçe',
    'español', 'italiano', 'português', 'nederlands', 'svenska', 'norsk',
    'dansk', 'suomi', 'magyar', 'slovenčina', 'slovenščina', 'hrvatski',
    'eesti keel', 'latviešu', 'lietuvių', 'luxembourgeois',
    'νέα ελληνικά', 'ελληνική γλώσσα', 'äidinkieli', 'gaeilge',
    'irish', 'čeština',
  ];
  return natives.contains(n) || n.contains('language arts') ||
      n.contains('język polski') || n.contains('slovenský jazyk') ||
      n.contains('lb. română') || n.contains('lb română');
}

bool _isForeignLang(String n) =>
    n.contains('engl') || n.contains('angl') || n.contains('franc') ||
    (n.contains('latin') && n.length < 8) || n.contains('span') ||
    n.contains('alema') || n.contains('tedesc') || n.contains('german') ||
    n.contains('ingilizce') || n.contains('αγγλικά') || n.contains('portugu');

bool _isHistory(String n) =>
    n.contains('istori') || n.contains('gesch') || n.contains('histor') ||
    n.contains('dějepis') || n.contains('dejepis') || n.contains('ajalugu') ||
    n.contains('vēsture') || n.contains('tarih') || n.contains('ιστορία') ||
    n.contains('történ');

bool _isGeography(String n) =>
    n.startsWith('geo') || n.contains('aardrijksk') || n.contains('coğrafya') ||
    n.contains('ģeogrāfija') || n.contains('geograafia') || n.contains('γεωγρ');

bool _isArt(String n) =>
    n == 'desen' || n == 'arte' || n == 'art' || n == 'arts' ||
    n.contains('plastyk') || n.contains('rajz') || n.contains('likovna') ||
    n.contains('vizualna') || n.contains('taide') || n.contains('bildner') ||
    n.contains('billedkunst') || n.contains('εικαστ') || n.contains('visual') ||
    (n.contains('kunst') && !n.contains('musik'));

bool _isMusic(String n) =>
    n.contains('muz') || n.contains('musik') || n.contains('musiq') ||
    n.contains('music') || n.contains('musie') || n.contains('ének') ||
    n.contains('musiikki') || n.contains('μουσική');

bool _isReligion(String n) =>
    n.contains('religi') || n.contains('vjero') || n.contains('θρησκ') ||
    n.contains('erkölcs') || n.contains('tikybą') || n.contains('uskonto');

bool _isPhilosophy(String n) =>
    n.contains('filos') || n.contains('philos') || n == 'logică' ||
    n.contains('logic') || n.contains('felsefe') || n.contains('φιλοσ') ||
    n.contains('ethics') || n.contains('etică') || n.contains('etika');

bool _isEconomics(String n) =>
    n.contains('econ') || n.contains('civic') || n.contains('wirtsch') ||
    n.contains('sociol') || n.contains('maatsch') || n.contains('samhäll') ||
    n.contains('ühisk') || n.contains('government') || n.contains('business') ||
    n.contains('formare') || n.contains('κοινων');
