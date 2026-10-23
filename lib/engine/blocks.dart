/// Visual block engine: a tree of [BlockNode]s generates real C++ code.
///
/// The generated program is always a complete `int main()` so kids see
/// real, compilable code from day one.
library;

/// One editable parameter inside a block.
class BlockParam {
  const BlockParam(this.key, this.labelEs, this.labelEn,
      {this.hint = '', this.defaultValue = ''});
  final String key;
  final String labelEs, labelEn;
  final String hint;
  final String defaultValue;
}

/// Definition of a palette block.
class BlockDef {
  const BlockDef({
    required this.id,
    required this.category,
    required this.labelEs,
    required this.labelEn,
    this.params = const [],
    this.hasBody = false,
    this.hasElse = false,
    required this.emit,
    this.elseHead = '} else {',
    this.bodyFoot = '}',
  });

  final String id;

  /// 'io' | 'var' | 'ctrl' | 'array' | 'misc'
  final String category;
  final String labelEs, labelEn;
  final List<BlockParam> params;

  /// Whether the block wraps a child list (`{ ... }`).
  final bool hasBody;

  /// Whether it has a second child list (`else { ... }`).
  final bool hasElse;

  /// Produces the block's own line(s) (before children).
  final String Function(Map<String, String> p) emit;
  final String elseHead;
  final String bodyFoot;
}

/// An instance of a block in the player's program.
class BlockNode {
  BlockNode(this.defId,
      {Map<String, String>? params,
      List<BlockNode>? children,
      List<BlockNode>? elseChildren})
      : params = params ?? {},
        children = children ?? [],
        elseChildren = elseChildren ?? [];

  String defId;
  final Map<String, String> params;
  final List<BlockNode> children;
  final List<BlockNode> elseChildren;

  BlockNode clone() => BlockNode(defId,
      params: Map.of(params),
      children: children.map((c) => c.clone()).toList(),
      elseChildren: elseChildren.map((c) => c.clone()).toList());

  Map<String, dynamic> toJson() => {
        'd': defId,
        'p': params,
        if (children.isNotEmpty) 'c': children.map((c) => c.toJson()).toList(),
        if (elseChildren.isNotEmpty)
          'e': elseChildren.map((c) => c.toJson()).toList(),
      };

  factory BlockNode.fromJson(Map<String, dynamic> j) => BlockNode(
        j['d'] as String,
        params: (j['p'] as Map?)?.map((k, v) => MapEntry('$k', '$v')) ?? {},
        children: ((j['c'] as List?) ?? [])
            .map((c) => BlockNode.fromJson(Map<String, dynamic>.from(c)))
            .toList(),
        elseChildren: ((j['e'] as List?) ?? [])
            .map((c) => BlockNode.fromJson(Map<String, dynamic>.from(c)))
            .toList(),
      );
}

/// Registry of every block definition.
final Map<String, BlockDef> kBlockDefs = {
  for (final d in _defs) d.id: d,
};

String _p(Map<String, String> p, String k, [String fallback = '']) {
  final v = p[k]?.trim() ?? '';
  return v.isEmpty ? fallback : v;
}

