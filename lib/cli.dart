import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_release_x/commands/build_command.dart';
import 'package:flutter_release_x/commands/check_update_command.dart';
import 'package:flutter_release_x/commands/init_command.dart';
import 'package:flutter_release_x/commands/notify_command/notify_command.dart';
import 'package:flutter_release_x/commands/version_command.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/services/update_check_service.dart';

class CLI {
  static const String description = '''
A powerful CLI tool to build and release Flutter & Non-Flutter apps effortlessly. 
- Generate release builds, upload to the cloud, and share QR codes & download links for quick distribution.
- Need a custom pipeline? Try the new Advanced Pipeline feature in FRX.
📖 Docs: ${FlutterReleaseXKstrings.documentaion}
''';

  void run(List<String> arguments) {
    final runner =
        CommandRunner(FlutterReleaseXKstrings.packageName, description)
          ..addCommand(FlutterReleaseXBuildCommand())
          ..addCommand(FlutterReleaseXNotifyCommand())
          ..addCommand(FlutterReleaseXVersionCommand())
          ..addCommand(FlutterReleaseXCheckUpdateCommand())
          ..addCommand(FlutterReleaseXInitCommand());

    runner.argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Display version information.',
    );

    try {
      final ArgResults topLevel = runner.parse(arguments);

      // -v/--version, show version and exit
      if (topLevel['version'] == true) {
        print('🔧 FRX Version: ${FlutterReleaseXKstrings.version}');
        return;
      }

      // Check for updates in the background (non-blocking)
      // Skip if running check-update, version, or init commands
      if (!arguments.contains('check-update') && 
          !arguments.contains('version') &&
          !arguments.contains('init')) {
        _checkForUpdatesInBackground();
      }

      runner.run(arguments);
    } on UsageException catch (e) {
      print('${e.message}\n');
      print(
          'Usage: ${FlutterReleaseXKstrings.packageName} <command> [options]');
    } catch (e, stackTrace) {
      print('Unexpected error: $e');
      print(stackTrace);
    }
  }

  /// Check for updates in the background and show a notice if available
  /// This runs asynchronously and doesn't block the main command execution
  static void _checkForUpdatesInBackground() {
    // Run asynchronously without blocking
    Future.delayed(const Duration(seconds: 1)).then((_) async {
      try {
        final isUpdateAvailable =
            await FlutterReleaseXUpdateCheckService.isUpdateAvailable();
        if (isUpdateAvailable) {
          final message =
              await FlutterReleaseXUpdateCheckService.getUpdateMessage();
          if (message != null) {
            // Print update notice after a small delay to not interfere with command output
            Future.delayed(const Duration(milliseconds: 500), () {
              print('\n$message');
            });
          }
        }
      } catch (e) {
        // Silently fail - don't interrupt user's workflow
      }
    });
  }
}
