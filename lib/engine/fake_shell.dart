/// A tiny Ubuntu-like bash for the OBI exam tutorial: a home folder with
/// Descargas/, the task zip after "downloading" it, and the few commands
/// needed on exam day (pwd, ls, cd, unzip, cat, geany, g++, ./program).
class ShellResult {
  ShellResult(this.lines,
      {this.tag = '', this.input, this.exe, this.ok = true});
  final List<String> lines;

  /// What happened, for the tutorial and reports: pwd, ls, cd, unzip, cat,
  /// edit, compile, run, run_sample, error, hint, clear.
  final String tag;

  /// For `run`: the stdin to feed (null means "type it by hand").
  final String? input;

  /// For `compile`: the program name given with -o.
  final String? exe;
  final bool ok;
}

class FakeShell {
  FakeShell(
      {required this.task,
      required this.zip,
      required this.code,
      this.user = 'obi'});

  /// Task file name, e.g. `multiplos`.
  final String task;

  /// Zip contents by path inside the zip (`cpp/grader.cpp`, ...).
  final Map<String, String> zip;

  /// Current text of the player's `<task>.cpp` (edited in Geany).
  final String Function() code;
  final String user;

  String get home => '/home/$user';
  late String cwd = home;
  late final Set<String> dirs = {
    '/',
    '/home',
    home,
    '$home/Descargas',
    '$home/Documentos',
    '$home/Escritorio'
  };
  final files = <String, String>{};

  String get zipName => '$task.zip';
  bool get downloaded => files.containsKey('$home/Descargas/$zipName');
  bool get unzipped => files.keys.any((k) => k.endsWith('/cpp/grader.cpp'));

  /// The unzipped cpp/ folder (where he should compile).
  String? get cppDir {
    for (final k in files.keys) {
      if (k.endsWith('/cpp/grader.cpp')) return k.substring(0, k.length - 11);
    }
    return null;
  }

  void download() => files['$home/Descargas/$zipName'] = '(zip)';

  String _short(String p) => p == home
      ? '~'
      : p.startsWith('$home/')
          ? '~/${p.substring(home.length + 1)}'
          : p;

  String get prompt => '$user@ubuntu:${_short(cwd)}\$';

  String resolve(String p) {
    if (p.isEmpty || p == '~') return home;
    var parts = <String>[];
    var rest = p;
    if (p.startsWith('~/')) {
      parts = home.substring(1).split('/');
      rest = p.substring(2);
    } else if (!p.startsWith('/')) {
      parts = cwd == '/' ? [] : cwd.substring(1).split('/');
    }
    for (final s in rest.split('/')) {
      if (s.isEmpty || s == '.') continue;
      if (s == '..') {
        if (parts.isNotEmpty) parts.removeLast();
      } else {
        parts.add(s);
      }
    }
    return '/${parts.join('/')}';
  }

  String? read(String path) =>
      path == '${cppDir ?? '\u0000'}/$task.cpp' ? code() : files[path];

  bool isDir(String p) => dirs.contains(p);

  List<String> list(String dir) {
    final pre = dir == '/' ? '/' : '$dir/';
    final out = <String>{};
    for (final d in dirs) {
      if (d != dir &&
          d.startsWith(pre) &&
          !d.substring(pre.length).contains('/')) {
        out.add('${d.substring(pre.length)}/');
      }
    }
    for (final f in files.keys) {
      if (f.startsWith(pre) && !f.substring(pre.length).contains('/')) {
        out.add(f.substring(pre.length));
      }
    }
    return out.toList()..sort();
  }

  void addFile(String path, String text) {
    var d = path.substring(0, path.lastIndexOf('/'));
    while (d.isNotEmpty && dirs.add(d)) {
      d = d.substring(0, d.lastIndexOf('/'));
    }
    files[path] = text;
  }

  String _noSuch(String cmd, String a) =>
      '$cmd: $a: No existe el archivo o el directorio';

