import 'package:args/command_runner.dart';
import 'package:flutter_release_x/commands/build_command.dart';
import 'package:flutter_release_x/constants/kstrings.dart';

class CLI {
  void run(List<String> arguments) {
    final runner = CommandRunner(
      Kstrings.packageName,
      'A powerful CLI tool to build and release Flutter apps effortlessly. Generate release builds, upload to the cloud, and share QR codes and download links for quick and easy distribution.',
    )..addCommand(BuildCommand());

    try {
      runner.run(arguments);
    } catch (e) {
      print('Error: ${e.toString()}');
      print('Usage: ${Kstrings.packageName} <command> [options]');
    }
  }
}
