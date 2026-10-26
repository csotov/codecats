import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import '../services/cloud.dart';

/// A problem uploaded by the coach (admin): either an own problem with
/// hidden tests, judged inside the game, or a Codeforces link the player
/// submits on Codeforces and the game verifies through the public API.
class CoachProblem {
  CoachProblem({
    required this.id,
    required this.title,
    this.statement = '',
    this.inputDesc = '',
    this.outputDesc = '',
    this.samples = const [],
    this.tests = const [],
    this.hints = const [],
    this.topic = '',
    this.xp = 150,
    this.cfContest,
    this.cfIndex,
  });

  final String id;
  final String title, statement, inputDesc, outputDesc, topic;
  final List<List<String>> samples, tests;
  final List<String> hints;
  final int xp;
  final int? cfContest;
  final String? cfIndex;

  bool get isCodeforces => cfContest != null && cfIndex != null;
  String get levelId => 'cc_${id.replaceAll('-', '').substring(0, 10)}';
  String get cfUrl =>
      'https://codeforces.com/problemset/problem/$cfContest/$cfIndex';

  static List<List<String>> _pairs(Object? v) => [
        for (final p in (v as List? ?? const []))
          [for (final s in (p as List)) '$s'],
      ];

  factory CoachProblem.fromJson(Map<String, dynamic> j) => CoachProblem(
        id: '${j['id']}',
        title: '${j['title'] ?? ''}',
        statement: '${j['statement'] ?? ''}',
        inputDesc: '${j['input_desc'] ?? ''}',
        outputDesc: '${j['output_desc'] ?? ''}',
        samples: _pairs(j['samples']),
        tests: _pairs(j['tests']),
        hints: [for (final h in (j['hints'] as List? ?? const [])) '$h'],
        topic: '${j['topic'] ?? ''}',
        xp: (j['xp'] as num?)?.toInt() ?? 150,
        cfContest: (j['cf_contest'] as num?)?.toInt(),
        cfIndex: j['cf_index'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'statement': statement,
        'input_desc': inputDesc,
        'output_desc': outputDesc,
        'samples': samples,
        'tests': tests,
        'hints': hints,
        'topic': topic,
        'xp': xp,
        'cf_contest': cfContest,
        'cf_index': cfIndex,
      };

  /// Own problems become a normal code level (same judge, stars, rewards).
  Level toLevel() => Level(
        id: levelId,
        titleEs: title,
        titleEn: title,
        storyEs: topic.isEmpty ? 'Problema del entrenador.' : 'Tema: $topic',
        storyEn: topic.isEmpty ? 'Coach problem.' : 'Topic: $topic',
        statementEs: statement,
        statementEn: statement,
        inputEs: inputDesc,
        inputEn: inputDesc,
        outputEs: outputDesc,
        outputEn: outputDesc,
        samples: [
          for (final s in samples) SampleIO(input: s[0], output: s[1]),
        ],
        tests: [
          for (final s in samples) TestCase(input: s[0], output: s[1]),
          for (final t in tests) TestCase(input: t[0], output: t[1]),
        ],
        hintsEs: hints,
        hintsEn: hints,
        starterCode: '#include <iostream>\nusing namespace std;\n\n'
            'int main() {\n    \n    return 0;\n}\n',
        xp: xp,
      );
}

/// Parse a Codeforces problem URL into (contest, index).
(int, String)? parseCodeforcesUrl(String url) {
  final m = RegExp(
          r'codeforces\.com/(?:contest|problemset/problem|gym)/(\d+)/(?:problem/)?([A-Za-z]\d?)')
      .firstMatch(url.trim());
  if (m == null) return null;
  return (int.parse(m.group(1)!), m.group(2)!.toUpperCase());
}

/// Parse tests written as blocks separated by a line `---`, each block
/// being input, a line `===`, then the expected output.
List<List<String>> parseTests(String text) {
  final out = <List<String>>[];
  for (final block in text.split(RegExp(r'^\s*---\s*$', multiLine: true))) {
    if (block.trim().isEmpty) continue;
    final parts = block.split(RegExp(r'^\s*===\s*$', multiLine: true));
    if (parts.length != 2) continue;
    out.add([parts[0].trim(), parts[1].trim()]);
  }
  return out;
}

String formatTests(List<List<String>> tests) =>
    tests.map((t) => '${t[0]}\n===\n${t[1]}').join('\n---\n');

/// Loaded coach problems, cached locally so they work offline.
class CoachStore extends ChangeNotifier {
  CoachStore._();
  static final instance = CoachStore._();
  static const _cacheKey = 'coach_problems_cache';

  List<CoachProblem> problems = const [];
  bool loading = false;

  Level? levelFor(String levelId) {
    for (final p in problems) {
      if (!p.isCodeforces && p.levelId == levelId) return p.toLevel();
    }
    return null;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null && problems.isEmpty) {
      try {
        problems = [
          for (final j in jsonDecode(cached) as List)
            CoachProblem.fromJson(Map<String, dynamic>.from(j as Map)),
        ];
        notifyListeners();
      } catch (_) {}
    }
    final c = Cloud.instance.client;
    if (c == null || !Cloud.instance.signedIn) return;
    loading = true;
    notifyListeners();
    try {
      final rows = await c
          .from('coach_problems')
          .select()
          .order('created_at', ascending: true);
      problems = [
        for (final r in rows)
          CoachProblem.fromJson(Map<String, dynamic>.from(r)),
      ];
      await prefs.setString(
          _cacheKey, jsonEncode([for (final p in problems) p.toJson()]));
    } catch (_) {
      // offline: keep the cache
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> save(CoachProblem p, {bool isNew = true}) async {
    final c = Cloud.instance.client;
    if (c == null) throw StateError('Cloud not configured');
    final row = p.toJson()..remove('id');
    if (isNew) {
      await c.from('coach_problems').insert(row);
    } else {
      await c.from('coach_problems').update(row).eq('id', p.id);
    }
    await load();
  }

  Future<void> delete(String id) async {
    final c = Cloud.instance.client;
    if (c == null) return;
    await c.from('coach_problems').delete().eq('id', id);
    await load();
  }
}

/// Whether [handle] has an accepted submission for the problem, checked
/// with the public Codeforces API (it allows browser CORS).
Future<bool> codeforcesSolved(String handle, int contest, String index,
    {http.Client? client}) async {
  final c = client ?? http.Client();
  final uri = Uri.parse(
      'https://codeforces.com/api/user.status?handle=${Uri.encodeQueryComponent(handle)}&from=1&count=1000');
  final res = await c.get(uri);
  if (res.statusCode != 200) {
    throw StateError('Codeforces HTTP ${res.statusCode}');
  }
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  if (body['status'] != 'OK') throw StateError('${body['comment']}');
  for (final s in body['result'] as List) {
    final m = Map<String, dynamic>.from(s as Map);
    final pr = Map<String, dynamic>.from(m['problem'] as Map);
    if (m['verdict'] == 'OK' &&
        (pr['contestId'] as num?)?.toInt() == contest &&
        '${pr['index']}'.toUpperCase() == index) {
      return true;
    }
  }
  return false;
}
