import 'package:args/command_runner.dart';
import 'package:flutter_release_x/commands/prompt_storage_options.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/helpers/helpers.dart';

class BuildCommand extends Command {
  @override
  String get description =>
      'Build the release APK, upload it, and generate a QR code for the download link.';

  @override
  String get name => 'build';

  @override
  void run() async {
    print('Building the release APK...');

    // Check if Flutter is installed
    final isFlutterAvailable = await Helpers.checkFlutterAvailability();

    if (isFlutterAvailable) {
      final apkBuilt = await Helpers.buildApk();

      if (apkBuilt) {
        final apkPath = Kstrings.releaseApkPath;

        // Upload APK to GitHub
        await promptUploadOption(apkPath);

        // Generate QR code
        Helpers.showLoading('🔶 Generating QR code...');
        await Helpers.generateQrCodeAndLink();
        Helpers.stopLoading();

        // CTA
        print('🚀 You did it! APK built and ready to share! 🎉');
        Helpers.showHighlight(
          firstMessage:
              '🎉 Enjoyed using the tool? Share it with your friends and colleagues! Consider starring the repo on GitHub:',
          highLightmessage: Kstrings.gitRepoLink,
        );
      } else {
        print('❌ Failed to build APK');
      }
    } else {
      print('🐦 Please install Flutter to proceed.');
    }
  }
}
