import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/scan_context.dart';
import 'base_scanner.dart';

final class CodeScanner extends BaseScanner {
  CodeScanner(super.logger);

  @override
  Future<void> run(ScanContext context) async {
    final progress = logger.progress('Analyzing Dart code...');

    if (context.foundAssets.isEmpty) {
      progress.complete('No assets to analyze.');
      return;
    }

    final directoriesToCheck = ['lib', 'bin', 'test'];
    final List<File> dartFiles = [];

    for (final dirName in directoriesToCheck) {
      final dir = Directory(dirName);
      if (dir.existsSync()) {
        final entities = dir.listSync(recursive: true);
        for (final entity in entities) {
          if (entity is File && p.extension(entity.path) == '.dart') {
            dartFiles.add(entity);
          }
        }
      }
    }

    if (dartFiles.isEmpty) {
      progress.complete('No Dart files found to analyze.');
      return;
    }

    final assetsToSearchFor = Set<String>.from(context.foundAssets);

    for (final file in dartFiles) {
      if (assetsToSearchFor.isEmpty) break;

      try {
        final content = file.readAsStringSync();
        final newlyFoundAssets = <String>[];

        for (final assetPath in assetsToSearchFor) {
          if (content.contains(assetPath)) {
            context.usedAssets.add(assetPath);
            newlyFoundAssets.add(assetPath);
            logger.detail(
              'Verbose: Exact match -> "$assetPath" in ${file.path}',
            );
            continue;
          }

          final assetDir = p.dirname(assetPath);
          if (content.contains("'$assetDir'") ||
              content.contains('"$assetDir"')) {
            context.usedAssets.add(assetPath);
            newlyFoundAssets.add(assetPath);
            logger.detail(
              'Verbose: Directory match -> "$assetPath" via "$assetDir" in ${file.path}',
            );
            continue;
          }

          final baseName = p.basenameWithoutExtension(assetPath);
          final prefix = baseName.split('_').first;

          if (prefix.length > 2) {
            final prefixPath = '$assetDir/$prefix';
            if (content.contains("'$prefixPath") ||
                content.contains('"$prefixPath')) {
              context.usedAssets.add(assetPath);
              newlyFoundAssets.add(assetPath);
              logger.detail(
                'Verbose: Prefix match -> "$assetPath" via "$prefixPath" in ${file.path}',
              );
              continue;
            }
          }
        }

        assetsToSearchFor.removeAll(newlyFoundAssets);
      } catch (e) {
        logger.err('Failed to read file ${file.path}: $e');
      }
    }

    progress.complete(
      'Analyzed ${dartFiles.length} Dart files (Found ${context.usedAssets.length} used assets)',
    );
  }
}
