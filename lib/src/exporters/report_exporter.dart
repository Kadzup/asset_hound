import 'package:mason_logger/mason_logger.dart';

import '../models/scan_context.dart';

abstract class ReportExporter {
  ReportExporter(this.logger);

  final Logger logger;

  void export(ScanContext context);
}
