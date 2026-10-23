/// Direct block interpreter: executes the block tree without generating
/// or compiling C++. Used in block/hybrid mode so early levels produce
/// output instantly and can never hit syntax errors.
///
/// The generated C++ is still shown for learning; this VM only affects
/// what "Run" and "Fight" do while the player stays in the block editor.
library;

import 'blocks.dart';
import 'runner.dart';

/// Runs a block forest directly against stdin tokens.
class BlocksRunner implements CppRunner {
  BlocksRunner(List<BlockNode> roots) : _roots = roots.map((n) => n.clone()).toList();
  final List<BlockNode> _roots;

  @override
  Future<RunOutput> run(
    String code, // ignored: we execute the blocks, not the text
    String input, {
    int maxOps = 200000,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final vm = _Vm(_roots, input, maxSteps: maxOps);
    try {
      vm.execAll();
      return RunOutput(ok: true, exitCode: 0, output: vm.out.toString());
    } on _VmError catch (e) {
      return RunOutput(
          ok: false, error: RunError.runtime, detail: e.message, output: vm.out.toString());
    } on _StepsExceeded {
      return RunOutput(ok: false, error: RunError.tle, output: vm.out.toString());
    }
  }

  @override
  void dispose() {}
}

// ---------------------------------------------------------------------------
// Errors & control flow signals
// ---------------------------------------------------------------------------
class _VmError implements Exception {
  _VmError(this.message);
  final String message;
  @override
  String toString() => message;
}

class _StepsExceeded implements Exception {}
class _BreakSignal implements Exception {}
class _ContinueSignal implements Exception {}
class _ReturnSignal implements Exception {}

// ---------------------------------------------------------------------------
// The virtual machine
// ---------------------------------------------------------------------------
class _Vm {
  _Vm(this.roots, String input, {required this.maxSteps})
      : _tokens = input.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  final List<BlockNode> roots;
  final int maxSteps;
  final List<String> _tokens;
  int _ti = 0;
  int _steps = 0;
  final out = StringBuffer();
  final Map<String, Object?> _vars = {};

  // -- main loop ------------------------------------------------------------
  void execAll() {
    try {
      for (final n in roots) {
        _exec(n);
      }
    } on _ReturnSignal {
      // `return 0;` ends the program
    }
  }

  void _tick() {
    if (++_steps > maxSteps) throw _StepsExceeded();
  }

  void _execList(List<BlockNode> nodes) {
    for (final n in nodes) {
      _exec(n);
    }
  }

  String _param(BlockNode n, String k, [String fb = '']) {
    final v = n.params[k]?.trim() ?? '';
    return v.isEmpty ? fb : v;
  }

