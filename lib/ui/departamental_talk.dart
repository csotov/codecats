import 'package:flutter/material.dart';

import '../l10n.dart';
import '../services/progress.dart';
import '../services/sfx.dart';
import '../services/speech.dart';
import 'professor.dart';

/// The Profe's pep talk before the first solo exam (OBI Departamental).
class DepartamentalTalk {
  static const id = 'departamental';
  static final examDay = DateTime(2026, 11, 21);

  /// Offered on the map until the day after the exam.
  static bool get relevant =>
      DateTime.now().isBefore(examDay.add(const Duration(days: 1)));

  static const _es = [
    '¡Miau! Hoy no hay código: vamos a hablar de tu primer examen de verdad, la Departamental de la OBI. 🎓',
    'Vas a estar solo frente a la compu, como un gato en su caja. ¡Y está perfecto: entrenaste para esto! 📦',
    'Vas a ver varios problemas. Son como los niveles del juego: completás una función y el grader la prueba.',
    'Paso 1: leé TODOS los problemas antes de escribir. Como un gato que olfatea todo antes de comer. 👃',
    'Paso 2: empezá por el que te parezca más fácil. No hace falta ir en orden.',
    'Paso 3: las subtareas fáciles dan puntos. Asegurá esas primero, aunque no tengas la solución completa. 🐟',
    'Paso 4: probá con los ejemplos antes de enviar, igual que con Ejecutar acá.',
    'Paso 5: si llevás más de 30 o 40 minutos trabado en uno, pasá a otro. Después volvés con la cabeza fresca.',
    'Si te ponés nervioso, respirá hondo tres veces, como un gato antes de saltar. Inhalá... exhalá... 😮‍💨',
    'Concentración de gato cazador: nada de otras pestañas ni distracciones. Solo vos, el problema y tus garras. 🐾',
    'Si algo no sale, no pasa nada. Cada punto cuenta, y lo que no salga lo practicamos después.',
    'La noche antes: dormí bien, comé algo rico y llevá agua. Un gato descansado caza mejor. 😴',
    '¡Confío en vos! Podés volver a ver esta charla cuando quieras desde el mapa. ¡A cazar puntos! 🏆',
  ];

  static const _en = [
    'Meow! No code today: let\'s talk about your first real exam, the OBI Departamental. 🎓',
    'You will be alone at the computer, like a cat in its box. That is fine: you trained for this! 📦',
    'You will get several problems. They are like the game levels: you fill in a function and the grader tests it.',
    'Step 1: read ALL the problems before writing. Like a cat sniffing everything before eating. 👃',
    'Step 2: start with the one that looks easiest. You don\'t have to go in order.',
    'Step 3: easy subtasks give points. Grab those first, even without the full solution. 🐟',
    'Step 4: test with the examples before submitting, just like Run here.',
    'Step 5: if you are stuck for more than 30 or 40 minutes, move to another one. Come back later with a fresh head.',
    'If you get nervous, take three deep breaths, like a cat before jumping. In... out... 😮‍💨',
    'Hunter-cat focus: no other tabs, no distractions. Just you, the problem and your claws. 🐾',
    'If something does not work out, that is OK. Every point counts, and we practice the rest later.',
    'The night before: sleep well, eat something tasty and bring water. A rested cat hunts better. 😴',
    'I believe in you! You can watch this talk again any time from the map. Go hunt those points! 🏆',
  ];

  static Future<void> show(BuildContext context) async {
    final l = L.instance;
    final lines = l.pick(_es.join('\n'), _en.join('\n')).split('\n');
    final lang = l.pick('es-419', 'en-US');
    Progress.instance.markTalkSeen(id);
    Sfx.holdMusic();
    try {
      await ProfessorDialog.show(
        context,
        lines,
        lastLabel: l.pick('¡Vamos! 💪', 'Let\'s go! 💪'),
        onLine: (i) {
          if (!Sfx.muted) speak(lines[i], lang: lang);
        },
      );
    } finally {
      stopSpeaking();
      Sfx.releaseMusic();
    }
  }
}
