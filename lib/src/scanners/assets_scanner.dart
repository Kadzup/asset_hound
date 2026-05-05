import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/scan_context.dart';
import 'base_scanner.dart';

final class AssetsScanner extends BaseScanner {
  AssetsScanner(super.logger);

  @override
  Future<void> run(ScanContext context) async {
    final progress = logger.progress('Scanning asset directories...');

    if (context.declaredDirectories.isEmpty) {
      progress.complete('No asset directories to scan.');
      return;
    }

    var fileCount = 0;

    for (final dirPath in context.declaredDirectories) {
      final normalizedPath = p.normalize(dirPath);
      final directory = Directory(normalizedPath);

      if (!directory.existsSync()) {
        logger.detail(
          'Verbose: Declared directory "$dirPath" does not exist on disk.',
        );
        continue;
      }

      try {
        final entities = directory.listSync(recursive: true);

        for (final entity in entities) {
          if (entity is File) {
            final fileName = p.basename(entity.path);

            if (fileName.startsWith('.')) continue;

            final standardizedPath = p.posix.joinAll(p.split(entity.path));

            context.foundAssets.add(standardizedPath);

            context.savedBytes += entity.lengthSync();
            fileCount++;

            logger.detail('Verbose: Found physical asset -> $standardizedPath');
          }
        }
      } catch (e) {
        logger.err('Failed to scan directory $dirPath: $e');
      }
    }

    progress.complete(
      'Scanned file system (Found $fileCount physical asset files)',
    );
  }
}