  /// "a, b" → ['a','b'] — comma-separated identifiers in one param.
  List<String> _names(String raw) => raw
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  void _exec(BlockNode n) {
    _tick();
    switch (n.defId) {
      // ---- io -------------------------------------------------------------
      case 'print_text':
        out.writeln(_param(n, 'text'));
      case 'print_expr':
        out.writeln(_strVal(_eval(_param(n, 'expr', '0'))));
      case 'print_inline':
        out.write(_strVal(_eval(_param(n, 'expr', '0'))));
      case 'print_space':
        out.write(' ');
      case 'read_var':
        // "a, b" reads a token into each variable (cin >> a >> b)
        for (final v in _names(_param(n, 'var', 'x'))) {
          _assign(v, null, _readToken());
        }
      // ---- vars -----------------------------------------------------------
      case 'decl_int':
      case 'decl_ll':
        final init = _eval(_param(n, 'init', '0'));
        for (final v in _names(_param(n, 'name', 'x'))) {
          _vars[v] = init;
        }
      case 'decl_double':
        final init = _eval(_param(n, 'init', '0'));
        for (final v in _names(_param(n, 'name', 'x'))) {
          _vars[v] = init;
        }
      case 'decl_bool':
        final init = _eval(_param(n, 'init', 'false'));
        for (final v in _names(_param(n, 'name', 'ok'))) {
          _vars[v] = init;
        }
      case 'assign':
        _assign(_param(n, 'name', 'x'), null, _eval(_param(n, 'expr', '0')));
      case 'add_assign':
        final name = _param(n, 'name', 'suma');
        _vars[name] = _toNum(_vars[name]) + _toNum(_eval(_param(n, 'expr', '1')));
      case 'increment':
        final name = _param(n, 'name', 'i');
        _vars[name] = _toNum(_vars[name]) + 1;
      case 'decrement':
        final name = _param(n, 'name', 'i');
        _vars[name] = _toNum(_vars[name]) - 1;
      // ---- control --------------------------------------------------------
      case 'if_block':
      case 'if_else':
        if (_truthy(_eval(_param(n, 'cond', 'true')))) {
          _execList(n.children);
        } else {
          _execList(n.elseChildren);
        }
      case 'for_i':
        final v = _param(n, 'var', 'i');
        final had = _vars.containsKey(v);
        final saved = _vars[v];
        try {
          final end = () => _toNum(_eval(_param(n, 'end', 'n')));
          for (_vars[v] = _toNum(_eval(_param(n, 'start', '0')));
              _toNum(_vars[v]) < end();
              _vars[v] = _toNum(_vars[v]) + 1) {
            _tick();
            try {
              _execList(n.children);
            } on _ContinueSignal {
              // next iteration
            }
          }
        } on _BreakSignal {
          // exit loop
        } finally {
          if (had) {
            _vars[v] = saved;
          } else {
            _vars.remove(v);
          }
        }
      case 'for_down':
        final v = _param(n, 'var', 'i');
        final had = _vars.containsKey(v);
        final saved = _vars[v];
        try {
          final end = () => _toNum(_eval(_param(n, 'end', '0')));
          for (_vars[v] = _toNum(_eval(_param(n, 'start', 'n - 1')));
              _toNum(_vars[v]) >= end();
              _vars[v] = _toNum(_vars[v]) - 1) {
            _tick();
            try {
              _execList(n.children);
            } on _ContinueSignal {}
          }
        } on _BreakSignal {
        } finally {
          if (had) {
            _vars[v] = saved;
          } else {
            _vars.remove(v);
          }
        }
      case 'while_block':
        try {
          while (_truthy(_eval(_param(n, 'cond', 'false')))) {
            _tick();
            try {
              _execList(n.children);
            } on _ContinueSignal {}
          }
        } on _BreakSignal {}
      case 'break_stmt':
        throw _BreakSignal();
      case 'continue_stmt':
        throw _ContinueSignal();
      // ---- arrays ---------------------------------------------------------
      case 'decl_array':
        final size = _toNum(_eval(_param(n, 'size', '105')));
        _vars[_param(n, 'name', 'a')] = List<int>.filled(size < 0 ? 0 : size, 0);
      case 'decl_str':
        _vars[_param(n, 'name', 's')] = '';
      case 'read_array':
        final arr = _arr(_param(n, 'name', 'a'));
        final cnt = _toNum(_eval(_param(n, 'n', 'n')));
        for (var i = 0; i < cnt && i < arr.length; i++) {
          _tick();
          arr[i] = _toNum(_readToken());
        }
      case 'print_array':
        final arr = _arr(_param(n, 'name', 'a'));
        final cnt = _toNum(_eval(_param(n, 'n', 'n')));
        for (var i = 0; i < cnt && i < arr.length; i++) {
          if (i > 0) out.write(' ');
          out.write(arr[i]);
        }
        out.writeln();
      case 'set_elem':
        _assign(_param(n, 'name', 'a'), _param(n, 'idx', '0'),
            _eval(_param(n, 'expr', '0')));
      case 'swap_vars':
        _swap(_param(n, 'a', 'x'), _param(n, 'b', 'y'));
      // ---- misc -----------------------------------------------------------
      case 'return0':
        throw _ReturnSignal();
      case 'raw_line':
        _execRaw(_param(n, 'code', ';'));
      default:
        throw _VmError('bloque desconocido: ${n.defId}');
    }
  }

