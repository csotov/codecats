import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/memory_drills.dart';
import '../l10n.dart';
import '../services/cloud.dart';
import '../services/progress.dart';
import 'keyboard_scroll.dart';
import 'olympiad_screens.dart';
import 'professor.dart';
import 'theme.dart';

const int kMemLessonSize = 8;

List<MemDeck> memDecksFor(Progress p) {
  final w = worldReached(p);
  return [
    for (final d in kMemDecks)
      if (d.minWorld <= w) d
  ];
}

String _crowns(int lv) => '${'👑' * lv}${'·' * (5 - lv)}';

class MemoryGymScreen extends StatefulWidget {
  const MemoryGymScreen({super.key});

  @override
  State<MemoryGymScreen> createState() => _MemoryGymScreenState();
}

class _MemoryGymScreenState extends State<MemoryGymScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _open(List<MemDeck> decks, String title) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => MemLessonScreen(decks: decks, title: title)));

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return Scaffold(
      appBar:
          AppBar(title: Text('⚡ ${l.pick('Memoria rápida', 'Quick recall')}')),
      body: AnimatedBuilder(
        animation: Progress.instance,
        builder: (context, _) {
          final p = Progress.instance;
          final decks = memDecksFor(p);
          final locked = kMemDecks.where((d) => !decks.contains(d));
          return KeyboardScroll(
            controller: _scroll,
            child: Scrollbar(
              controller: _scroll,
              thumbVisibility: true,
              thickness: 12,
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.all(14),
                children: [
                  Text(
                      l.pick(
                          'Elegí un tema. Son rompecabezas cortos: arrastrá las piezas a los casilleros.',
                          'Pick a topic. Short puzzles: drag the pieces into the slots.'),
                      style: const TextStyle(color: AppTheme.textLo)),
                  const SizedBox(height: 10),
                  for (final d in decks) _deckCard(d, p),
                  if (decks.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 6),
                      child: Tooltip(
                        message: l.pick(
                            'Una ronda con piezas de todos los temas',
                            'One round mixing every topic'),
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                          icon: const Icon(Icons.shuffle),
                          label:
                              Text(l.pick('Repaso mezclado', 'Mixed review')),
                          onPressed: () => _open(
                              decks, l.pick('Repaso mezclado', 'Mixed review')),
                        ),
                      ),
                    ),
                  for (final d in locked)
                    Card(
                      child: ListTile(
                        leading:
                            const Text('🔒', style: TextStyle(fontSize: 26)),
                        title: Text(l.pick(d.titleEs, d.titleEn),
                            style: const TextStyle(color: AppTheme.textLo)),
                        subtitle: Text(l.pick(
                            'Se abre en el mundo ${d.minWorld}',
                            'Opens at world ${d.minWorld}')),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _deckCard(MemDeck d, Progress p) {
    final l = L.instance;
    final lv = memLevel(p.memStats(d.id)[0]);
    return Card(
      child: Tooltip(
        message: l.pick('Jugar este tema', 'Play this topic'),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Text(d.emoji, style: const TextStyle(fontSize: 30)),
          title: Text(l.pick(d.titleEs, d.titleEn),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          subtitle: Text(_crowns(lv),
              style: const TextStyle(fontSize: 16, color: AppTheme.accent2)),
          trailing: const Icon(Icons.play_arrow_rounded, size: 36),
          onTap: () => _open([d], l.pick(d.titleEs, d.titleEn)),
        ),
      ),
    );
  }
}

class MemLessonScreen extends StatefulWidget {
  const MemLessonScreen({super.key, required this.decks, required this.title});
  final List<MemDeck> decks;
  final String title;

  @override
  State<MemLessonScreen> createState() => _MemLessonScreenState();
}

class _MemLessonScreenState extends State<MemLessonScreen> {
  final _rng = Random();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  final _queue = <(MemDeck, Puzzle)>[];

  /// Slot index (in reading order) -> tile index in the tray.
  final Map<int, int> _placed = {};
  int? _selectedTile;
  bool _intro = true;
  bool _solved = false;
  bool _wrongFlash = false;
  bool _showPrompt = false;
  int _shakeSeq = 0;
  int? _hoverTile;
  int _crownBefore = 0;
  int _misses = 0;
  int _done = 0, _firstTry = 0, _streak = 0, _best = 0, _seq = 0;
  int? _earned;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final es = L.instance.isEs;
    final seen = <String>{};
    var guard = 0;
    while (_queue.length < kMemLessonSize && guard++ < 300) {
      final d = widget.decks[_queue.length % widget.decks.length];
      final lv = memLevel(Progress.instance.memStats(d.id)[0]);
      final q = d.make(_rng, lv, es);
      if (seen.add(q.prompt + q.lines.toString())) _queue.add((d, q));
    }
    _queue.shuffle(_rng);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  MemDeck get _deck => _queue.first.$1;
  Puzzle get _puzzle => _queue.first.$2;

  /// Slot i (reading order) -> its group.
  List<int> get _slotGroups => [
        for (final l in _puzzle.lines)
          for (final p in l)
            if (p.isSlot) p.group
      ];

  void _place(int slot, int tile) {
    if (_solved || _wrongFlash) return;
    setState(() {
      _placed.removeWhere((s, t) => t == tile);
      _placed[slot] = tile;
      _selectedTile = null;
      _hoverTile = null;
    });
    if (_placed.length == _puzzle.slotCount) _check();
  }

  void _unplace(int slot) {
    if (_solved || _wrongFlash) return;
    setState(() => _placed.remove(slot));
  }

  bool _groupOk(int g) {
    final want = [..._puzzle.groups[g]!]..sort();
    final got = <String>[];
    final groups = _slotGroups;
    _placed.forEach((s, t) {
      if (groups[s] == g) got.add(_puzzle.tiles[t]);
    });
    got.sort();
    return want.length == got.length &&
        [for (var i = 0; i < want.length; i++) want[i] == got[i]]
            .every((x) => x);
  }

  void _check() {
    final ok = _puzzle.groups.keys.every(_groupOk);
    Cloud.instance
        .log('memory_gym', data: {'deck': _deck.id, 'ok': ok, 'miss': _misses});
    if (ok) {
      setState(() {
        _solved = true;
        if (_misses == 0) _firstTry++;
        _streak++;
        _best = max(_best, _streak);
      });
      _focus.requestFocus();
      return;
    }
    setState(() {
      _wrongFlash = true;
      _shakeSeq++;
      _misses++;
      _streak = 0;
    });
    _timer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _wrongFlash = false;
        final groups = _slotGroups;
        _placed.removeWhere((s, t) => !_groupOk(groups[s]));
      });
    });
  }

  void _next() {
    if (!_solved) return;
    setState(() {
      _queue.removeAt(0);
      _done++;
      _placed.clear();
      _solved = false;
      _misses = 0;
      _showPrompt = false;
      _seq++;
      if (_queue.isEmpty) _finish();
    });
    _focus.requestFocus();
  }

  void _finish() {
    _crownBefore =
        memLevel(Progress.instance.memStats(widget.decks.first.id)[0]);
    var earned = 0;
    for (final d in widget.decks) {
      // A mixed review counts as one lesson per deck; coins are paid once.
      final share = d == widget.decks.first ? _firstTry : 0;
      final total = d == widget.decks.first ? kMemLessonSize : 1;
      earned += Progress.instance.memLesson(d.id, share, total);
    }
    _earned = earned;
  }

  KeyEventResult _key(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space) {
      if (_intro) {
        setState(() => _intro = false);
        return KeyEventResult.handled;
      }
      if (_solved) {
        _next();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// Phone held sideways: short and wide. Board goes left, tray right.
  bool _landscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height && size.height < 560;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final land = _landscape(context);
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: land ? 40 : null, title: Text('⚡ ${widget.title}')),
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _key,
        child: KeyboardScroll(
          controller: _scroll,
          child: Scrollbar(
            controller: _scroll,
            thumbVisibility: true,
            thickness: 12,
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.all(land ? 8 : 14),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: land ? 1100 : 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_intro) ...[
                        Row(children: [
                          Expanded(child: _kibbleBar()),
                          const SizedBox(width: 10),
                          Text(
                              _streak >= 2
                                  ? '🧶 x$_streak'
                                  : '$_done/$kMemLessonSize',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                        ]),
                        SizedBox(height: land ? 6 : 14),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (c, a) => SlideTransition(
                          position: Tween(
                                  begin: const Offset(0.25, 0),
                                  end: Offset.zero)
                              .animate(a),
                          child: FadeTransition(opacity: a, child: c),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_intro
                              ? -2
                              : _earned != null
                                  ? -1
                                  : _seq),
                          child: _intro
                              ? _introCard(l)
                              : _earned != null
                                  ? _summary(l)
                                  : _board(l, land),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _introCard(L l) {
    final d = widget.decks.first;
    final mixed = widget.decks.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfessorSays(
          text: mixed
              ? l.pick(
                  'Repaso mezclado: piezas de todos los temas que ya abriste, revueltas como un ovillo. Mirá el tablero y probá por intuición: arrastrá cada pieza a su casillero, o tocá la pieza y después el casillero. Si te equivocás, las piezas vuelven y probás otra vez.',
                  'Mixed review: pieces from every topic you opened, tangled like a ball of yarn. Drag each piece into its slot, or tap the piece and then the slot. If you miss, the pieces come back and you try again.')
              : l.pick(d.introEs, d.introEn),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: Tooltip(
            message: l.pick('Empezar (Enter)', 'Start (Enter)'),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 22)),
              onPressed: () => setState(() => _intro = false),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l.pick('¡A jugar!', 'Play!'),
                  style: const TextStyle(fontSize: 17)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _board(L l, bool land) {
    if (!land) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _boardPanel(l),
          const SizedBox(height: 14),
          _tray(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _boardPanel(l)),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _tray()),
      ],
    );
  }

  Widget _tray() {
    final q = _puzzle;
    final used = _placed.values.toSet();
    if (_solved) return const SizedBox.shrink();
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      alignment: Alignment.topCenter,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < q.tiles.length; i++)
            if (!used.contains(i))
              _Pop(
                  key: ValueKey('t$i-$_shakeSeq'), child: _tile(i, _deck.code)),
        ],
      ),
    );
  }

  Widget _boardPanel(L l) {
    final d = _deck;
    final q = _puzzle;
    final groups = _slotGroups;
    var slotIdx = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${d.emoji} ${l.pick(d.titleEs, d.titleEn)}',
            style: const TextStyle(color: AppTheme.textLo)),
        const SizedBox(height: 6),
        if (_showPrompt || _misses >= 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(q.prompt,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: l.pick(
                  'Mostrar la consigna en palabras', 'Show the task in words'),
              child: TextButton.icon(
                onPressed: () => setState(() => _showPrompt = true),
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text(l.pick('¿Qué hay que hacer?', 'What do I do?')),
              ),
            ),
          ),
        const SizedBox(height: 6),
        _Shake(
          key: ValueKey(_shakeSeq),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _solved
                          ? AppTheme.good
                          : _wrongFlash
                              ? AppTheme.bad
                              : AppTheme.cardEdge,
                      width: 2),
                  boxShadow: _solved
                      ? [
                          BoxShadow(
                              color: AppTheme.good.withValues(alpha: 0.45),
                              blurRadius: 24,
                              spreadRadius: 2)
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in q.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 8,
                          children: [
                            for (final p in line)
                              if (p.isSlot)
                                _slot(slotIdx++, groups, d.code)
                              else
                                Text(p.text,
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontFamily: d.code ? 'monospace' : null,
                                        color: AppTheme.textHi)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (_wrongFlash)
                const Positioned.fill(child: IgnorePointer(child: _Scratch())),
              if (_solved)
                const Positioned(
                    right: 10, top: -14, child: IgnorePointer(child: _Paws())),
            ],
          ),
        ),
        if (!_solved && _misses >= 2) ...[
          const SizedBox(height: 10),
          Text('💡 ${q.why}',
              style: const TextStyle(
                  color: Color(0xFFFFC857), fontWeight: FontWeight.w700)),
        ],
        if (_solved) ...[
          ProfessorSays(
              text:
                  '${_misses == 0 ? l.pick('¡A la primera! ', 'First try! ') : ''}${q.why}',
              typewriter: false,
              avatarSize: 48),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Tooltip(
              message: l.pick('Siguiente (Enter)', 'Next (Enter)'),
              child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 22)),
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(l.pick('Seguir', 'Continue'),
                      style: const TextStyle(fontSize: 17))),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tileBox(String text, bool code,
      {Color? color, Color? edge, bool ghost = false, bool paw = true}) {
    final base = color ?? AppTheme.bgAlt;
    return Container(
      constraints: const BoxConstraints(minWidth: 56, minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              base.withValues(alpha: 0.95),
              base.withValues(alpha: 0.7)
            ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: edge ?? AppTheme.accent3, width: 2),
        boxShadow: ghost
            ? null
            : const [
                BoxShadow(
                    color: Colors.black38, offset: Offset(0, 3), blurRadius: 4)
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (paw)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Text('🐾', style: TextStyle(fontSize: 12)),
            ),
          Text(text,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: code ? 'monospace' : null,
                  color: AppTheme.textHi)),
        ],
      ),
    );
  }

  Widget _tile(int i, bool code) {
    final text = _puzzle.tiles[i];
    final selected = _selectedTile == i;
    final box = AnimatedScale(
      scale: _hoverTile == i || selected ? 1.08 : 1,
      duration: const Duration(milliseconds: 120),
      child: _tileBox(text, code,
          color: selected ? AppTheme.accent.withValues(alpha: 0.35) : null,
          edge: selected ? AppTheme.accent : null),
    );
    return Draggable<int>(
      data: i,
      feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(scale: 1.1, child: box)),
      childWhenDragging: Opacity(opacity: 0.3, child: box),
      onDragStarted: () => setState(() => _selectedTile = i),
      child: GestureDetector(
        onTap: () {
          if (selected) {
            setState(() => _selectedTile = null);
            return;
          }
          // Tapping a tile with exactly one empty slot left places it.
          final empty = [
            for (var s = 0; s < _puzzle.slotCount; s++)
              if (!_placed.containsKey(s)) s
          ];
          if (empty.length == 1) {
            _place(empty.first, i);
          } else {
            setState(() => _selectedTile = i);
          }
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hoverTile = i),
          onExit: (_) => setState(() => _hoverTile = null),
          child: Tooltip(
              message: L.instance.pick(
                  'Arrastrá o tocá para elegir', 'Drag, or tap to select'),
              child: box),
        ),
      ),
    );
  }

  Widget _slot(int s, List<int> groups, bool code) {
    final t = _placed[s];
    final okGroup = _solved || (_wrongFlash && _groupOk(groups[s]));
    final badGroup = _wrongFlash && !_groupOk(groups[s]);
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !_solved && !_wrongFlash,
      onAcceptWithDetails: (d) => _place(s, d.data),
      builder: (context, cand, _) {
        final hover = cand.isNotEmpty;
        if (t != null) {
          return GestureDetector(
            onTap: () => _unplace(s),
            child: Tooltip(
              message: L.instance
                  .pick('Tocá para sacar la pieza', 'Tap to remove the piece'),
              child: _Pop(
                key: ValueKey('p$s-$t'),
                child: _tileBox(_puzzle.tiles[t], code,
                    paw: false,
                    color: okGroup
                        ? AppTheme.good.withValues(alpha: 0.3)
                        : badGroup
                            ? AppTheme.bad.withValues(alpha: 0.3)
                            : AppTheme.accent3.withValues(alpha: 0.18),
                    edge: okGroup
                        ? AppTheme.good
                        : badGroup
                            ? AppTheme.bad
                            : AppTheme.accent3),
              ),
            ),
          );
        }
        return GestureDetector(
          onTap: () {
            final sel = _selectedTile;
            if (sel != null) _place(s, sel);
          },
          child: Tooltip(
            message:
                L.instance.pick('Soltá una pieza acá', 'Drop a piece here'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 76,
              height: 52,
              decoration: BoxDecoration(
                color: hover || _selectedTile != null
                    ? AppTheme.accent.withValues(alpha: 0.25)
                    : AppTheme.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: hover ? AppTheme.accent : AppTheme.textLo,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside),
              ),
              child: const Center(
                  child: Text('?',
                      style: TextStyle(
                          fontSize: 20,
                          color: AppTheme.textLo,
                          fontWeight: FontWeight.w800))),
            ),
          ),
        );
      },
    );
  }

  /// Progress as a row of kibble: one piece per solved puzzle.
  Widget _kibbleBar() {
    return Row(
      children: [
        for (var i = 0; i < kMemLessonSize; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _Pop(
                key: ValueKey('k$i-${i < _done}'),
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: i < _done ? _kibbleGradient : null,
                    color: i < _done ? null : AppTheme.cardEdge,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _summary(L l) {
    final perfect = _firstTry == kMemLessonSize;
    final crownNow =
        memLevel(Progress.instance.memStats(widget.decks.first.id)[0]);
    final newCrown = crownNow > _crownBefore && widget.decks.length == 1;
    final earned = _earned ?? 0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2600),
      builder: (context, t, _) {
        // Stages: cat jumps in, kibble falls one by one, paws + crown,
        // then the professor speaks.
        double stage(double a, double b) => ((t - a) / (b - a)).clamp(0, 1);
        final cat = Curves.elasticOut.transform(stage(0, 0.25));
        final kibbleShown = (stage(0.2, 0.7) * earned).floor();
        final paws = stage(0.7, 0.9);
        final talk = stage(0.9, 1);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Transform.scale(
                scale: cat,
                child: Text(perfect ? '😺' : '🐱',
                    style: const TextStyle(fontSize: 72)),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                  perfect
                      ? l.pick('¡Ronda perfecta!', 'Perfect round!')
                      : l.pick('¡Ronda terminada!', 'Round done!'),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < earned; i++)
                  i < kibbleShown
                      ? _Pop(
                          key: ValueKey('c$i'),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _kibbleGradient),
                          ),
                        )
                      : const SizedBox(width: 22, height: 22),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                  '+$kibbleShown Miaudólares${perfect && kibbleShown == earned ? l.pick(' (incluye +5 por perfecta)', ' (includes +5 for perfect)') : ''}',
                  style: const TextStyle(
                      fontSize: 18,
                      color: AppTheme.accent2,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            Center(
              child: Opacity(
                opacity: paws,
                child: Text(
                    '${l.pick('A la primera', 'First try')}: $_firstTry/$kMemLessonSize   ·   🧶 ${l.pick('mejor racha', 'best streak')} $_best',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            if (newCrown)
              Center(
                child: Transform.scale(
                  scale: Curves.elasticOut.transform(paws),
                  child: Text(
                      '👑 ${l.pick('¡Corona nueva!', 'New crown!')} ${_crowns(crownNow)}',
                      style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFFFFC857),
                          fontWeight: FontWeight.w900)),
                ),
              ),
            const SizedBox(height: 14),
            Opacity(
              opacity: talk,
              child: ProfessorSays(
                typewriter: false,
                avatarSize: 48,
                text: perfect
                    ? l.pick(
                        'Eso ya lo tenés en la cabeza, como un gato que sabe exactamente dónde está la lata de atún.',
                        'That is in your head now, like a cat that knows exactly where the tuna can is.')
                    : l.pick(
                        'Lo que no salió a la primera, salió al segundo intento: así es como se queda en la memoria.',
                        'What did not come out first try came out on the second: that is how it sticks.'),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Tooltip(
                message: l.pick(
                    'Volver a la lista de temas', 'Back to the topic list'),
                child: FilledButton(
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 22)),
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.pick('Listo', 'Done'),
                        style: const TextStyle(fontSize: 17))),
              ),
            ),
          ],
        );
      },
    );
  }
}

