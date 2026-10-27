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
  });

  final String initial;
  final ValueChanged<String> onChanged;
  final double minHeight;

  @override
  State<CodeEditor> createState() => CodeEditorState();
}

class CodeEditorState extends State<CodeEditor> {
  late final CodeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CodeController(
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
    return Container(
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
    );
  }
}
