import 'package:asset_hound/asset_hound.dart';
import 'package:test/test.dart';

void main() {
  group('ScanContext Logic Tests', () {
    test('Calculates unused assets correctly', () {
      final context = ScanContext();

      context.foundAssets.addAll([
        'assets/logo.png',
        'assets/icon.png',
        'assets/old_banner.png',
      ]);

      context.usedAssets.add('assets/logo.png');

      final unused = context.unusedAssets;

      expect(unused.length, equals(2));
      expect(unused, contains('assets/icon.png'));
      expect(unused, contains('assets/old_banner.png'));
      expect(unused, isNot(contains('assets/logo.png')));
    });

    test('Respects ignore patterns (glob matching)', () {
      final context = ScanContext();

      context.foundAssets.addAll([
        'assets/images/logo.png',
        'assets/videos/intro.mp4',
      ]);

      context.ignoredPatterns.add('assets/videos/**');

      final unused = context.unusedAssets;

      expect(unused.length, equals(1));
      expect(unused, contains('assets/images/logo.png'));
      expect(unused, isNot(contains('assets/videos/intro.mp4')));
    });
  });
}