  ShellResult run(String line) {
    final l = line.trim();
    if (l.isEmpty) return ShellResult(const [], tag: 'empty');
    var input = '';
    var cmdPart = l;
    final lt = l.indexOf('<');
    if (lt >= 0) {
      cmdPart = l.substring(0, lt).trim();
      input = l.substring(lt + 1).trim();
    }
    final a = cmdPart.split(RegExp(r'\s+'));
    final cmd = a.first;
    final args = a.skip(1).toList();
    switch (cmd) {
      case 'pwd':
        return ShellResult([cwd], tag: 'pwd');
      case 'ls':
      case 'dir' when false:
        final target = args.where((x) => !x.startsWith('-')).firstOrNull;
        final p = resolve(target ?? '.');
        if (files.containsKey(p)) return ShellResult([target!], tag: 'ls');
        if (!isDir(p)) {
          return ShellResult([
            'ls: no se puede acceder a \'$target\': No existe el archivo o el directorio'
          ], tag: 'error', ok: false);
        }
        final items = list(p);
        return ShellResult([items.isEmpty ? '' : items.join('   ')], tag: 'ls');
      case 'cd':
        final p = resolve(args.isEmpty ? '~' : args.first);
        if (!isDir(p)) {
          return ShellResult([
            files.containsKey(p)
                ? 'bash: cd: ${args.first}: No es un directorio'
                : 'bash: ${_noSuch('cd', args.first)}'
          ], tag: 'error', ok: false);
        }
        cwd = p;
        return ShellResult(const [], tag: 'cd');
      case 'clear':
        return ShellResult(const [], tag: 'clear');
      case 'cat':
        if (args.isEmpty) return ShellResult(const [], tag: 'cat');
        final p = resolve(args.first);
        final s = read(p);
        if (s == null || s == '(zip)') {
          return ShellResult([
            s == '(zip)'
                ? 'cat: ${args.first}: es un zip, primero unzip'
                : _noSuch('cat', args.first)
          ], tag: 'error', ok: false);
        }
        return ShellResult(s.trimRight().split('\n'), tag: 'cat');
      case 'unzip':
        final name = args.where((x) => !x.startsWith('-')).firstOrNull;
        if (name == null) {
          return ShellResult(['Uso: unzip archivo.zip -d carpeta'],
              tag: 'error', ok: false);
        }
        final di = args.indexOf('-d');
        final src = resolve(name);
        if (files[src] != '(zip)') {
          return ShellResult([
            'unzip:  cannot find or open $name.',
            '(¿Estás en la carpeta correcta? Probá ls para ver qué hay acá.)'
          ], tag: 'error', ok: false);
        }
        final dest =
            di >= 0 && di + 1 < args.length ? resolve(args[di + 1]) : cwd;
        final out = ['Archive:  $name'];
        dirs.add(dest);
        for (final e in zip.entries) {
          addFile('$dest/${e.key}', e.value);
          out.add(
              '  inflating: ${_short('$dest/${e.key}').replaceFirst('${_short(cwd)}/', '')}');
        }
        return ShellResult(out, tag: 'unzip');
      case 'geany':
      case 'code':
      case 'codeblocks':
      case 'gedit':
      case 'nano':
        if (args.isEmpty) {
          return ShellResult(['Decile qué archivo abrir: $cmd $task.cpp'],
              tag: 'hint', ok: false);
        }
        final p = resolve(args.first);
        if (p.endsWith('/grader.cpp') || p.endsWith('/$task.h')) {
          return ShellResult(
              ['🐱 Profe: ese archivo no se toca. Tu código va en $task.cpp.'],
              tag: 'hint', ok: false);
        }
        if (read(p) == null) {
          return ShellResult([
            _noSuch(cmd, args.first),
            '(Primero andá con cd a la carpeta cpp, donde está $task.cpp.)'
          ], tag: 'error', ok: false);
        }
        return ShellResult(const [], tag: 'edit');
      case 'g++':
        final hasGrader = args.contains('grader.cpp');
        final hasMine = args.contains('$task.cpp');
        final oi = args.indexOf('-o');
        final exe = oi >= 0 && oi + 1 < args.length ? args[oi + 1] : 'a.out';
        if (!files.containsKey('$cwd/grader.cpp')) {
          return ShellResult([
            'g++: error: grader.cpp: No existe el archivo o el directorio',
            '🐱 Profe: compilá dentro de la carpeta cpp. Usá cd para llegar.'
          ], tag: 'error', ok: false);
        }
        if (!hasGrader || !hasMine) {
          return ShellResult([
            hasGrader
                ? 'undefined reference to `${_fn()}\''
                : 'undefined reference to `main\'',
            '🐱 Profe: hay que compilar los DOS juntos: grader.cpp y $task.cpp.'
          ], tag: 'error', ok: false);
        }
        return ShellResult(const [], tag: 'compile', exe: exe);
      default:
        if (cmd.startsWith('./')) {
          final exe = cmd.substring(2);
          if (!files.containsKey('$cwd/$exe')) {
            return ShellResult([
              'bash: $cmd: No existe el archivo o el directorio',
              '🐱 Profe: primero compilá con g++ (y fijate el nombre después de -o).'
            ], tag: 'error', ok: false);
          }
          if (input.isEmpty) return ShellResult(const [], tag: 'run');
          final p = resolve(input);
          final s = files[p];
          if (s == null) {
            return ShellResult(['bash: ${_noSuch('', input).substring(2)}'],
                tag: 'error', ok: false);
          }
          return ShellResult(const [], tag: 'run_sample', input: s);
        }
        if (files.containsKey('$cwd/$cmd') || cmd == task) {
          return ShellResult([
            '$cmd: orden no encontrada',
            '🐱 Profe: en Ubuntu se ejecuta con ./ adelante: ./$cmd'
          ], tag: 'hint', ok: false);
        }
        const win = {
          'dir': 'ls',
          'cls': 'clear',
          'type': 'cat',
          'Get-Content': 'cat'
        };
        if (win.containsKey(cmd)) {
          return ShellResult([
            '$cmd: orden no encontrada',
            '🐱 Profe: eso es de Windows. En Ubuntu se usa ${win[cmd]}.'
          ], tag: 'hint', ok: false);
        }
        return ShellResult(['$cmd: orden no encontrada'],
            tag: 'error', ok: false);
    }
  }

  String _fn() {
    final h = zip['cpp/$task.h'] ?? '';
    final m = RegExp(r'(\w+)\s*\(').allMatches(h).lastOrNull;
    return m == null ? task : '${m.group(1)}';
  }
}