const _kibbleGradient = LinearGradient(colors: [
  Color(0xFFE0A050),
  Color(0xFF9A5A1E),
]);

/// Scale-in pop, used when a tile lands, returns to the tray or kibble fills.
class _Pop extends StatelessWidget {
  const _Pop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.6, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.elasticOut,
        builder: (_, v, c) => Transform.scale(scale: v, child: c),
        child: child,
      );
}

/// Horizontal shake, replayed whenever the key changes.
class _Shake extends StatelessWidget {
  const _Shake({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (_, t, c) => Transform.translate(
            offset: Offset(sin(t * pi * 5) * 10 * (1 - t), 0), child: c),
        child: child,
      );
}

/// Claw marks (three slanted red strokes) that fade out.
class _Scratch extends StatelessWidget {
  const _Scratch();

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeIn,
        builder: (_, v, c) => Opacity(opacity: v, child: c),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [for (var k = 0; k < 2; k++) _claws()],
        ),
      );

  static Widget _claws() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Transform.rotate(
                angle: -0.45,
                child: Container(
                  width: 5,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3E3),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.bad.withValues(alpha: 0.9),
                          blurRadius: 8,
                          spreadRadius: 2)
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
}

/// Paw prints walking in one after another when a puzzle is solved.
class _Paws extends StatelessWidget {
  const _Paws();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 4; i++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 350 + i * 220),
              curve: Interval(i / 4, 1, curve: Curves.easeOutBack),
              builder: (_, v, c) => Opacity(
                  opacity: v.clamp(0, 1),
                  child: Transform.translate(
                      offset: Offset(0, (1 - v) * 10), child: c)),
              child: Padding(
                padding: EdgeInsets.only(right: 4, top: i.isEven ? 0 : 8),
                child: const Text('🐾', style: TextStyle(fontSize: 22)),
              ),
            ),
        ],
      );
}
