import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/ref_solutions.dart';
import '../models.dart';
import '../services/cloud.dart';
import '../services/progress.dart';

/// Lost battles and questions to Gemini before it may show the solution.
const kTutorFailsForSolution = 3;
const kTutorAsksForSolution = 3;

final _chats = <String, List<({bool me, String text})>>{};

/// Gemini as a tutor in a side panel (half the screen on wide layouts).
Future<void> openGeminiTutor(BuildContext context,
    {required Level level, required String Function() code}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Gemini',
    barrierColor: Colors.black26,
    pageBuilder: (ctx, _, __) {
      final w = MediaQuery.of(ctx).size.width;
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: w < 700 ? w : math.max(w * 0.5, 420),
          child: _TutorPanel(level: level, code: code),
        ),
      );
    },
    transitionBuilder: (_, a, __, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

class _TutorPanel extends StatefulWidget {
  const _TutorPanel({required this.level, required this.code});
  final Level level;
  final String Function() code;

  @override
  State<_TutorPanel> createState() => _TutorPanelState();
}

class _TutorPanelState extends State<_TutorPanel> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _busy = false;

  List<({bool me, String text})> get _msgs =>
      _chats.putIfAbsent(widget.level.id, () => []);

  int get _asked => _msgs.where((m) => m.me).length;

  bool get _solutionOpen {
    final p = Progress.instance.of(widget.level.id);
    final lost = p.attempts - (p.solved ? 1 : 0);
    return lost >= kTutorFailsForSolution && _asked >= kTutorAsksForSolution;
  }

  String get _problem {
    final lv = widget.level;
    return [
      lv.titleEs,
      lv.statementEs,
      if (lv.inputEs.isNotEmpty) 'Entrada: ${lv.inputEs}',
      if (lv.outputEs.isNotEmpty) 'Salida: ${lv.outputEs}',
      for (final s in lv.samples)
        'Ejemplo:\nentrada:\n${s.input}\nsalida:\n${s.output}',
    ].join('\n\n');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty || _busy) return;
    _ctrl.clear();
    setState(() {
      _msgs.add((me: true, text: q));
      _busy = true;
    });
    _toBottom();
    final code = widget.code();
    final sol = _solutionOpen ? refSolution(widget.level.id) : null;
    String a;
    try {
      final token =
          Cloud.instance.client?.auth.currentSession?.accessToken ?? '';
      final r = await http
          .post(
            Uri.parse('${Cloud.url}/functions/v1/tutor'),
            headers: {
              'Authorization': 'Bearer $token',
              'apikey': Cloud.anonKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'problem': _problem,
              'code': code,
              'solution': sol,
              'messages': [
                for (final m in _msgs)
                  {'role': m.me ? 'user' : 'model', 'text': m.text}
              ],
            }),
          )
          .timeout(const Duration(seconds: 45));
      final d = jsonDecode(r.body) as Map<String, dynamic>;
      a = d['text'] as String? ??
          switch (d['error']) {
            'login' => 'Para hablar con Gemini tenés que entrar a tu cuenta.',
            'busy' =>
              'Gemini está ocupado (límite gratis). Probá en un minuto.',
            _ => 'Gemini no respondió. Probá de nuevo.',
          };
    } catch (_) {
      a = 'No me pude conectar con Gemini. Revisá internet y probá de nuevo.';
    }
    Cloud.instance.log('gemini_ask', levelId: widget.level.id, data: {
      'q': q,
      'a': a,
      'code': code,
      'n': _asked,
      'solution_open': sol != null,
    });
    if (!mounted) return;
    setState(() {
      _msgs.add((me: false, text: a));
      _busy = false;
    });
    _toBottom();
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut);
        }
      });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E1E2E),
      elevation: 12,
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Text('✨', style: TextStyle(fontSize: 24)),
              title: const Text('Gemini, tu tutor',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(_solutionOpen
                  ? 'Si seguís trabado, ya te puede mostrar la solución.'
                  : 'Te guía con preguntas. No te da la solución.'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                children: [
                  if (_msgs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                          'Contale qué no entendés o qué te sale mal. Gemini ya ve el problema y tu código.'),
                    ),
                  for (final m in _msgs) _bubble(m.me, m.text),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Escribí tu pregunta…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(bool me, String text) => Align(
        alignment: me ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: me ? const Color(0xFF3A5BA0) : const Color(0xFF2E2E42),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(text),
        ),
      );
}
