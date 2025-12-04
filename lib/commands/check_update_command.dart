import 'package:args/command_runner.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/services/update_check_service.dart';

class FlutterReleaseXCheckUpdateCommand extends Command {
  @override
  final name = 'check-update';
  @override
  final description =
      'Check if a new version of Flutter Release X (frx) is available.';

  FlutterReleaseXCheckUpdateCommand();

  @override
  void run() async {
    print('🔍 Checking for updates...\n');

    try {
      final message = await FlutterReleaseXUpdateCheckService.getUpdateMessage(
        forceCheck: true,
      );

      if (message != null) {
        print(message);
      } else {
        print(
            '✅ You are using the latest version of FRX (${FlutterReleaseXKstrings.version})');
      }
    } catch (e) {
      print('⚠️  Could not check for updates. Please try again later.');
      print('   Error: $e');
    }
  }
}
