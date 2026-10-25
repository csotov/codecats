import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n.dart';
import '../services/progress.dart';
import '../data/complexity.dart';
import 'theme.dart';

/// Profe Miaurício Bigotes: the cat teacher who gives hints, explains
/// failed battles and runs the step-by-step tutorial.
class Professor {
  Professor._();

  static String get name => 'Profe Miaurício Bigotes';

  static String _metKey() =>
      'codecats_profe_met_${Progress.instance.active?.id ?? 'default'}';

  /// True the first time per profile; marks the professor as met.
  static Future<bool> firstMeeting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_metKey()) ?? false) return false;
      await prefs.setBool(_metKey(), true);
      return true;
    } catch (_) {
      return false;
    }
  }

  static List<String> introLines() {
    final l = L.instance;
    return [
      l.pick(
          '¡Miau! Soy el $name, doctor en Ciencias de la Computación '
              'y en siestas de 16 horas.',
          'Meow! I am $name, PhD in Computer Science and in 16-hour naps.'),
      l.pick(
          'Voy a ser tu profe. Cuando te trabes, te doy pistas por '
              '10 Miaudólares. ¡Los buenos consejos no son gratis, miau!',
          'I will be your teacher. When you get stuck, I sell hints for '
              '10 Meowdollars. Good advice is not free, meow!'),
      l.pick(
          'Y si fallás 3 veces, te muestro paso a paso qué hacer. '
              '¡Afilá las garras y a programar!',
          'And if you fail 3 times, I will show you step by step what to '
              'do. Sharpen your claws and let\'s code!'),
    ];
  }
}

/// Someone who talks through a [SpeechBubble].
class Speaker {
  const Speaker({
    required this.name,
    required this.label,
    required this.asset,
    required this.color,
    required this.border,
  });
  final String name;
  final String label;
  final String asset;
  final Color color;
  final Color border;

  static const profe = Speaker(
    name: 'Profe Miaurício Bigotes',
    label: 'Profe Miaurício',
    asset: 'assets/profe.png',
    color: AppTheme.accent2,
    border: AppTheme.accent,
  );

  static const boss = Speaker(
    name: 'Lord Zarpazo',
    label: 'Lord Zarpazo',
    asset: 'assets/boss.png',
    color: Color(0xFFFF4D4D),
    border: Color(0xFFFF4D4D),
  );
}

/// What the professor says when a Big O class first becomes relevant.
List<String> bigOLesson(BigO bo) => [
      L.instance.pick(
          '¡Momento de ciencia! Este nivel es ${bo.notation}, complejidad '
              '${bo.name}. Te explico qué significa.',
          'Science time! This level is ${bo.notation}, ${bo.name} '
              'complexity. Let me explain.'),
      ...bo.lines,
      L.instance.pick(
          'Vas a ver la nota "Big O" arriba de cada misión. Tocala cuando '
              'quieras que te lo repita.',
          'You will see the "Big O" note above every mission. Tap it any '
              'time you want me to repeat this.'),
    ];

/// The world boss: an angry cat who taunts you.
class Boss {
  Boss._();

  static List<String> introLines() => L.instance.isEs
      ? [
          '¡Jajaja! Así que vos sos el "héroe"... Soy Lord Zarpazo, el '
              'jefe de este mundo.',
          'No podrás vencerme. Este reto es muy difícil para vos, jajaja.',
          'Andá a jugar con tu profe de bigotes. Acá se viene la paliza.',
        ]
      : [
          'Hahaha! So you are the "hero"... I am Lord Zarpazo, the boss '
              'of this world.',
          'You cannot beat me. This challenge is way too hard for you, hahaha.',
          'Go play with your moustached teacher. A beating is coming.',
        ];

  static String failTaunt(int fails) {
    final es = [
      '¡Jajaja! ¿Eso es todo? Te lo dije: muy difícil para vos.',
      '¿Otra vez? Me estoy aburriendo de ganarte, jajaja.',
      'Mirá que insistís... pero este nivel es MÍO. ¡Jajaja!',
    ];
    final en = [
      'Hahaha! Is that all? I told you: way too hard for you.',
      'Again? I am getting bored of beating you, hahaha.',
      'You do keep trying... but this level is MINE. Hahaha!',
    ];
    final i = fails % es.length;
    return L.instance.pick(es[i], en[i]);
  }

  static String defeatLine() => L.instance.pick(
      '¡¿QUÉ?! ¡Imposible! ¡Me venciste! ...Esto no termina acá, miau.',
      'WHAT?! Impossible! You beat me! ...This is not over, meow.');

  static String replyLabel() => L.instance.pick('¡Vas a ver!', 'We\'ll see!');
}

