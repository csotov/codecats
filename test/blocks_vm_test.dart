import 'package:codecats/engine/blocks.dart';
import 'package:codecats/engine/blocks_vm.dart';
import 'package:codecats/engine/runner.dart';
import 'package:flutter_test/flutter_test.dart';

BlockNode b(String id,
        {Map<String, String>? params,
        List<BlockNode>? children,
        List<BlockNode>? elseChildren}) =>
    BlockNode(id,
        params: params, children: children, elseChildren: elseChildren);

Future<RunOutput> runBlocks(List<BlockNode> roots, [String input = '']) =>
    BlocksRunner(roots).run('', input);

void main() {
  test('print text + expression', () async {
    final r = await runBlocks([
      b('decl_int', params: {'name': 'x', 'init': '5'}),
      b('print_text', params: {'text': 'Hola'}),
      b('print_expr', params: {'expr': 'x * 2 + 1'}),
    ]);
    expect(r.ok, isTrue);
    expect(r.output, 'Hola\n11\n');
  });

  test('cin reads sequential tokens', () async {
    final r = await runBlocks([
      b('read_var', params: {'var': 'a'}),
      b('read_var', params: {'var': 'b'}),
      b('print_expr', params: {'expr': 'a + b'}),
    ], '3 4');
    expect(r.output, '7\n');
  });

  test('multi declaration: "a, b" declares both', () async {
    final r = await runBlocks([
      b('decl_int', params: {'name': 'a, b', 'init': '3'}),
      b('print_expr', params: {'expr': 'a + b'}),
    ]);
    expect(r.output, '6\n');
  });

  test('multi read: "a, b" in one read_var', () async {
    final r = await runBlocks([
      b('decl_int', params: {'name': 'a, b'}),
      b('read_var', params: {'var': 'a, b'}),
      b('print_expr', params: {'expr': 'a * b'}),
    ], '6 7');
    expect(r.output, '42\n');
  });

  test('raw line: cin >> a, b and int a, b', () async {
    final r = await runBlocks([
      b('raw_line', params: {'code': 'int a, b;'}),
      b('raw_line', params: {'code': 'cin >> a, b;'}),
      b('raw_line', params: {'code': 'cout << a + b << endl;'}),
    ], '10 20');
    expect(r.output, '30\n');
  });

  test('for loop accumulates', () async {
    final r = await runBlocks([
      b('decl_int', params: {'name': 'n', 'init': '5'}),
      b('decl_int', params: {'name': 's', 'init': '0'}),
      b('for_i', params: {
        'var': 'i',
        'start': '1',
        'end': 'n + 1'
      }, children: [
        b('add_assign', params: {'name': 's', 'expr': 'i'}),
      ]),
      b('print_expr', params: {'expr': 's'}),
    ]);
    expect(r.output, '15\n');
  });

  test('nested for: inner var does not clobber outer', () async {
    final r = await runBlocks([
      b('for_i', params: {
        'var': 'i',
        'start': '0',
        'end': '3'
      }, children: [
        b('for_i', params: {
          'var': 'i',
          'start': '0',
          'end': '2'
        }, children: [
          b('print_inline', params: {'expr': '1'}),
        ]),
      ]),
    ]);
    expect(r.output, '111111');
  });

  test('C++ division truncates toward zero', () async {
    final r = await runBlocks([
      b('print_expr', params: {'expr': '-7 / 2'}),
      b('print_expr', params: {'expr': '-8 % 3'}),
    ]);
    expect(r.output, '-3\n-2\n');
  });

  test('if/else branches', () async {
    final r = await runBlocks([
      b('decl_int', params: {'name': 'x', 'init': '-3'}),
      b('if_else', params: {
        'cond': 'x >= 0'
      }, children: [
        b('print_text', params: {'text': 'pos'}),
      ], elseChildren: [
        b('print_text', params: {'text': 'neg'}),
      ]),
    ]);
    expect(r.output, 'neg\n');
  });

  test('while + break', () async {
    final r = await runBlocks([
      b('decl_int', params: {'name': 'i', 'init': '0'}),
      b('while_block', params: {
        'cond': 'true'
      }, children: [
        b('increment', params: {'name': 'i'}),
        b('if_block', params: {'cond': 'i >= 3'}, children: [b('break_stmt')]),
      ]),
      b('print_expr', params: {'expr': 'i'}),
    ]);
    expect(r.output, '3\n');
  });

  test('infinite loop -> TLE', () async {
    final r = await runBlocks([
      b('while_block', params: {'cond': 'true'}, children: []),
    ]);
    expect(r.ok, isFalse);
    expect(r.error, RunError.tle);
  });

  test('arrays: read, set, swap, print', () async {
    final r = await runBlocks([
      b('decl_int', params: {'name': 'n', 'init': '3'}),
      b('decl_array', params: {'name': 'a', 'size': '5'}),
      b('read_array', params: {'name': 'a', 'n': 'n'}),
      b('swap_vars', params: {'a': 'a[0]', 'b': 'a[2]'}),
      b('print_array', params: {'name': 'a', 'n': 'n'}),
    ], '1 2 3');
    expect(r.output, '3 2 1\n');
  });

  test('raw_line: assignment and cout', () async {
    final r = await runBlocks([
      b('decl_int', params: {'name': 'x', 'init': '1'}),
      b('raw_line', params: {'code': 'x = x * 10;'}),
      b('raw_line', params: {'code': 'cout << x << endl;'}),
    ]);
    expect(r.output, '10\n');
  });

  test('logic operators', () async {
    final r = await runBlocks([
      b('print_expr', params: {'expr': '(3 > 1) && !(2 == 5)'}),
      b('print_expr', params: {'expr': '2 == 5 || 3 == 3'}),
    ]);
    expect(r.output, '1\n1\n');
  });
}
