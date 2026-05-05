import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:asset_hound/src/commands/scan_command.dart';
import 'package:mason_logger/mason_logger.dart';

void main(List<String> args) async {
  final logger = Logger();

  final runner = CommandRunner(
    'asset_hound',
    '🐶 A powerful CLI tool to sniff out and remove unused assets in Flutter projects.',
  )..addCommand(ScanCommand(logger: logger));

  try {
    await runner.run(args);
  } catch (e) {
    logger.err('A fatal error occurred: $e');
    exit(1);
  }
}