  // -- small raw-line executor (tolerant mini statements) -------------------
  void _execRaw(String code) {
    var c = code.trim();
    if (c.endsWith(';')) c = c.substring(0, c.length - 1).trim();
    if (c.isEmpty) return;
    if (c.startsWith('cout')) {
      // cout << a << " " << b << endl;
      final parts = c.substring(4).split('<<');
      for (var part in parts) {
        part = part.trim();
        if (part.isEmpty) continue;
        if (part == 'endl') {
          out.writeln();
        } else {
          out.write(_strVal(_eval(part)));
        }
      }
      return;
    }
    if (c.startsWith('cin')) {
      for (var part in c.substring(3).split('>>')) {
        // "cin >> a, b" is also natural kid syntax
        for (var v in part.split(',')) {
          v = v.trim();
          if (v.isNotEmpty) _assign(v, null, _readToken());
        }
      }
      return;
    }
    if (c.startsWith('return')) throw _ReturnSignal();
    if (c == 'break') throw _BreakSignal();
    if (c == 'continue') throw _ContinueSignal();
    // int/long long/bool/double/char declarations
    final decl =
        RegExp(r'^(int|long long|bool|double|char)\s+(.+)$').firstMatch(c);
    if (decl != null) {
      for (var item in decl.group(2)!.split(',')) {
        item = item.trim();
        final eq = item.indexOf('=');
        if (eq >= 0) {
          final name = item.substring(0, eq).trim();
          _vars[_stripIdx(name).$1] = _eval(item.substring(eq + 1));
        } else if (item.isNotEmpty) {
          _vars[item] = 0;
        }
      }
      return;
    }
    // compound assign / increment
    final ca = RegExp(r'^(.+?)(\+=|-=|\*=|/=|%=|\+\+|--)(.*)$').firstMatch(c);
    if (ca != null) {
      final lhs = ca.group(1)!.trim();
      final op = ca.group(2)!;
      final rhs = ca.group(3)!.trim();
      switch (op) {
        case '++':
          _assignLhs(lhs, _toNum(_readLhs(lhs)) + 1);
        case '--':
          _assignLhs(lhs, _toNum(_readLhs(lhs)) - 1);
        case '+=':
          _assignLhs(lhs, _toNum(_readLhs(lhs)) + _toNum(_eval(rhs)));
        case '-=':
          _assignLhs(lhs, _toNum(_readLhs(lhs)) - _toNum(_eval(rhs)));
        case '*=':
          _assignLhs(lhs, _toNum(_readLhs(lhs)) * _toNum(_eval(rhs)));
        case '/=':
          _assignLhs(lhs, _cdiv(_toNum(_readLhs(lhs)), _toNum(_eval(rhs))));
        case '%=':
          _assignLhs(lhs, _cmod(_toNum(_readLhs(lhs)), _toNum(_eval(rhs))));
      }
      return;
    }
    final eq = c.indexOf('=');
    if (eq > 0 && c[eq + 1] != '=' && c[eq - 1] != '=' && c[eq - 1] != '!' &&
        c[eq - 1] != '<' && c[eq - 1] != '>') {
      _assignLhs(c.substring(0, eq).trim(), _eval(c.substring(eq + 1)));
      return;
    }
    _eval(c); // expression statement
  }

  // -- lvalues --------------------------------------------------------------
  (String, int?) _stripIdx(String lhs) {
    final m = RegExp(r'^(.*?)\[(.*)\]\s*$').firstMatch(lhs.trim());
    if (m == null) return (lhs.trim(), null);
    return (m.group(1)!.trim(), _toNum(_eval(m.group(2)!)));
  }

  void _assign(String name, String? idxExpr, Object? v) {
    if (idxExpr != null) {
      _assignLhs('$name[$idxExpr]', v);
    } else {
      _assignLhs(name, v);
    }
  }

  Object? _readLhs(String lhs) {
    final (name, idx) = _stripIdx(lhs);
    if (idx == null) return _vars[name] ?? 0;
    final arr = _arr(name);
    return idx >= 0 && idx < arr.length ? arr[idx] : 0;
  }

  void _assignLhs(String lhs, Object? v) {
    final (name, idx) = _stripIdx(lhs);
    if (idx == null) {
      _vars[name] = v is num ? v : _toNum(v);
      return;
    }
    final arr = _arr(name);
    if (idx < 0 || idx >= arr.length) {
      throw _VmError('índice fuera del arreglo: $name[$idx]');
    }
    arr[idx] = _toNum(v);
  }

  void _swap(String a, String b) {
    final t = _readLhs(a);
    _assignLhs(a, _readLhs(b));
    _assignLhs(b, t);
  }

  List<int> _arr(String name) {
    final v = _vars[name];
    if (v is List<int>) return v;
    throw _VmError('$name no es un arreglo de enteros');
  }

