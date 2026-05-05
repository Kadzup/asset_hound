import 'package:glob/glob.dart';

final class ScanContext {
  /// Asset directories declared in pubspec.yaml
  final Set<String> declaredDirectories = {};

  /// Actual physical files found in those directories
  final Set<String> foundAssets = {};

  /// Assets actively referenced in the Dart code
  final Set<String> usedAssets = {};

  /// Store ignore rules from pubspec.yaml
  final Set<String> ignoredPatterns = {};

  /// Store the native config packages to protect
  final Set<String> protectedPackages = {};

  /// Total bytes we can save by deleting unused assets
  int savedBytes = 0;

  /// The final list of unused assets (calculated at the end)
  List<String> get unusedAssets {
    final mathematicallyUnused = foundAssets
        .where((asset) => !usedAssets.contains(asset))
        .toList();

    return mathematicallyUnused.where((asset) {
      for (final pattern in ignoredPatterns) {
        final glob = Glob(pattern);
        if (glob.matches(asset)) return false;
      }

      return true;
    }).toList();
  }
}
