import 'dart:io';
import 'package:mason_logger/mason_logger.dart';

import '../models/scan_context.dart';

final class AssetCleaner {
  AssetCleaner(this.logger);

  final Logger logger;

  /// Executes the cleaning process.
  /// Returns [true] if files were deleted (or would be in a dry run), [false] if aborted or nothing to delete.
  bool clean({
    required ScanContext context,
    required bool isDryRun,
    required bool skipConfirm,
  }) {
    final unused = context.unusedAssets;

    if (unused.isEmpty) {
      logger.success(
        '\n✨ No unused assets found! Your project is already perfectly clean.',
      );
      return false;
    }

    if (!isDryRun && !skipConfirm) {
      logger.alert(
        '\n⚠️  WARNING: You are about to permanently delete ${unused.length} files.',
      );

      stdout.write('Are you sure you want to proceed? (y/N): ');

      final answer = stdin.readLineSync();

      if (answer?.toLowerCase() != 'y' && answer?.toLowerCase() != 'yes') {
        logger.info('\n❌ Auto-fix aborted by user. No files were deleted.');
        return false;
      }
      logger.info('');
    }

    logger.alert(
      '🗑️  ${isDryRun ? "[DRY RUN] " : ""}Starting auto-fix for ${unused.length} files...',
    );

    var deletedCount = 0;
    var failedCount = 0;

    for (final asset in unused) {
      final file = File(asset);

      if (isDryRun) {
        logger.info('   Would delete: $asset');
        deletedCount++;
      } else {
        try {
          if (file.existsSync()) {
            file.deleteSync();
            logger.detail('Verbose: Deleted -> $asset');
            deletedCount++;
          }
        } catch (e) {
          logger.err('   Failed to delete $asset: $e');
          failedCount++;
        }
      }
    }

    if (isDryRun) {
      logger.success(
        '✅ [DRY RUN] Finished! Would have safely deleted $deletedCount files.',
      );
    } else {
      logger.success(
        '✅ Auto-fix complete! Successfully deleted $deletedCount files.',
      );
      if (failedCount > 0) {
        logger.warn(
          '⚠️ Could not delete $failedCount files (Check file permissions).',
        );
      }
    }

    return true;
  }
}