  Object? _readToken() {
    if (_ti >= _tokens.length) return 0; // C++ cin leaves 0-ish; keep going
    final t = _tokens[_ti++];
    final i = int.tryParse(t);
    return i ?? t;
  }

  // -- coercion -------------------------------------------------------------
  int _toNum(Object? v) {
    if (v is int) return v;
    if (v is bool) return v ? 1 : 0;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  bool _truthy(Object? v) {
    if (v is bool) return v;
    return _toNum(v) != 0;
  }

  String _strVal(Object? v) => v is bool ? (v ? '1' : '0') : '$v';

  // -- expression parser -----------------------------------------------------
  _Parser _p(String src) => _Parser(src, this);

  Object? _eval(String src) {
    final s = src.trim();
    if (s.isEmpty) return 0;
    try {
      return _p(s).expr();
    } catch (e) {
      if (e is _VmError || e is _StepsExceeded) rethrow;
      throw _VmError('expresión inválida: "$s"');
    }
  }

  Object? resolve(String name) => _vars[name] ?? 0;

  Object? resolveIndex(String name, int idx) {
    final v = _vars[name];
    if (v is List<int>) {
      return idx >= 0 && idx < v.length ? v[idx] : 0;
    }
    if (v is String) {
      return idx >= 0 && idx < v.length ? v.codeUnitAt(idx) : 0;
    }
    return 0;
  }

  int strLen(String name) {
    final v = _vars[name];
    if (v is String) return v.length;
    if (v is List) return v.length;
    return 0;
  }

  int get stepBudget => maxSteps;
  void tick() => _tick();
  int cdiv(int a, int b) => _cdiv(a, b);
  int cmod(int a, int b) => _cmod(a, b);
}

// C++ semantics helpers (int division truncates toward zero).
int _cdiv(int a, int b) {
  if (b == 0) throw _VmError('división entre cero');
  return (a / b).truncate();
}

int _cmod(int a, int b) {
  if (b == 0) throw _VmError('módulo entre cero');
  return a - _cdiv(a, b) * b;
}

// ---------------------------------------------------------------------------
// Tiny C-expression parser
// ---------------------------------------------------------------------------
class _Parser {
  _Parser(this.src, this.vm);
  final String src;
  final _Vm vm;
  int _i = 0;

  String _peek() {
    _skip();
    return _i >= src.length ? '' : src[_i];
  }

  void _skip() {
    while (_i < src.length && src[_i] == ' ') {
      _i++;
    }
  }

  bool _eat(String tok) {
    _skip();
    if (src.startsWith(tok, _i)) {
      // don't eat '!' of '!=', '=' of '==', '<' of '<=' etc.
      _i += tok.length;
      return true;
    }
    return false;
  }

  void _expect(String tok) {
    if (!_eat(tok)) throw _VmError('se esperaba "$tok" en "$src"');
  }

  Object? expr() => _or();

  Object? _or() {
    var l = _and();
    while (true) {
      _skip();
      if (src.startsWith('||', _i)) {
        _i += 2;
        final r = _and();
        l = (vm._truthy(l) || vm._truthy(r));
      } else {
        return l;
      }
    }
  }

  Object? _and() {
    var l = _eq();
    while (true) {
      _skip();
      if (src.startsWith('&&', _i)) {
        _i += 2;
        final r = _eq();
        l = (vm._truthy(l) && vm._truthy(r));
      } else {
        return l;
      }
    }
  }

  Object? _eq() {
    var l = _rel();
    while (true) {
      _skip();
      if (src.startsWith('==', _i)) {
        _i += 2;
        l = vm._toNum(l) == vm._toNum(_rel());
      } else if (src.startsWith('!=', _i)) {
        _i += 2;
        l = vm._toNum(l) != vm._toNum(_rel());
      } else {
        return l;
      }
    }
  }

  Object? _rel() {
    var l = _add();
    while (true) {
      _skip();
      if (src.startsWith('<=', _i)) {
        _i += 2;
        l = vm._toNum(l) <= vm._toNum(_add());
      } else if (src.startsWith('>=', _i)) {
        _i += 2;
        l = vm._toNum(l) >= vm._toNum(_add());
      } else if (_peek() == '<') {
        _i++;
        l = vm._toNum(l) < vm._toNum(_add());
      } else if (_peek() == '>') {
        _i++;
        l = vm._toNum(l) > vm._toNum(_add());
      } else {
        return l;
      }
    }
  }

