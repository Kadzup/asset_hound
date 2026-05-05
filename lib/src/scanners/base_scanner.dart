import 'package:mason_logger/mason_logger.dart';
import '../models/scan_context.dart';

abstract class BaseScanner {
  BaseScanner(this.logger);

  final Logger logger;

  /// Every parser takes the context, does its job, and modifies the context.
  Future<void> run(ScanContext context);
}
