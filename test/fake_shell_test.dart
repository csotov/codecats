import 'package:codecats/engine/fake_shell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FakeShell make() => FakeShell(
      task: 'multiplos',
      zip: {
        'cpp/grader.cpp': 'int main(){}',
        'cpp/multiplos.h': 'long long contar(long long n);',
        'cpp/multiplos.cpp': 'starter',
        'examples/0-01.in': '10',
        'examples/0-01.out': '5',
      },
      code: () => 'mine');

  test('exam-day path: cd, unzip, geany, g++, run sample', () {
    final s = make()..download();
    expect(s.run('pwd').lines, ['/home/obi']);
    expect(s.run('ls').lines.single, contains('Descargas/'));
    expect(s.run('unzip multiplos.zip').ok, isFalse);
    expect(s.run('cd Descargas').tag, 'cd');
    expect(s.prompt, 'obi@ubuntu:~/Descargas\$');
    expect(s.run('unzip multiplos.zip -d multiplos').tag, 'unzip');
    expect(s.run('g++ grader.cpp multiplos.cpp').ok, isFalse);
    s.run('cd multiplos/cpp');
    expect(
        s.run('ls').lines.single, 'grader.cpp   multiplos.cpp   multiplos.h');
    expect(s.run('cat multiplos.cpp').lines, ['mine']);
    expect(s.run('geany grader.cpp').tag, 'hint');
    expect(s.run('geany multiplos.cpp').tag, 'edit');
    expect(s.run('./multiplos').ok, isFalse);
    final c =
        s.run('g++ -std=gnu++17 -O2 -o multiplos grader.cpp multiplos.cpp');
    expect(c.tag, 'compile');
    s.addFile('${s.cwd}/${c.exe}', '(exe)');
    final r = s.run('./multiplos < ../examples/0-01.in');
    expect(r.tag, 'run_sample');
    expect(r.input, '10');
    expect(s.run('cd ..').tag, 'cd');
    expect(s.cwd, '/home/obi/Descargas/multiplos');
    expect(s.run('cd ~').tag, 'cd');
    expect(s.cwd, '/home/obi');
  });

  test('missing pieces give hints', () {
    final s = make();
    expect(s.run('cd Nada').ok, isFalse);
    expect(s.run('dir').tag, 'hint');
    expect(s.run('foo').tag, 'error');
  });
}