/// The professor: Chemistry Cat with glasses and bow tie. Idle he
/// floats gently; while [talking] he hops and wiggles.
class ProfessorAvatar extends StatefulWidget {
  const ProfessorAvatar(
      {super.key,
      this.size = 72,
      this.talking = false,
      this.speaker = Speaker.profe});
  final double size;
  final bool talking;
  final Speaker speaker;

  @override
  State<ProfessorAvatar> createState() => _ProfessorAvatarState();
}

class _ProfessorAvatarState extends State<ProfessorAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat();

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(widget.speaker.asset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium);
    return AnimatedBuilder(
      animation: _t,
      child: img,
      builder: (_, child) {
        final v = _t.value * 2 * math.pi;
        final double dy;
        final double tilt;
        if (widget.talking) {
          dy = -(math.sin(v * 6).abs()) * widget.size * 0.06;
          tilt = math.sin(v * 3) * 0.05;
        } else {
          dy = math.sin(v) * widget.size * 0.02;
          tilt = 0;
        }
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(angle: tilt, child: child),
        );
      },
    );
  }
}

/// A comic speech bubble whose tail points left (at the speaker).
/// Text appears letter by letter; a tap shows it all at once.
class SpeechBubble extends StatefulWidget {
  const SpeechBubble({
    super.key,
    required this.text,
    this.typewriter = true,
    this.footer,
    this.onTyped,
    this.color = AppTheme.accent,
  });
  final String text;
  final bool typewriter;
  final Widget? footer;
  final VoidCallback? onTyped;
  final Color color;

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble> {
  Timer? _timer;
  int _shown = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(SpeechBubble old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) _start();
  }

  void _start() {
    _timer?.cancel();
    if (!widget.typewriter) {
      _shown = widget.text.length;
      return;
    }
    _shown = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 18), (t) {
      if (!mounted) return;
      setState(() => _shown = math.min(widget.text.length, _shown + 2));
      if (_shown >= widget.text.length) {
        t.cancel();
        widget.onTyped?.call();
      }
    });
  }

  void _finish() {
    if (_shown >= widget.text.length) return;
    _timer?.cancel();
    setState(() => _shown = widget.text.length);
    widget.onTyped?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _finish,
      child: CustomPaint(
        painter: _BubblePainter(widget.color),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  // Reserve the full height so the bubble does not grow.
                  Opacity(opacity: 0, child: Text(widget.text, style: _style)),
                  Text(widget.text.substring(0, _shown), style: _style),
                ],
              ),
              if (widget.footer != null) ...[
                const SizedBox(height: 8),
                widget.footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  static const _style = TextStyle(
      color: Color(0xFF241433),
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w600);
}

class _BubblePainter extends CustomPainter {
  _BubblePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const tail = 12.0;
    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(tail, 0, size.width - tail, size.height),
        const Radius.circular(16));
    final ty = math.min(30.0, size.height / 2);
    final path = Path()
      ..addRRect(body)
      ..moveTo(tail + 1, ty - 9)
      ..lineTo(0, ty + 4)
      ..lineTo(tail + 1, ty + 7)
      ..close();
    canvas.drawShadow(path, Colors.black, 4, false);
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFF6FF));
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.color != color;
}

/// Avatar + name + speech bubble, side by side.
class ProfessorSays extends StatefulWidget {
  const ProfessorSays({
    super.key,
    required this.text,
    this.footer,
    this.avatarSize = 64,
    this.typewriter = true,
    this.speaker = Speaker.profe,
  });
  final String text;
  final Widget? footer;
  final double avatarSize;
  final bool typewriter;
  final Speaker speaker;

  @override
  State<ProfessorSays> createState() => _ProfessorSaysState();
}

class _ProfessorSaysState extends State<ProfessorSays> {
  late bool _talking = widget.typewriter;

  @override
  void didUpdateWidget(ProfessorSays old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text && widget.typewriter) _talking = true;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: widget.speaker.name,
          child: Column(
            children: [
              ProfessorAvatar(
                  size: widget.avatarSize,
                  talking: _talking,
                  speaker: widget.speaker),
              SizedBox(
                width: widget.avatarSize + 16,
                child: Text(widget.speaker.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: widget.speaker.color)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SpeechBubble(
            text: widget.text,
            typewriter: widget.typewriter,
            footer: widget.footer,
            color: widget.speaker.border,
            onTyped: () {
              if (mounted) setState(() => _talking = false);
            },
          ),
        ),
      ],
    );
  }
}

/// Full-screen "conversation" with the professor, one line at a time,
/// like talking to a character in an RPG.
class ProfessorDialog {
  static Future<void> show(BuildContext context, List<String> lines,
      {Speaker speaker = Speaker.profe, String? lastLabel}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      pageBuilder: (_, __, ___) => _ConversationView(
          lines: lines, speaker: speaker, lastLabel: lastLabel),
    );
  }
}

class _ConversationView extends StatefulWidget {
  const _ConversationView(
      {required this.lines, required this.speaker, this.lastLabel});
  final List<String> lines;
  final Speaker speaker;
  final String? lastLabel;

