import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:highlight/languages/cpp.dart';

import 'theme.dart';

/// C++ code editor with syntax highlighting.
class CodeEditor extends StatefulWidget {
  const CodeEditor({
    super.key,
    required this.initial,
    required this.onChanged,
    this.minHeight = 220,
    this.geany = false,
  });

  final String initial;
  final ValueChanged<String> onChanged;
  final double minHeight;

  /// Light Geany look: white page, gray line numbers, default Geany colors.
  final bool geany;

  @override
  State<CodeEditor> createState() => CodeEditorState();
}

/// Highlighting re-parses the whole program on every rebuild of the
/// field (selection, focus, any parent setState); reuse the last spans
/// while the text is unchanged.
class _CachedCodeController extends CodeController {
  _CachedCodeController({super.text, super.language});

  String? _lastText;
  CodeThemeData? _lastTheme;
  TextStyle? _lastStyle;
  TextSpan? _lastSpan;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final theme = CodeTheme.of(context);
    if (_lastSpan != null &&
        _lastText == text &&
        identical(_lastTheme, theme) &&
        _lastStyle == style) {
      return _lastSpan!;
    }
    _lastText = text;
    _lastTheme = theme;
    _lastStyle = style;
    return _lastSpan = super.buildTextSpan(
        context: context, style: style, withComposing: withComposing);
  }
}

class CodeEditorState extends State<CodeEditor> {
  late final CodeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _CachedCodeController(
      text: widget.initial,
      language: cpp,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get code => _controller.text;

  void setCode(String text) {
    _controller.text = text;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.geany) {
      return RepaintBoundary(
        child: Container(
          constraints: BoxConstraints(minHeight: widget.minHeight),
          color: Colors.white,
          child: CodeTheme(
            data: const CodeThemeData(styles: _geanyTheme),
            child: CodeField(
              controller: _controller,
              background: Colors.white,
              cursorColor: Colors.black,
              textStyle: const TextStyle(
                  fontFamily: 'monospace', fontSize: 13, height: 1.35),
              lineNumberStyle: const LineNumberStyle(
                  width: 38,
                  margin: 6,
                  background: Color(0xFFE6E6E6),
                  textStyle: TextStyle(
                      color: Colors.black, fontSize: 12, height: 1.35)),
              expands: false,
              wrap: false,
              onChanged: widget.onChanged,
            ),
          ),
        ),
      );
    }
    return RepaintBoundary(
        child: Container(
      constraints: BoxConstraints(minHeight: widget.minHeight),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardEdge),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: CodeTheme(
        data: const CodeThemeData(styles: atomOneDarkTheme),
        child: CodeField(
          controller: _controller,
          textStyle: const TextStyle(
              fontFamily: 'monospace', fontSize: 13, height: 1.45),
          expands: false,
          wrap: false,
          onChanged: widget.onChanged,
        ),
      ),
    ));
  }
}

/// Geany 1.38 default colors for C/C++ (filetypes.common / filetypes.c).
const _geanyTheme = {
  'root': TextStyle(color: Colors.black, backgroundColor: Colors.white),
  'keyword': TextStyle(color: Color(0xFF00007F), fontWeight: FontWeight.bold),
  'built_in': TextStyle(color: Color(0xFF00007F), fontWeight: FontWeight.bold),
  'type': TextStyle(color: Color(0xFF00007F), fontWeight: FontWeight.bold),
  'literal': TextStyle(color: Color(0xFF007F00)),
  'number': TextStyle(color: Color(0xFF007F00)),
  'string': TextStyle(color: Color(0xFFFF901E)),
  'comment': TextStyle(color: Color(0xFFD00000)),
  'meta': TextStyle(color: Color(0xFF007F7F)),
  'meta-string': TextStyle(color: Color(0xFFFF901E)),
  'meta-keyword': TextStyle(color: Color(0xFF007F7F)),
  'title': TextStyle(color: Colors.black),
};
