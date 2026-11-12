import 'package:codecats/services/progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('winning programs are kept, deduplicated and survive json', () {
    final p = LevelProgress();
    expect(p.addWin('int main(){return 0;}'), isTrue);
    expect(p.addWin('int main() {\n  return 0;\n}'), isFalse);
    expect(p.addWin('int main(){return 1;}', blocksJson: const []), isTrue);
    final r = LevelProgress.fromJson(p.toJson());
    expect(r.wins.length, 2);
    expect(r.wins.last['b'], isEmpty);
    expect(LevelProgress.fromJson(LevelProgress().toJson()).wins, isEmpty);
  });
}
