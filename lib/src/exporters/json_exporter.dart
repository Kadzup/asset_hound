import 'dart:convert';
import 'dart:io';
import '../models/scan_context.dart';
import 'report_exporter.dart';

final class JsonExporter extends ReportExporter {
  JsonExporter(super.logger);

  @override
  void export(ScanContext context) {
    logger.info('Generating JSON report...');

    final unusedAssets = context.unusedAssets;
    var totalSavedBytes = 0;

    for (final asset in unusedAssets) {
      final file = File(asset);
      if (file.existsSync()) {
        totalSavedBytes += file.lengthSync();
      }
    }

    final reportData = {
      'summary': {
        'total_assets_found': context.foundAssets.length,
        'used_assets': context.usedAssets.length,
        'unused_assets': unusedAssets.length,
        'potential_savings_bytes': totalSavedBytes,
        'potential_savings_mb': (totalSavedBytes / (1024 * 1024))
            .toStringAsFixed(2),
      },
      'unused_files': unusedAssets,
    };

    final encoder = const JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(reportData);

    final file = File('asset_hound_report.json');
    file.writeAsStringSync(jsonString);

    logger.success('📄 JSON Report saved to: ${file.absolute.path}');
  }
}
