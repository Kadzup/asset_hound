import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../cleaners/asset_cleaner.dart';
import '../exporters/html_exporter.dart';
import '../exporters/json_exporter.dart';

import '../models/scan_context.dart';
import '../models/scan_scope.dart';

import '../scanners/assets_scanner.dart';
import '../scanners/pubspec_scanner.dart';
import '../scanners/code_scanner.dart';

class ScanCommand extends Command {
  @override
  final String name = 'scan';

  @override
  final String description = 'Scans the Flutter project to find unused assets.';

  final Logger _logger;

  ScanCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addFlag(
        'auto-fix',
        abbr: 'f',
        help: 'Automatically delete the unused assets found during the scan.',
        negatable: false,
      )
      ..addFlag(
        'yes',
        abbr: 'y',
        help: 'Skip the confirmation prompt when using --auto-fix.',
        negatable: false,
      )
      ..addFlag(
        'dry-run',
        abbr: 'd',
        help: 'Simulate the scan without actually deleting any files.',
        negatable: false,
      )
      ..addMultiOption(
        'scope',
        abbr: 's',
        allowed: ScanScope.values.map((e) => e.name),
        defaultsTo: ScanScope.values.map((e) => e.name),
        help: 'Comma-separated list of scopes to include in the scan.',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Enable verbose logging for debugging purposes.',
        negatable: false,
      )
      ..addOption(
        'report',
        abbr: 'r',
        help: 'Generate a visual report file.',
        allowed: ['html', 'json'],
        valueHelp: 'FORMAT',
      )
      ..addMultiOption(
        'protect',
        abbr: 'p',
        help: 'Comma-separated list of pubspec config packages to protect.',
        defaultsTo: [
          'flutter_icons',
          'flutter_launcher_icons',
          'flutter_native_splash',
        ],
      );
  }

  @override
  Future<void> run() async {
    final isVerbose = argResults?['verbose'] as bool? ?? false;
    if (isVerbose) _logger.level = Level.verbose;

    final reportFormat = argResults?['report'] as String?;
    final autoFix = argResults?['auto-fix'] as bool? ?? false;
    final scopes = argResults?['scope'] as List<String>? ?? [];
    final protectedPackages = argResults?['protect'] as List<String>? ?? [];
    final isDryRun = argResults?['dry-run'] as bool? ?? false;
    final skipConfirm = argResults?['yes'] as bool? ?? false;

    _logger.info('\n🐶 Asset Hound activated!\n');

    final context = ScanContext();
    context.protectedPackages.addAll(protectedPackages);

    if (scopes.contains(ScanScope.pubspec.name)) {
      await PubspecScanner(_logger).run(context);
    }

    if (scopes.contains(ScanScope.assets.name)) {
      await AssetsScanner(_logger).run(context);
    }

    if (scopes.contains(ScanScope.code.name)) {
      await CodeScanner(_logger).run(context);
    }

    if (autoFix || isDryRun) {
      AssetCleaner(
        _logger,
      ).clean(context: context, isDryRun: isDryRun, skipConfirm: skipConfirm);
    }

    if (reportFormat == 'html') {
      HtmlExporter(_logger).export(context);
    } else if (reportFormat == 'json') {
      JsonExporter(_logger).export(context);
    }

    _logger.success('\n✅ Pipeline complete!');
  }
}
