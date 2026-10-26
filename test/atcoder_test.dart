import 'package:codecats/data/atcoder_lists.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('accepted ids come only from AC submissions', () async {
    final c = MockClient((_) async => http.Response(
        '[{"problem_id":"abc086_a","result":"AC"},{"problem_id":"abc081_b","result":"WA"}]',
        200));
    expect(await atcoderAccepted('x', client: c), {'abc086_a'});
  });

  test('problem ids are unique', () {
    expect(kAtcoderProblems.map((p) => p.id).toSet().length,
        kAtcoderProblems.length);
  });
}
