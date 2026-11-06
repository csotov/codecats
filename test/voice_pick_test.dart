import 'package:codecats/services/voice_pick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('picks a male Spanish voice, preferring natural ones', () {
    final vs = [
      ('Google español de Estados Unidos', 'es-US'),
      ('Microsoft Sabina - Spanish (Mexico)', 'es-MX'),
      ('Microsoft Raul - Spanish (Mexico)', 'es-MX'),
      ('Microsoft Jorge Online (Natural) - Spanish (Mexico)', 'es-MX'),
      ('Microsoft David - English', 'en-US'),
    ];
    expect(pickMaleVoice(vs, 'es-419'), 3);
    expect(pickMaleVoice(vs.take(3).toList(), 'es-419'), 2);
    expect(pickMaleVoice(vs.take(2).toList(), 'es-419'), -1);
    expect(pickMaleVoice(vs, 'en-US'), 4);
  });
}