final List<BlockDef> _defs = [
  // ---- I/O ------------------------------------------------------------
  BlockDef(
    id: 'print_text',
    category: 'io',
    labelEs: 'Imprimir texto',
    labelEn: 'Print text',
    params: [BlockParam('text', 'texto', 'text', hint: 'Hola')],
    emit: (p) => 'cout << "${_p(p, 'text', '')}" << endl;',
  ),
  BlockDef(
    id: 'print_expr',
    category: 'io',
    labelEs: 'Imprimir expresión',
    labelEn: 'Print expression',
    params: [BlockParam('expr', 'expresión', 'expression', hint: 'a + b')],
    emit: (p) => 'cout << ${_p(p, 'expr', '0')} << endl;',
  ),
  BlockDef(
    id: 'print_inline',
    category: 'io',
    labelEs: 'Imprimir sin salto',
    labelEn: 'Print (no newline)',
    params: [BlockParam('expr', 'expresión', 'expression', hint: 'x')],
    emit: (p) => 'cout << ${_p(p, 'expr', '0')};',
  ),
  BlockDef(
    id: 'print_space',
    category: 'io',
    labelEs: 'Imprimir espacio',
    labelEn: 'Print space',
    emit: (p) => 'cout << " ";',
  ),
  BlockDef(
    id: 'read_var',
    category: 'io',
    labelEs: 'Leer variable',
    labelEn: 'Read variable',
    params: [BlockParam('var', 'variable', 'variable', hint: 'x')],
    emit: (p) => 'cin >> ${_p(p, 'var', 'x')};',
  ),
  // ---- Variables -------------------------------------------------------
  BlockDef(
    id: 'decl_int',
    category: 'var',
    labelEs: 'Variable entera',
    labelEn: 'Integer variable',
    params: [
      BlockParam('name', 'nombre', 'name', hint: 'x'),
      BlockParam('init', 'valor inicial (opcional)',
          'initial value (optional)', hint: '0'),
    ],
    emit: (p) {
      final init = _p(p, 'init');
      return init.isEmpty
          ? 'int ${_p(p, 'name', 'x')};'
          : 'int ${_p(p, 'name', 'x')} = $init;';
    },
  ),
  BlockDef(
    id: 'decl_ll',
    category: 'var',
    labelEs: 'Entero grande (long long)',
    labelEn: 'Big integer (long long)',
    params: [
      BlockParam('name', 'nombre', 'name', hint: 'x'),
      BlockParam('init', 'valor inicial (opcional)',
          'initial value (optional)', hint: '0'),
    ],
    emit: (p) {
      final init = _p(p, 'init');
      return init.isEmpty
          ? 'long long ${_p(p, 'name', 'x')};'
          : 'long long ${_p(p, 'name', 'x')} = $init;';
    },
  ),
  BlockDef(
    id: 'decl_double',
    category: 'var',
    labelEs: 'Número decimal',
    labelEn: 'Decimal number',
    params: [
      BlockParam('name', 'nombre', 'name', hint: 'x'),
      BlockParam('init', 'valor inicial (opcional)',
          'initial value (optional)', hint: '0'),
    ],
    emit: (p) {
      final init = _p(p, 'init');
      return init.isEmpty
          ? 'double ${_p(p, 'name', 'x')};'
          : 'double ${_p(p, 'name', 'x')} = $init;';
    },
  ),
  BlockDef(
    id: 'decl_bool',
    category: 'var',
    labelEs: 'Variable booleana',
    labelEn: 'Boolean variable',
    params: [
      BlockParam('name', 'nombre', 'name', hint: 'ok'),
      BlockParam('init', 'valor inicial (opcional)',
          'initial value (optional)', hint: 'false'),
    ],
    emit: (p) {
      final init = _p(p, 'init');
      return init.isEmpty
          ? 'bool ${_p(p, 'name', 'ok')};'
          : 'bool ${_p(p, 'name', 'ok')} = $init;';
    },
  ),
  BlockDef(
    id: 'assign',
    category: 'var',
    labelEs: 'Asignar',
    labelEn: 'Assign',
    params: [
      BlockParam('name', 'variable', 'variable', hint: 'x'),
      BlockParam('expr', 'valor', 'value', hint: 'a + b'),
    ],
    emit: (p) => '${_p(p, 'name', 'x')} = ${_p(p, 'expr', '0')};',
  ),
  BlockDef(
    id: 'add_assign',
    category: 'var',
    labelEs: 'Sumar a variable',
    labelEn: 'Add to variable',
    params: [
      BlockParam('name', 'variable', 'variable', hint: 'suma'),
      BlockParam('expr', 'cantidad', 'amount', hint: 'x'),
    ],
    emit: (p) => '${_p(p, 'name', 'x')} += ${_p(p, 'expr', '1')};',
  ),
  BlockDef(
    id: 'increment',
    category: 'var',
    labelEs: 'Incrementar en 1',
    labelEn: 'Increment by 1',
    params: [BlockParam('name', 'variable', 'variable', hint: 'i')],
    emit: (p) => '${_p(p, 'name', 'i')}++;',
  ),
  BlockDef(
    id: 'decrement',
    category: 'var',
    labelEs: 'Decrementar en 1',
    labelEn: 'Decrement by 1',
    params: [BlockParam('name', 'variable', 'variable', hint: 'i')],
    emit: (p) => '${_p(p, 'name', 'i')}--;',
  ),
  // ---- Control ----------------------------------------------------------
  BlockDef(
    id: 'if_block',
    category: 'ctrl',
    labelEs: 'Si (if)',
    labelEn: 'If',
    params: [BlockParam('cond', 'condición', 'condition', hint: 'x > 0')],
    hasBody: true,
    emit: (p) => 'if (${_p(p, 'cond', 'true')}) {',
  ),
  BlockDef(
    id: 'if_else',
    category: 'ctrl',
    labelEs: 'Si / Si no (if/else)',
    labelEn: 'If / Else',
    params: [BlockParam('cond', 'condición', 'condition', hint: 'x > 0')],
    hasBody: true,
    hasElse: true,
    emit: (p) => 'if (${_p(p, 'cond', 'true')}) {',
  ),
  BlockDef(
    id: 'for_i',
    category: 'ctrl',
    labelEs: 'Repetir (for)',
    labelEn: 'Repeat (for)',
    params: [
      BlockParam('var', 'variable', 'variable', hint: 'i', defaultValue: 'i'),
      BlockParam('start', 'desde', 'from', hint: '0', defaultValue: '0'),
      BlockParam('end', 'hasta (sin incluir)', 'to (excluded)',
          hint: 'n', defaultValue: 'n'),
    ],
    hasBody: true,
    emit: (p) =>
        'for (int ${_p(p, 'var', 'i')} = ${_p(p, 'start', '0')}; '
        '${_p(p, 'var', 'i')} < ${_p(p, 'end', 'n')}; ${_p(p, 'var', 'i')}++) {',
  ),
  BlockDef(
    id: 'for_down',
    category: 'ctrl',
    labelEs: 'Repetir hacia atrás (for--)',
    labelEn: 'Repeat backwards (for--)',
    params: [
      BlockParam('var', 'variable', 'variable', hint: 'i', defaultValue: 'i'),
      BlockParam('start', 'desde', 'from', hint: 'n - 1', defaultValue: 'n - 1'),
      BlockParam('end', 'mientras >=', 'while >=', hint: '0', defaultValue: '0'),
    ],
    hasBody: true,
    emit: (p) =>
        'for (int ${_p(p, 'var', 'i')} = ${_p(p, 'start', 'n - 1')}; '
        '${_p(p, 'var', 'i')} >= ${_p(p, 'end', '0')}; ${_p(p, 'var', 'i')}--) {',
  ),
  BlockDef(
    id: 'while_block',
    category: 'ctrl',
    labelEs: 'Mientras (while)',
    labelEn: 'While',
    params: [BlockParam('cond', 'condición', 'condition', hint: 'x > 0')],
    hasBody: true,
    emit: (p) => 'while (${_p(p, 'cond', 'true')}) {',
  ),
  BlockDef(
    id: 'break_stmt',
    category: 'ctrl',
    labelEs: 'Salir del bucle (break)',
    labelEn: 'Exit loop (break)',
    emit: (p) => 'break;',
  ),
  BlockDef(
    id: 'continue_stmt',
    category: 'ctrl',
    labelEs: 'Saltar iteración (continue)',
    labelEn: 'Skip iteration (continue)',
    emit: (p) => 'continue;',
  ),
  // ---- Arrays & C-strings ------------------------------------------------
  BlockDef(
    id: 'decl_array',
    category: 'array',
    labelEs: 'Arreglo de enteros',
    labelEn: 'Integer array',
    params: [
      BlockParam('name', 'nombre', 'name', hint: 'a'),
      BlockParam('size', 'tamaño', 'size', hint: '105'),
    ],
    emit: (p) => 'int ${_p(p, 'name', 'a')}[${_p(p, 'size', '105')}];',
  ),
  BlockDef(
    id: 'decl_str',
    category: 'array',
    labelEs: 'Cadena de texto (char[])',
    labelEn: 'Text string (char[])',
    params: [
      BlockParam('name', 'nombre', 'name', hint: 's'),
      BlockParam('size', 'tamaño', 'size', hint: '105'),
    ],
    emit: (p) => 'char ${_p(p, 'name', 's')}[${_p(p, 'size', '105')}];',
  ),
  BlockDef(
    id: 'read_array',
    category: 'array',
    labelEs: 'Leer n elementos al arreglo',
    labelEn: 'Read n items into array',
    params: [
      BlockParam('name', 'arreglo', 'array', hint: 'a'),
      BlockParam('n', 'cantidad', 'count', hint: 'n'),
    ],
    emit: (p) =>
        'for (int _i = 0; _i < ${_p(p, 'n', 'n')}; _i++) '
        'cin >> ${_p(p, 'name', 'a')}[_i];',
  ),
  BlockDef(
    id: 'print_array',
    category: 'array',
    labelEs: 'Imprimir arreglo separado',
    labelEn: 'Print array separated',
    params: [
      BlockParam('name', 'arreglo', 'array', hint: 'a'),
      BlockParam('n', 'cantidad', 'count', hint: 'n'),
    ],
    emit: (p) =>
        'for (int _i = 0; _i < ${_p(p, 'n', 'n')}; _i++) { '
        'if (_i) cout << " "; cout << ${_p(p, 'name', 'a')}[_i]; } '
        'cout << endl;',
  ),
  BlockDef(
    id: 'set_elem',
    category: 'array',
    labelEs: 'Poner elemento del arreglo',
    labelEn: 'Set array element',
    params: [
      BlockParam('name', 'arreglo', 'array', hint: 'a'),
      BlockParam('idx', 'índice', 'index', hint: 'i'),
      BlockParam('expr', 'valor', 'value', hint: 'x'),
    ],
    emit: (p) =>
        '${_p(p, 'name', 'a')}[${_p(p, 'idx', '0')}] = ${_p(p, 'expr', '0')};',
  ),
  BlockDef(
    id: 'swap_vars',
    category: 'array',
    labelEs: 'Intercambiar dos variables',
    labelEn: 'Swap two variables',
    params: [
      BlockParam('a', 'variable A', 'variable A', hint: 'a[i]'),
      BlockParam('b', 'variable B', 'variable B', hint: 'a[j]'),
    ],
    emit: (p) =>
        '{ int _t = ${_p(p, 'a', 'x')}; ${_p(p, 'a', 'x')} = '
        '${_p(p, 'b', 'y')}; ${_p(p, 'b', 'y')} = _t; }',
  ),
  // ---- Misc ---------------------------------------------------------------
  BlockDef(
    id: 'return0',
    category: 'misc',
    labelEs: 'Terminar programa',
    labelEn: 'End program',
    emit: (p) => 'return 0;',
  ),
  BlockDef(
    id: 'raw_line',
    category: 'misc',
    labelEs: 'Línea de código libre',
    labelEn: 'Free code line',
    params: [BlockParam('code', 'código', 'code', hint: 'suma = a + b;')],
    emit: (p) => _p(p, 'code', ';'),
  ),
];

