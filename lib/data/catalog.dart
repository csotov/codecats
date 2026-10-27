import '../models.dart';

/// Compact level builder so world files stay readable.
Level lvl({
  required String id,
  required String tEs,
  required String tEn,
  required String sEs,
  required String sEn,
  required String dEs,
  required String dEn,
  String iEs = 'Un número entero.',
  String iEn = 'One integer.',
  String oEs = 'Un número entero.',
  String oEn = 'One integer.',
  required List<List<String>> samples,
  List<List<String>> tests = const [],
  List<String> cEs = const [],
  List<String> cEn = const [],
  List<String> hEs = const [],
  List<String> hEn = const [],
  String? starter,
  EditorMode mode = EditorMode.code,
  List<String> blocks = const [],
  int xp = 100,
  bool boss = false,
  int maxOps = 2000000,
  List<String> concepts = const [],
}) {
  return Level(
    id: id,
    titleEs: tEs,
    titleEn: tEn,
    storyEs: sEs,
    storyEn: sEn,
    statementEs: dEs,
    statementEn: dEn,
    inputEs: iEs,
    inputEn: iEn,
    outputEs: oEs,
    outputEn: oEn,
    samples: [for (final s in samples) SampleIO(input: s[0], output: s[1])],
    tests: [
      for (final t in tests) TestCase(input: t[0], output: t[1], hidden: true),
    ],
    constraintsEs: cEs,
    constraintsEn: cEn,
    hintsEs: hEs,
    hintsEn: hEn,
    starterCode: starter ?? kDefaultStarter,
    mode: mode,
    allowedBlocks: blocks,
    xp: xp,
    boss: boss,
    maxOps: maxOps,
    concepts: concepts,
  );
}

const kDefaultStarter = '''#include <iostream>
using namespace std;

int main() {
    // Escribe tu código aquí / Write your code here
    return 0;
}
''';

const kStrStarter = '''#include <iostream>
#include <cstring>
using namespace std;

int main() {
    // Escribe tu código aquí / Write your code here
    return 0;
}
''';

const kStlStarter = '''#include <bits/stdc++.h>
using namespace std;

int main() {
    // Escribe tu código aquí / Write your code here
    return 0;
}
''';

const kFuncStarter = '''#include <iostream>
using namespace std;

// Escribe tu función aquí / Write your function here

int main() {
    // Escribe tu código aquí / Write your code here
    return 0;
}
''';

// Block palette shortcuts -------------------------------------------------
const kIoBlocks = [
  'print_text', 'print_expr', 'print_inline', 'print_space', 'read_var',
];
const kVarBlocks = [
  'decl_int', 'decl_ll', 'decl_double', 'decl_bool',
  'assign', 'add_assign', 'increment', 'decrement',
];
const kCtrlBlocks = [
  'if_block', 'if_else', 'for_i', 'for_down', 'while_block',
  'break_stmt', 'continue_stmt',
];
const kArrBlocks = [
  'decl_array', 'decl_str', 'read_array', 'print_array',
  'set_elem', 'swap_vars',
];
const kMiscBlocks = ['return0', 'raw_line'];
const kAllBlocks = [
  ...kIoBlocks, ...kVarBlocks, ...kCtrlBlocks, ...kArrBlocks, ...kMiscBlocks,
];

/// Global ordered list of level ids (campaign path).
List<String> orderedLevelIds(List<World> worlds) =>
    [for (final w in worlds) for (final l in w.levels) l.id];
