import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lets the page scroll with the keyboard (arrows, PageUp/PageDown,
/// Home/End, Space) even when nothing is focused — laptop players
/// without a mouse rely on it. Keys typed into a text field are left
/// alone, and only the top-most route reacts.
class KeyboardScroll extends StatefulWidget {
  const KeyboardScroll(
      {super.key, required this.controller, required this.child});

  final ScrollController controller;
  final Widget child;

  @override
  State<KeyboardScroll> createState() => _KeyboardScrollState();
}

class _KeyboardScrollState extends State<KeyboardScroll> {
  static const _step = 80.0;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _typing() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return false;
    return ctx.widget is EditableText ||
        ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _onKey(KeyEvent e) {
    if (e is KeyUpEvent || !mounted) return false;
    if (ModalRoute.of(context)?.isCurrent == false) return false;
    final c = widget.controller;
    if (!c.hasClients || _typing()) return false;
    final pos = c.position;
    final page = pos.viewportDimension * 0.85;
    final k = e.logicalKey;
    double? target;
    if (k == LogicalKeyboardKey.arrowDown) {
      target = pos.pixels + _step;
    } else if (k == LogicalKeyboardKey.arrowUp) {
      target = pos.pixels - _step;
    } else if (k == LogicalKeyboardKey.pageDown ||
        (k == LogicalKeyboardKey.space && e is KeyDownEvent)) {
      target = pos.pixels + page;
    } else if (k == LogicalKeyboardKey.pageUp) {
      target = pos.pixels - page;
    } else if (k == LogicalKeyboardKey.home && e is KeyDownEvent) {
      target = pos.minScrollExtent;
    } else if (k == LogicalKeyboardKey.end && e is KeyDownEvent) {
      target = pos.maxScrollExtent;
    }
    if (target == null) return false;
    c.animateTo(target.clamp(pos.minScrollExtent, pos.maxScrollExtent),
        duration: const Duration(milliseconds: 120), curve: Curves.easeOut);
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// App-wide scrolling: a fat, always-visible, draggable scrollbar on
/// vertical lists (easy to grab with a touchpad) and trackpad/mouse
/// drag support.
class CodeCatsScrollBehavior extends MaterialScrollBehavior {
  const CodeCatsScrollBehavior();

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    if (details.direction == AxisDirection.down ||
        details.direction == AxisDirection.up) {
      return Scrollbar(
        controller: details.controller,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        child: child,
      );
    }
    return super.buildScrollbar(context, child, details);
  }
}
