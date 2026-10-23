import 'package:codecats/engine/complexity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Complexity.analyze', () {
    test('no loops -> O(1)', () {
      const code = 'int main(){int x=5;cout<<x<<endl;return 0;}';
      expect(Complexity.analyze(code).notation, 'O(1)');
    });
    test('single loop -> O(n)', () {
      const code = 'int main(){int s=0;for(int i=0;i<n;i++)s+=i;'
          'cout<<s;return 0;}';
      expect(Complexity.analyze(code).notation, 'O(n)');
    });
    test('nested loops -> O(n^2)', () {
      const code = 'int main(){for(int i=0;i<n;i++){for(int j=0;j<n;j++){'
          'cout<<i*j;}}return 0;}';
      expect(Complexity.analyze(code).notation, 'O(n²)');
    });
    test('triple nesting -> O(n^3+)', () {
      const code =
          'int main(){for(int i=0;i<n;i++){for(int j=0;j<n;j++){'
          'for(int k=0;k<n;k++){s+=1;}}}return 0;}';
      expect(Complexity.analyze(code).notation, 'O(n³+)');
    });
    test('binary search pattern -> O(log n)', () {
      const code = 'int main(){int lo=0,hi=n;while(lo<hi){'
          'int mid=(lo+hi)/2;if(a[mid]<x)lo=mid+1;else hi=mid;}'
          'return 0;}';
      expect(Complexity.analyze(code).notation, 'O(log n)');
    });
    test('braces inside strings do not count', () {
      const code = 'int main(){cout<<"{{{"<<endl;return 0;}';
      expect(Complexity.analyze(code).notation, 'O(1)');
    });
  });
}
