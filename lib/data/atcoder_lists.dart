import 'dart:convert';

import 'package:http/http.dart' as http;

/// A real AtCoder problem, linked (never copied) and verified through
/// the public AtCoder Problems API.
class AtcoderProblem {
  const AtcoderProblem(this.id, this.contest, this.titleEs, this.titleEn,
      this.minWorld, this.topicEs, this.topicEn);
  final String id, contest, titleEs, titleEn, topicEs, topicEn;
  final int minWorld;

  String get url => 'https://atcoder.jp/contests/$contest/tasks/$id';
  String get levelId => 'at_$id';
}

/// "AtCoder Beginners Selection" plus classic ABC A/B tasks, by world.
const kAtcoderProblems = [
  AtcoderProblem('abc086_a', 'abc086', 'Product', 'Product', 2, 'if y paridad',
      'if and parity'),
  AtcoderProblem('abc081_b', 'abc081', 'Shift only', 'Shift only', 3,
      'bucles y división', 'loops and division'),
  AtcoderProblem('abc087_b', 'abc087', 'Coins', 'Coins', 3, 'búsqueda completa',
      'brute force'),
  AtcoderProblem('abc083_b', 'abc083', 'Some Sums', 'Some Sums', 3,
      'suma de dígitos', 'digit sums'),
  AtcoderProblem('abc088_b', 'abc088', 'Card Game for Two', 'Card Game for Two',
      4, 'arreglos y ordenar', 'arrays and sorting'),
  AtcoderProblem('abc085_b', 'abc085', 'Kagami Mochi', 'Kagami Mochi', 4,
      'valores distintos', 'distinct values'),
  AtcoderProblem('abc085_c', 'abc085', 'Otoshidama', 'Otoshidama', 5,
      'búsqueda completa doble', 'double brute force'),
  AtcoderProblem('abc049_c', 'abc049', 'Daydream', 'Daydream', 5,
      'strings y greedy', 'strings and greedy'),
  AtcoderProblem('abc086_c', 'abc086', 'Traveling', 'Traveling', 5,
      'simulación y paridad', 'simulation and parity'),
];

/// Problem ids the AtCoder user has an AC on.
Future<Set<String>> atcoderAccepted(String user, {http.Client? client}) async {
  final c = client ?? http.Client();
  final res = await c.get(Uri.parse(
      'https://kenkoooo.com/atcoder/atcoder-api/v3/user/submissions?user=${Uri.encodeQueryComponent(user)}&from_second=0'));
  if (res.statusCode != 200) throw StateError('AtCoder HTTP ${res.statusCode}');
  return {
    for (final s in jsonDecode(res.body) as List)
      if ((s as Map)['result'] == 'AC') '${s['problem_id']}',
  };
}
