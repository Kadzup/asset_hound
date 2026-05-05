import 'dart:io';
import '../models/scan_context.dart';
import 'report_exporter.dart';

final class HtmlExporter extends ReportExporter {
  HtmlExporter(super.logger);

  @override
  void export(ScanContext context) {
    logger.info('Generating HTML report...');

    final unusedAssets = context.unusedAssets;
    var totalSavedBytes = 0;

    final buffer = StringBuffer();
    for (final asset in unusedAssets) {
      final file = File(asset);
      var size = 0;
      if (file.existsSync()) {
        size = file.lengthSync();
        totalSavedBytes += size;
      }

      final sizeKb = (size / 1024).toStringAsFixed(1);
      buffer.writeln('''
        <tr>
          <td class="path">$asset</td>
          <td class="size">$sizeKb KB</td>
        </tr>
      ''');
    }

    final savedMb = (totalSavedBytes / (1024 * 1024)).toStringAsFixed(2);

    final htmlContent =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Asset Hound Report</title>
  <style>
    body { font-family: system-ui, -apple-system, sans-serif; background-color: #0f172a; color: #f8fafc; margin: 0; padding: 40px; }
    .container { max-width: 900px; margin: 0 auto; }
    h1 { color: #38bdf8; display: flex; align-items: center; gap: 10px; }
    .summary-cards { display: flex; gap: 20px; margin-bottom: 30px; }
    .card { background: #1e293b; padding: 20px; border-radius: 12px; flex: 1; text-align: center; border: 1px solid #334155; }
    .card h3 { margin: 0; font-size: 14px; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; }
    .card p { margin: 10px 0 0 0; font-size: 32px; font-weight: bold; color: #fff; }
    .card.highlight p { color: #10b981; }
    table { width: 100%; border-collapse: collapse; background: #1e293b; border-radius: 12px; overflow: hidden; }
    th, td { padding: 15px; text-align: left; border-bottom: 1px solid #334155; }
    th { background: #0f172a; color: #94a3b8; font-weight: 600; text-transform: uppercase; font-size: 13px; }
    tr:last-child td { border-bottom: none; }
    .path { font-family: monospace; color: #cbd5e1; }
    .size { color: #f87171; font-weight: 500; width: 120px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>🐶 Asset Hound Report</h1>
    
    <div class="summary-cards">
      <div class="card">
        <h3>Assets Scanned</h3>
        <p>${context.foundAssets.length}</p>
      </div>
      <div class="card">
        <h3>Unused Files</h3>
        <p>${unusedAssets.length}</p>
      </div>
      <div class="card highlight">
        <h3>Potential Savings</h3>
        <p>$savedMb MB</p>
      </div>
    </div>

    <table>
      <thead>
        <tr>
          <th>Unused Asset Path</th>
          <th>File Size</th>
        </tr>
      </thead>
      <tbody>
        ${buffer.toString()}
      </tbody>
    </table>
  </div>
</body>
</html>
''';

    final file = File('asset_hound_report.html');
    file.writeAsStringSync(htmlContent);

    logger.success('📄 HTML Report saved to: ${file.absolute.path}');
  }
}
