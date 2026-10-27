import 'package:flutter/material.dart';

import 'sound_panel.dart';

import '../data/coach_problems.dart';
import '../l10n.dart';
import 'keyboard_scroll.dart';
import 'theme.dart';
import 'widgets.dart';

/// Admin: upload and edit coach problems.
class CoachAdminScreen extends StatefulWidget {
  const CoachAdminScreen({super.key});

  @override
  State<CoachAdminScreen> createState() => _CoachAdminScreenState();
}

class _CoachAdminScreenState extends State<CoachAdminScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    CoachStore.instance.load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar: AppBar(
          actions: const [MusicButton()],
          title: Text(l.pick('Subir problemas', 'Upload problems'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(null),
        icon: const Icon(Icons.add),
        label: Text(l.pick('Nuevo problema', 'New problem')),
      ),
      body: AnimatedBuilder(
        animation: CoachStore.instance,
        builder: (context, _) => KeyboardScroll(
          controller: _scroll,
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
            children: [
              Text(
                  l.pick(
                      'Dos tipos: (1) problema propio con casos ocultos, que se juzga en el juego; (2) link de Codeforces: tu hijo lo envía en Codeforces y el juego verifica el Accepted con la API pública.',
                      'Two kinds: (1) own problem with hidden tests, judged in the game; (2) Codeforces link: your child submits on Codeforces and the game verifies the Accepted through the public API.'),
                  style: const TextStyle(color: AppTheme.textLo, fontSize: 13)),
              const SizedBox(height: 12),
              for (final p in CoachStore.instance.problems)
                Card(
                  child: ListTile(
                    title: Text(p.title),
                    subtitle: Text(p.isCodeforces
                        ? 'Codeforces ${p.cfContest}${p.cfIndex}'
                        : '${p.samples.length} ${l.pick('ejemplos', 'samples')} · ${p.tests.length} ${l.pick('casos ocultos', 'hidden tests')}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                          tooltip: l.pick('Editar', 'Edit'),
                          onPressed: () => _edit(p),
                          icon: const Icon(Icons.edit_outlined)),
                      IconButton(
                          tooltip: l.pick('Borrar', 'Delete'),
                          onPressed: () => _delete(p),
                          icon: const Icon(Icons.delete_outline)),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(CoachProblem p) async {
    final l = L.instance;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l.pick('¿Borrar "${p.title}"?', 'Delete "${p.title}"?')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l.t('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(l.t('confirm'))),
        ],
      ),
    );
    if (ok == true) await CoachStore.instance.delete(p.id);
  }

  Future<void> _edit(CoachProblem? p) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => _CoachProblemForm(existing: p)));
  }
}

class _CoachProblemForm extends StatefulWidget {
  const _CoachProblemForm({this.existing});
  final CoachProblem? existing;

  @override
  State<_CoachProblemForm> createState() => _CoachProblemFormState();
}

class _CoachProblemFormState extends State<_CoachProblemForm> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _topic = TextEditingController(text: widget.existing?.topic);
  late final _cf = TextEditingController(
      text:
          widget.existing?.isCodeforces == true ? widget.existing!.cfUrl : '');
  late final _statement =
      TextEditingController(text: widget.existing?.statement);
  late final _input = TextEditingController(text: widget.existing?.inputDesc);
  late final _output = TextEditingController(text: widget.existing?.outputDesc);
  late final _samples = TextEditingController(
      text: formatTests(widget.existing?.samples ?? const []));
  late final _tests = TextEditingController(
      text: formatTests(widget.existing?.tests ?? const []));
  late final _hints =
      TextEditingController(text: (widget.existing?.hints ?? []).join('\n'));
  late final _xp = TextEditingController(text: '${widget.existing?.xp ?? 150}');
  final _scroll = ScrollController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [
      _title,
      _topic,
      _cf,
      _statement,
      _input,
      _output,
      _samples,
      _tests,
      _hints,
      _xp
    ]) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  Widget _field(TextEditingController c, String label,
          {int lines = 1, String? help, bool mono = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          minLines: lines,
          maxLines: lines == 1 ? 1 : 30,
          style: mono ? const TextStyle(fontFamily: 'monospace') : null,
          decoration: InputDecoration(
              labelText: label,
              helperText: help,
              helperMaxLines: 3,
              border: const OutlineInputBorder()),
        ),
      );

  Future<void> _save() async {
    final l = L.instance;
    final cf = _cf.text.trim().isEmpty ? null : parseCodeforcesUrl(_cf.text);
    if (_title.text.trim().isEmpty) {
      setState(() => _error = l.pick('Falta el título.', 'Title missing.'));
      return;
    }
    if (_cf.text.trim().isNotEmpty && cf == null) {
      setState(() => _error = l.pick('No reconozco ese link de Codeforces.',
          'I do not recognise that Codeforces link.'));
      return;
    }
    final samples = parseTests(_samples.text);
    if (cf == null && samples.isEmpty) {
      setState(() => _error = l.pick(
          'Un problema propio necesita al menos un ejemplo (entrada, línea ===, salida).',
          'An own problem needs at least one sample (input, a === line, output).'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await CoachStore.instance.save(
        CoachProblem(
          id: widget.existing?.id ?? '',
          title: _title.text.trim(),
          topic: _topic.text.trim(),
          statement: _statement.text.trim(),
          inputDesc: _input.text.trim(),
          outputDesc: _output.text.trim(),
          samples: samples,
          tests: parseTests(_tests.text),
          hints: [
            for (final h in _hints.text.split('\n'))
              if (h.trim().isNotEmpty) h.trim(),
          ],
          xp: int.tryParse(_xp.text.trim()) ?? 150,
          cfContest: cf?.$1,
          cfIndex: cf?.$2,
        ),
        isNew: widget.existing == null,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    const testsHelp =
        'Formato: entrada, una línea ===, salida. Separá cada caso con una línea ---';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null
            ? l.pick('Nuevo problema', 'New problem')
            : l.pick('Editar problema', 'Edit problem')),
        actions: [
          const MusicButton(),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(l.pick('Guardar', 'Save'))),
          ),
        ],
      ),
      body: KeyboardScroll(
        controller: _scroll,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(14),
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:
                    Text(_error!, style: const TextStyle(color: AppTheme.bad)),
              ),
            _field(_title, l.pick('Título', 'Title')),
            _field(_topic, l.pick('Tema (opcional)', 'Topic (optional)'),
                help: l.pick('Ej.: bucles, arreglos, búsqueda binaria',
                    'E.g. loops, arrays, binary search')),
            _field(_xp, 'XP'),
            SectionCard(
              title: l.pick(
                  'Opción A: link de Codeforces', 'Option A: Codeforces link'),
              child: _field(
                  _cf, 'https://codeforces.com/problemset/problem/4/A',
                  help: l.pick(
                      'Si ponés un link, lo demás es opcional: el enunciado y el juez son los de Codeforces.',
                      'With a link the rest is optional: statement and judge are Codeforces\'.')),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title:
                  l.pick('Opción B: problema propio', 'Option B: own problem'),
              child: Column(children: [
                _field(_statement, l.pick('Enunciado', 'Statement'), lines: 5),
                _field(_input, l.pick('Entrada', 'Input'), lines: 2),
                _field(_output, l.pick('Salida', 'Output'), lines: 2),
                _field(_samples,
                    l.pick('Ejemplos (visibles)', 'Samples (visible)'),
                    lines: 5, help: testsHelp, mono: true),
                _field(_tests, l.pick('Casos ocultos', 'Hidden tests'),
                    lines: 6, help: testsHelp, mono: true),
                _field(_hints,
                    l.pick('Pistas (una por línea)', 'Hints (one per line)'),
                    lines: 3),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
