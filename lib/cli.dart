import 'package:args/command_runner.dart';
import 'package:flutter_release_x/commands/build_command.dart';
import 'package:flutter_release_x/commands/notify_command/notify_command.dart';
import 'package:flutter_release_x/constants/kstrings.dart';

class CLI {
  static const String description = '''
A powerful CLI tool to build and release Flutter & Non-Flutter apps effortlessly. 
- Generate release builds, upload to the cloud, and share QR codes & download links for quick distribution.
- Need a custom pipeline? Try the new Advanced Pipeline feature in FRX.''';

  void run(List<String> arguments) {
    final runner = CommandRunner(Kstrings.packageName, description)
      ..addCommand(BuildCommand())
      ..addCommand(NotifyCommand());

    try {
      runner.run(arguments);
    } on UsageException catch (e) {
      print('${e.message}\n');
      print('Usage: ${Kstrings.packageName} <command> [options]');
    } catch (e, stackTrace) {
      print('Unexpected error: $e');
      print(stackTrace);
    }
  }
}
