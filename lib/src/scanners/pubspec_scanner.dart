import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import '../models/scan_context.dart';
import 'base_scanner.dart';

final class PubspecScanner extends BaseScanner {
  PubspecScanner(super.logger);

  @override
  Future<void> run(ScanContext context) async {
    final progress = logger.progress('Parsing pubspec.yaml...');

    final file = File('pubspec.yaml');
    if (!file.existsSync()) {
      progress.fail('Could not find pubspec.yaml.');
      throw Exception(
        'Please run this command from the root of a Flutter project.',
      );
    }

    try {
      final yamlString = await file.readAsString();
      final yamlMap = loadYaml(yamlString) as YamlMap?;

      if (yamlMap == null) {
        progress.fail('pubspec.yaml is empty or invalid.');
        return;
      }

      // 1. Parse standard Flutter assets
      final flutterSection = yamlMap['flutter'];
      if (flutterSection is YamlMap) {
        final assetsList = flutterSection['assets'];
        if (assetsList is YamlList) {
          for (final assetPath in assetsList) {
            if (assetPath is String) {
              context.declaredDirectories.add(assetPath);
            }
          }
        }
      }

      final houndSection = yamlMap['asset_hound'];
      if (houndSection is YamlMap && houndSection['ignore'] is YamlList) {
        for (final pattern in houndSection['ignore']) {
          context.ignoredPatterns.add(pattern.toString());
        }
      }

      for (final packageName in context.protectedPackages) {
        final packageSection = yamlMap[packageName];
        if (packageSection is YamlMap) {
          _protectNativeAssets(packageSection, packageName, context);
        }
      }

      progress.complete(
        'Parsed pubspec.yaml (Found ${context.declaredDirectories.length} dirs, ${context.usedAssets.length} native protected assets)',
      );
    } catch (e) {
      progress.fail('Failed to parse pubspec.yaml.');
      logger.err('YAML Parsing Error: $e');
      throw Exception('Invalid pubspec.yaml format.');
    }
  }

  /// Recursively searches a YamlMap for file paths and marks them as used.
  void _protectNativeAssets(
    YamlMap map,
    String packageName,
    ScanContext context,
  ) {
    for (final value in map.values) {
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower.endsWith('.png') ||
            lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.svg') ||
            lower.endsWith('.webp')) {
          final normalizedPath = p.posix.joinAll(p.split(value));

          // Add it directly to usedAssets so the CodeScanner ignores it
          context.usedAssets.add(normalizedPath);
          logger.detail(
            'Verbose: Protected native asset from $packageName -> $normalizedPath',
          );
        }
      } else if (value is YamlMap) {
        // If it's a nested map (like android_12: ...), search it recursively
        _protectNativeAssets(value, packageName, context);
      }
    }
  }
}
