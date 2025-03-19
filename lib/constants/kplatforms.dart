import 'dart:io';

import 'package:flutter_release_x/commands/prompt_storage_options.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/helpers/helpers.dart';

class Kplatforms {
  static String getBuildPath(String platform) {
    switch (platform) {
      case 'ios':
        return Kstrings.iosReleasePath;
      case 'android':
        return Kstrings.releaseApkPath;
      case 'web':
        return Kstrings.webReleasePath;
      case 'macos':
        return Kstrings.macosReleasePath;
      case 'windows':
        return Kstrings.windowsReleasePath;
      case 'linux':
        return Kstrings.linuxReleasePath;
      default:
        return '';
    }
  }

  static Future<bool> buildPlatform(String platform) async {
    final String flutterPath = Helpers.getFlutterPath();

    ProcessResult res;

    switch (platform) {
      case 'ios':
        res = await Helpers.executeCommand('$flutterPath build ios --release');
        break;
      case 'android':
        res = await Helpers.executeCommand('$flutterPath build apk --release');
        break;
      case 'web':
        res = await Helpers.executeCommand('$flutterPath build web --release');
        break;
      case 'macos':
        res =
            await Helpers.executeCommand('$flutterPath build macos --release');
        break;
      case 'windows':
        res = await Helpers.executeCommand(
            '$flutterPath build windows --release');
        break;
      case 'linux':
        res =
            await Helpers.executeCommand('$flutterPath build linux --release');
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
    final isFlutterAvailable = await Helpers.checkFlutterAvailability();

    if (!isFlutterAvailable) {
      print('🐦 Please install Flutter to proceed.');
      return;
    }

    for (var platform in platforms) {
      print('🚀 Building for $platform...');
      final buildSuccess = await Kplatforms.buildPlatform(platform);

      if (buildSuccess) {
        final buildPath = Kplatforms.getBuildPath(platform);

        // Upload, generate qr, & notify slack only if platform is not web or linux
        if (platform != 'linux' && platform != 'web') {
          // Upload build to GitHub or other storage
          await promptUploadOption(buildPath);

          // Generate QR code and link
          await Helpers.generateQrCodeAndLink();

          // Notify Slack
          await Helpers.notifySlack();
        }
        print('✅ $platform build completed and ready to share!');
      } else {
        print('❌ Failed to build for $platform');
      }
    }
  }
}
