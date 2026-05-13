import 'package:flutter_test/flutter_test.dart';

import 'package:breakcount/data/persona_copy.dart';
import 'package:breakcount/data/personas_data.dart';

void main() {
  const expectedKeys = {
    'countdown_urgent',
    'countdown_long',
    'empty_achievements',
    'mood_hint_fire',
    'mood_hint_dead',
    'unlock_tagline',
    'next_break_hint',
    'recap_intro',
    'recap_fallback_template',
    'meet_greeting',
    'vibe_card_caption',
    'streak_celebration',
    'year_over_banner',
    'on_break_banner',
    'schedule_empty_hint',
    'break_reveal',
  };

  test('every persona in kPersonas has every copy key and no empty template', () {
    for (final p in kPersonas) {
      final map = PersonaCopy.all[p.id];
      expect(map, isNotNull, reason: 'persona ${p.id} missing copy map');
      for (final k in expectedKeys) {
        final v = map![k];
        expect(v, isNotNull, reason: '${p.id} missing key $k');
        expect(v!.trim(), isNotEmpty, reason: '${p.id}.$k is empty');
      }
    }
  });

  test('there are exactly 30 personas', () {
    expect(kPersonas.length, 30);
  });

  test('all persona ids are unique', () {
    final ids = kPersonas.map((p) => p.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('interpolates {var} tokens', () {
    final out = PersonaCopy.get('hype', 'next_break_hint',
        vars: {'days': '7', 'name': 'Winter Break'});
    expect(out, contains('7'));
    expect(out, contains('Winter Break'));
    expect(out.contains('{'), isFalse);
  });

  test('falls back to hype when persona id is unknown', () {
    final a = PersonaCopy.get('hype', 'unlock_tagline');
    final b = PersonaCopy.get('unknown-id', 'unlock_tagline');
    expect(b, a);
  });

  test('returns fallback when both persona and hype key miss', () {
    final out = PersonaCopy.get('hype', 'does_not_exist',
        fallback: 'default string');
    expect(out, 'default string');
  });
}
