import 'package:args/command_runner.dart';
import 'package:flutter_release_x/constants/kstrings.dart';

class VersionCommand extends Command {
  @override
  final name = 'version';
  @override
  final description = 'Display the current version of Flutter Release X (frx).';

  VersionCommand();

  @override
  void run() {
    print('FRX Version: ${Kstrings.version}');
  }
}
