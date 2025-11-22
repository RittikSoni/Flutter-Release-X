import 'dart:io';

import 'package:flutter_release_x/commands/prompt_storage_options.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/helpers/helpers.dart';

class FlutterReleaseXKplatforms {
  static String getBuildPath(String platform) {
    switch (platform) {
      case 'ios':
        return FlutterReleaseXKstrings.iosReleasePath;
      case 'android':
        return FlutterReleaseXKstrings.releaseApkPath;
      case 'web':
        return FlutterReleaseXKstrings.webReleasePath;
      case 'macos':
        return FlutterReleaseXKstrings.macosReleasePath;
      case 'windows':
        return FlutterReleaseXKstrings.windowsReleasePath;
      case 'linux':
        return FlutterReleaseXKstrings.linuxReleasePath;
      default:
        return '';
    }
  }

  static Future<bool> buildPlatform(String platform) async {
    final String flutterPath = FlutterReleaseXHelpers.getFlutterPath();

    ProcessResult res;

    switch (platform) {
      case 'ios':
        res = await FlutterReleaseXHelpers.executeCommand(
            '$flutterPath build ios --release');
        break;
      case 'android':
        res = await FlutterReleaseXHelpers.executeCommand(
            '$flutterPath build apk --release');
        break;
      case 'web':
        res = await FlutterReleaseXHelpers.executeCommand(
            '$flutterPath build web --release');
        break;
      case 'macos':
        res = await FlutterReleaseXHelpers.executeCommand(
            '$flutterPath build macos --release');
        break;
      case 'windows':
        res = await FlutterReleaseXHelpers.executeCommand(
            '$flutterPath build windows --release');
        break;
      case 'linux':
        res = await FlutterReleaseXHelpers.executeCommand(
            '$flutterPath build linux --release');
        break;
      default:
        print('❌ Unsupported platform: $platform');
        return false;
    }

    // ✅ Log command result for debugging
    if (res.exitCode == 0) {
      print('✅ Build successful for $platform: ${res.stdout}');
    } else {
      print('❌ Build failed for $platform: ${res.stderr}');
    }

    return res.exitCode == 0;
  }

  static Future<void> buildAndProcessPlatforms(Set<String> platforms) async {
    final isFlutterAvailable =
        await FlutterReleaseXHelpers.checkFlutterAvailability();

    if (!isFlutterAvailable) {
      print('🐦 Please install Flutter to proceed.');
      return;
    }

    for (var platform in platforms) {
      print('🚀 Building for $platform...');
      final buildSuccess =
          await FlutterReleaseXKplatforms.buildPlatform(platform);

      if (buildSuccess) {
        final buildPath = FlutterReleaseXKplatforms.getBuildPath(platform);

        // Upload, generate qr, & notify slack only if platform is not web or linux
        if (platform != 'linux' && platform != 'web') {
          // Upload build to GitHub or other storage
          await flutterReleaseXpromptUploadOption(buildPath);

          // Generate QR code and link
          await FlutterReleaseXHelpers.generateQrCodeAndLink();

          // Notify Slack
          await FlutterReleaseXHelpers.notifySlack();
        }
        print('✅ $platform build completed and ready to share!');
      } else {
        print('❌ Failed to build for $platform');
      }
    }
  }
}