  Object? _add() {
    var l = _mul();
    while (true) {
      final c = _peek();
      if (c == '+') {
        _i++;
        l = vm._toNum(l) + vm._toNum(_mul());
      } else if (c == '-') {
        _i++;
        l = vm._toNum(l) - vm._toNum(_mul());
      } else {
        return l;
      }
    }
  }

  Object? _mul() {
    var l = _unary();
    while (true) {
      final c = _peek();
      if (c == '*') {
        _i++;
        l = vm._toNum(l) * vm._toNum(_unary());
      } else if (c == '/') {
        _i++;
        l = vm.cdiv(vm._toNum(l), vm._toNum(_unary()));
      } else if (c == '%') {
        _i++;
        l = vm.cmod(vm._toNum(l), vm._toNum(_unary()));
      } else {
        return l;
      }
    }
  }

  Object? _unary() {
    final c = _peek();
    if (c == '-') {
      _i++;
      return -vm._toNum(_unary());
    }
    if (c == '!') {
      _i++;
      return !vm._truthy(_unary());
    }
    if (c == '+') {
      _i++;
      return _unary();
    }
    return _primary();
  }

  Object? _primary() {
    _skip();
    var c = _peek();
    if (c == '(') {
      _i++;
      final v = expr();
      _expect(')');
      return v;
    }
    if (c == '"') {
      _i++;
      final b = StringBuffer();
      while (_i < src.length && src[_i] != '"') {
        if (src[_i] == '\\' && _i + 1 < src.length) {
          _i++;
          b.write(src[_i] == 'n' ? '\n' : src[_i]);
        } else {
          b.write(src[_i]);
        }
        _i++;
      }
      _i++; // closing quote
      return b.toString();
    }
    if (c == "'") {
      _i++;
      var ch = 0;
      if (_i < src.length) {
        if (src[_i] == '\\' && _i + 1 < src.length) {
          _i++;
          ch = src[_i] == 'n' ? 10 : src.codeUnitAt(_i);
        } else {
          ch = src.codeUnitAt(_i);
        }
        _i++;
      }
      if (_i < src.length && src[_i] == "'") _i++;
      return ch;
    }
    if (c.isNotEmpty && RegExp(r'[0-9]').hasMatch(c)) {
      final m = RegExp(r'\d+').matchAsPrefix(src, _i)!;
      _i = m.end;
      return int.parse(m.group(0)!);
    }
    if (c.isNotEmpty && RegExp(r'[A-Za-z_]').hasMatch(c)) {
      final m = RegExp(r'[A-Za-z_]\w*').matchAsPrefix(src, _i)!;
      final name = m.group(0)!;
      _i = m.end;
      // function call?
      if (_peek() == '(') {
        _i++;
        final args = <Object?>[];
        if (_peek() != ')') {
          args.add(expr());
          while (_eat(',')) {
            args.add(expr());
          }
        }
        _expect(')');
        return _call(name, args);
      }
      if (_peek() == '[') {
        _i++;
        final idx = vm._toNum(expr());
        _expect(']');
        return vm.resolveIndex(name, idx);
      }
      return switch (name) {
        'true' => true,
        'false' => false,
        _ => vm.resolve(name),
      };
    }
    throw _VmError('expresión inválida en "$src" (posición $_i)');
  }

  Object? _call(String name, List<Object?> args) {
    switch (name) {
      case 'strlen':
        final v = args.isEmpty ? '' : args.first;
        return v is String ? v.length : 0;
      case 'abs':
        return args.isEmpty ? 0 : vm._toNum(args.first).abs();
      case 'min':
        return args.length < 2
            ? 0
            : (vm._toNum(args[0]) < vm._toNum(args[1])
                ? vm._toNum(args[0])
                : vm._toNum(args[1]));
      case 'max':
        return args.length < 2
            ? 0
            : (vm._toNum(args[0]) > vm._toNum(args[1])
                ? vm._toNum(args[0])
                : vm._toNum(args[1]));
    }
    throw _VmError('función no soportada en bloques: $name()');
  }
}