  @override
  State<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<_ConversationView> {
  int _i = 0;

  void _next() {
    if (_i < widget.lines.length - 1) {
      setState(() => _i++);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final last = _i == widget.lines.length - 1;
    final boss = widget.speaker == Speaker.boss;
    return Material(
      // Own dim layer so the character always stands out, boss in red.
      color: (boss ? const Color(0xFF3A0008) : Colors.black)
          .withValues(alpha: 0.78),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.sizeOf(context).height * 0.22, 20, 20),
              child: ProfessorSays(
                key: ValueKey(_i),
                text: widget.lines[_i],
                avatarSize: 110,
                speaker: widget.speaker,
                footer: Row(
                  children: [
                    Text('${_i + 1}/${widget.lines.length}',
                        style: const TextStyle(
                            color: Color(0xFF7A6390), fontSize: 12)),
                    const Spacer(),
                    Tooltip(
                      message: l.t(last ? 'tip_profe_done' : 'tip_profe_next'),
                      child: FilledButton(
                        autofocus: true,
                        onPressed: _next,
                        child: Text(last
                            ? (widget.lastLabel ?? l.t('profe_go'))
                            : l.t('profe_next')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One step of the spotlight tutorial: highlight [target], explain it.
class TutorialStep {
  const TutorialStep(this.target, this.text);
  final GlobalKey target;
  final String text;
}

/// Game-style tutorial: everything is dimmed and blurred except the
/// widget that matters right now, while the professor explains it.
class SpotlightTutorial {
  static Future<void> show(BuildContext context, List<TutorialStep> steps) {
    final valid = steps.where((s) => s.target.currentContext != null).toList();
    if (valid.isEmpty) return Future.value();
    return Navigator.of(context).push(PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => _SpotlightView(steps: valid),
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: child),
    ));
  }
}

class _SpotlightView extends StatefulWidget {
  const _SpotlightView({required this.steps});
  final List<TutorialStep> steps;

  @override
  State<_SpotlightView> createState() => _SpotlightViewState();
}

class _SpotlightViewState extends State<_SpotlightView>
    with SingleTickerProviderStateMixin {
  int _i = 0;
  Rect? _hole;
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus());
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _focus() async {
    final ctx = widget.steps[_i].target.currentContext;
    if (ctx == null) return;
    setState(() => _hole = null);
    await Scrollable.ensureVisible(ctx,
        alignment: 0.2,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (!mounted || !ctx.mounted) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final r = box.localToGlobal(Offset.zero) & box.size;
    setState(() => _hole = r.inflate(6));
  }

  void _next() {
    if (_i < widget.steps.length - 1) {
      setState(() => _i++);
      _focus();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    final screen = MediaQuery.of(context).size;
    final hole = _hole;
    final last = _i == widget.steps.length - 1;
    final bubble = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: ProfessorSays(
        key: ValueKey(_i),
        text: widget.steps[_i].text,
        avatarSize: 76,
        footer: Row(
          children: [
            Text('${_i + 1}/${widget.steps.length}',
                style: const TextStyle(color: Color(0xFF7A6390), fontSize: 12)),
            const Spacer(),
            if (!last)
              Tooltip(
                message: l.t('tip_tutorial_skip'),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.t('tutorial_skip')),
                ),
              ),
            Tooltip(
              message: l.t(last ? 'tip_profe_done' : 'tip_profe_next'),
              child: FilledButton(
                autofocus: true,
                onPressed: _next,
                child: Text(l.t(last ? 'tutorial_done' : 'profe_next')),
              ),
            ),
          ],
        ),
      ),
    );

    // Put the professor where there is more room: below or above the hole.
    final below = hole == null || hole.center.dy < screen.height / 2;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: _InverseHole(hole),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withValues(alpha: 0.62)),
              ),
            ),
          ),
          if (hole != null)
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Positioned.fromRect(
                rect: hole.inflate(2 + _pulse.value * 4),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accent2, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.accent2.withValues(alpha: 0.5),
                            blurRadius: 18,
                            blurStyle: BlurStyle.outer),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            top: below
                ? math.min((hole?.bottom ?? screen.height * 0.3) + 14,
                    screen.height - 230)
                : null,
            bottom: below
                ? null
                : math.min(screen.height - hole.top + 14, screen.height - 230),
            child: Center(child: bubble),
          ),
        ],
      ),
    );
  }
}

class _InverseHole extends CustomClipper<Path> {
  _InverseHole(this.hole);
  final Rect? hole;

  @override
  Path getClip(Size size) {
    final p = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    if (hole != null) {
      p.addRRect(RRect.fromRectAndRadius(hole!, const Radius.circular(16)));
    }
    return p;
  }

  @override
  bool shouldReclip(_InverseHole old) => old.hole != hole;
}
