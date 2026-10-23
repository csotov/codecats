import 'package:codecats/engine/blocks.dart';
import 'package:codecats/engine/judge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('outputsMatch (judge comparison)', () {
    test('exact match', () {
      expect(outputsMatch('1 2 3', '1 2 3'), isTrue);
    });
    test('ignores whitespace differences', () {
      expect(outputsMatch('1\n2\n3', '1 2 3'), isTrue);
      expect(outputsMatch('  42  ', '42'), isTrue);
      expect(outputsMatch('7 8\n', '7 8'), isTrue);
    });
    test('detects mismatch', () {
      expect(outputsMatch('1 2 3', '1 2 4'), isFalse);
      expect(outputsMatch('1 2', '1 2 3'), isFalse);
      expect(outputsMatch('', 'x'), isFalse);
    });
  });

  group('blocksToCode', () {
    test('wraps in a full program', () {
      final code = blocksToCode([
        BlockNode('print_text', params: {'text': 'Hola'}),
      ]);
      expect(code, contains('int main()'));
      expect(code, contains('cout << "Hola" << endl;'));
      expect(code, contains('return 0;'));
    });

    test('nested blocks indent correctly', () {
      final code = blocksToCode([
        BlockNode('for_i',
            params: {'var': 'i', 'start': '0', 'end': 'n'},
            children: [
              BlockNode('print_expr', params: {'expr': 'i'}),
            ]),
      ]);
      expect(code, contains('for (int i = 0; i < n; i++) {'));
      expect(code, contains('        cout << i << endl;'));
    });

    test('if/else emits both branches', () {
      final code = blocksToCode([
        BlockNode('if_else',
            params: {'cond': 'x > 0'},
            children: [
              BlockNode('print_text', params: {'text': 'pos'}),
            ],
            elseChildren: [
              BlockNode('print_text', params: {'text': 'neg'}),
            ]),
      ]);
      expect(code, contains('if (x > 0) {'));
      expect(code, contains('} else {'));
      expect(code, contains('"pos"'));
      expect(code, contains('"neg"'));
    });

    test('blocks survive JSON round-trip', () {
      final root = BlockNode('for_i',
          params: {'var': 'i', 'end': '10'},
          children: [
            BlockNode('print_expr', params: {'expr': 'i * i'}),
          ]);
      final restored =
          blocksFromJson(blocksToJson([root]));
      expect(restored.length, 1);
      expect(restored[0].defId, 'for_i');
      expect(restored[0].params['end'], '10');
      expect(restored[0].children[0].params['expr'], 'i * i');
    });
  });
}