/// Serialize a forest of blocks to JSON (for persistence).
List<Map<String, dynamic>> blocksToJson(List<BlockNode> roots) =>
    roots.map((n) => n.toJson()).toList();

List<BlockNode> blocksFromJson(List<dynamic>? j) => (j ?? [])
    .map((n) => BlockNode.fromJson(Map<String, dynamic>.from(n as Map)))
    .toList();

/// Generate a complete C++ program from the block forest.
String blocksToCode(List<BlockNode> roots) {
  final b = StringBuffer()
    // NOTE: do NOT include both <cmath> and <cstdlib> — JSCPP registers
    // abs(int) twice and the program fails to compile.
    ..writeln('#include <iostream>')
    ..writeln('#include <cstring>')
    ..writeln('#include <cmath>')
    ..writeln('using namespace std;')
    ..writeln('int main() {');
  _emitNodes(roots, 1, b);
  b
    ..writeln('    return 0;')
    ..writeln('}');
  return b.toString();
}

void _emitNodes(List<BlockNode> nodes, int depth, StringBuffer b) {
  final pad = '    ' * depth;
  for (final n in nodes) {
    final def = kBlockDefs[n.defId];
    if (def == null) continue;
    for (final line in def.emit(n.params).split('\n')) {
      b.writeln('$pad$line');
    }
    if (def.hasBody) {
      _emitNodes(n.children, depth + 1, b);
      if (def.hasElse) {
        b.writeln('$pad${def.elseHead}');
        _emitNodes(n.elseChildren, depth + 1, b);
      }
      b.writeln('$pad${def.bodyFoot}');
    }
  }
}
