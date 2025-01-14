import 'package:args/command_runner.dart';
import 'package:flutter_release_x/commands/prompt_storage_options.dart';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/helpers/helpers.dart';

class BuildCommand extends Command {
  @override
  String get description =>
      'Build the release APK, upload it, and generate a QR code for the download link.';

  @override
  String get name => 'build';

  // Define the --config option
  BuildCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to the configuration file.',
      defaultsTo: 'config.yaml', // Optional: set a default value
    );
    argParser.addFlag(
      'show-config',
      abbr: 's',
      help: 'Show the current configuration file path.',
      negatable: false, // Make it a flag (true/false)
      defaultsTo: false, // Optional: default value is false
    );
  }

  @override
  void run() async {
    final configPath = argResults?['config'];

    final showConfig = argResults?['show-config'] ?? false;

    // Load config dynamically or use persisted one
    Config().loadConfig(configPath);

    if (showConfig) {
      Helpers.showUserConfig();
      return;
    }

    print('Building the release APK...');
    final isFlutterAvailable = await Helpers.checkFlutterAvailability();

    if (isFlutterAvailable) {
      final apkBuilt = await Helpers.buildApk();

      if (apkBuilt) {
        final apkPath = Kstrings.releaseApkPath;

        // Upload APK to GitHub or other storage option
        await promptUploadOption(apkPath);

        /// Generate QR code and link.
        await Helpers.generateQrCodeAndLink();

        /// Notify Slack.
        await Helpers.notifySlack();
        print('🚀 APK built and ready to share!');
      } else {
        print('❌ Failed to build APK');
      }
    } else {
      print('🐦 Please install Flutter to proceed.');
    }
  }
}
