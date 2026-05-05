import 'package:asset_hound/asset_hound.dart';
import 'package:mason_logger/mason_logger.dart';

/// This example demonstrates how to use Asset Hound programmatically
/// if you don't want to use the CLI.
void main() async {
  final logger = Logger();
  final context = ScanContext();

  logger.info('Running Asset Hound programmatically...');

  // 1. You can manually feed it paths
  context.declaredDirectories.add('assets/images/');
  context.foundAssets.addAll([
    'assets/images/logo.png',
    'assets/images/unused_icon.png',
  ]);

  // 2. Or you can run the scanners directly!
  // await PubspecScanner(logger).run(context);
  // await AssetsScanner(logger).run(context);
  // await CodeScanner(logger).run(context);

  // 3. Mark an asset as used
  context.usedAssets.add('assets/images/logo.png');

  // 4. Get the results
  final unused = context.unusedAssets;

  logger.success('Found ${unused.length} unused assets:');
  for (final asset in unused) {
    logger.err('- $asset');
  }
}
