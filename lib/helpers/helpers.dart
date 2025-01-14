import 'dart:async';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/services/slack_service.dart';
import 'package:flutter_release_x/state_management/upload_state.dart';
import 'package:qr/qr.dart';
import 'package:image/image.dart' as img;

class Helpers {
  /// Store the timer for stopping later
  static Timer? _loadingTimer;

  static notifySlack() async {
    final slackService = SlackService();
    final uploadState = UploadState();

    final String? downloadLink = uploadState.uploadLink;
    final slackConfig = Config().config.uploadOptions.slack;
    final bool isSlackEnabled = slackConfig.enabled;
    final String? slackBotToken = slackConfig.botUserOauthToken;
    final String? channelId = slackConfig.defaultChannelId;
    final String? customMessage = slackConfig.customMessage;
    final List<String>? mentionUsers = slackConfig.mentionUsers;
    final bool isShareDownloadLink = slackConfig.shareLink;
    final bool isShareQR = slackConfig.shareQR;
    final File qrFile = File('./release-qr-code.png');

    if (isSlackEnabled && slackBotToken != null && channelId != null) {
      try {
        print('🔔 Sharing on Slack...');
        Helpers.showLoading('🔔 Sharing on Slack...');

        await slackService.sendLinkAndQr(
          slackBotToken: slackBotToken,
          fileSizeInBytes: qrFile.lengthSync(),
          file: qrFile,
          channelId: channelId,
          message: customMessage ?? '🎉 Your app is ready for download!',
          mentions: mentionUsers,
          downloadLink: downloadLink ?? Kstrings.packageLink,
          isShareQR: isShareQR,
          isShareDownloadLink: isShareDownloadLink,
        );
        print('Message sent successfully to Slack.');
      } catch (e, s) {
        showHighlight(
          firstMessage: 'Slack error:',
          highLightmessage: e.toString(),
          lastMessage: s.toString(),
        );
        exit(0);
      } finally {
        Helpers.stopLoading();
      }
    }
  }

  /// Get the QR error correction level
  ///
  /// Default value is 'low'.
  static int getQrCorrectionLevel(qrCorrectionLevel) {
    switch (qrCorrectionLevel) {
      case 'low':
        return QrErrorCorrectLevel.L;
      case 'medium':
        return QrErrorCorrectLevel.M;
      case 'quartile':
        return QrErrorCorrectLevel.Q;
      case 'high':
        return QrErrorCorrectLevel.H;
      default:
        return QrErrorCorrectLevel.L;
    }
  }

  /// Generate a QR code and displays & save it.
  /// Optionally, print a download link.
  ///
  ///
  /// Default values for [generateQr] and [generateLink] are true.
  static Future<void> generateQrCodeAndLink({
    String? url,
    bool? generateLink = true,
  }) async {
    final qrConfig = Config().config.qrCode;
    final isQrEnable = qrConfig.enabled;
    final isQrShowInConsole = qrConfig.showInCommand;
    final qrImgSize = qrConfig.size;
    final isQrSaveFile = qrConfig.saveFile;
    final qrImgSavePath = qrConfig.savePath;
    final qrCorrectionLevel = qrConfig.errorCorrectionLevel;

    // Directly accessing UploadState and updating it
    final uploadState = UploadState();

    final String? uploadLink = uploadState.uploadLink;

    if (isQrEnable && (uploadLink != null || url != null)) {
      final qrCode = QrCode.fromData(
        data: url ?? uploadLink.toString(),
        errorCorrectLevel: getQrCorrectionLevel(qrCorrectionLevel),
      );
      final qrImg = QrImage(qrCode);

      if (isQrShowInConsole) {
        printQrCode(qrImg);
      }

      // Create an empty image with the same dimensions as the QR code
      final qrImage =
          img.Image(width: qrCode.moduleCount, height: qrCode.moduleCount);

      // Loop through each module of the QR code and set the pixel
      for (int x = 0; x < qrCode.moduleCount; x++) {
        for (int y = 0; y < qrCode.moduleCount; y++) {
          // Set pixel to black (0xFF000000) for dark modules, white (0xFFFFFFFF) for light modules
          qrImage.setPixel(
            x,
            y,
            qrImg.isDark(y, x)
                ? img.ColorFloat16.rgb(255, 255, 255)
                : img.ColorFloat16.rgb(0, 0, 0),
          );
        }
      }
      if (isQrSaveFile) {
        final scaledImage = img.copyResize(
          qrImage,
          width: qrImgSize,
          height: qrImgSize,
        );
        final file = File(qrImgSavePath);
        file.writeAsBytesSync(img.encodePng(scaledImage));
        showHighlight(
          firstMessage: 'QR code saved to',
          highLightmessage: qrImgSavePath,
        );
      }
    }
    if (generateLink == true && (uploadLink != null || url != null)) {
      Helpers.showHighlight(
        firstMessage: '📥 Download the APK here:',
        highLightmessage: url ?? uploadLink,
      );
    }
  }

  /// Print the QR code to the console
  static void printQrCode(QrImage qr) {
    for (int y = 0; y < qr.moduleCount; y++) {
      String row = '';
      for (int x = 0; x < qr.moduleCount; x++) {
        row += qr.isDark(y, x)
            ? '██'
            : '  '; // Use '██' for black and '  ' for white
      }
      print(row);
    }
  }

  static String getFlutterPath() {
    final config = Config().config;
    final flutterPath = config.flutterPath;

    if (flutterPath == null) {
      print(
        '⚠️ Custom Flutter Path configuration not found. We recommend specifying it in the your config yaml file for better functionality.',
      );
      return Kstrings.defaultFlutterBinPath;
    }

    return flutterPath;
  }

  /// Check if Flutter is available in the system
  static Future<bool> checkFlutterAvailability() async {
    try {
      final String flutterPath = getFlutterPath();
      final result = await Process.run(flutterPath, ['--version']);

      if (result.exitCode == 0) {
        return true;
      } else {
        print('Flutter not found: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('Flutter not found: $e');
      return false;
    }
  }

  /// Build the APK using Flutter CLI
  static Future<bool> buildApk() async {
    final String flutterPath = getFlutterPath();

    showLoading("🚀 Starting the build process...");
    final result =
        await Process.run(flutterPath, ['build', 'apk', '--release']);
    stopLoading();

    if (result.exitCode == 0) {
      showHighlight(
        firstMessage: '🎁 APK built successfully',
        highLightmessage: Kstrings.releaseApkPath,
      );
      return true;
    } else {
      showHighlight(
        firstMessage: 'Failed to build APK:',
        highLightmessage: result.stderr,
      );
      return false;
    }
  }

  /// Show Loading spinner
  static void showLoading(String message) {
    final spinnerChars = ['|', '/', '-', '\\'];
    int i = 0;

    // Create the timer and store it
    _loadingTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      stdout.write('\r$message ${spinnerChars[i % spinnerChars.length]}');
      i++;
    });
  }

  /// Stop the Loading spinner
  static void stopLoading() {
    if (_loadingTimer != null) {
      _loadingTimer!.cancel(); // Cancel the spinner timer
      stdout.write('\r'); // Clear the line after stopping
    }
  }

  /// Print a highlighted message in the console.
  static void showHighlight({
    required String firstMessage,
    String? highLightmessage,
    String? lastMessage,
  }) {
    final AnsiPen pen = AnsiPen()..green(bold: true);
    print('$firstMessage ${pen(
      highLightmessage ?? "",
    )}  ${lastMessage ?? ""}');
  }

  static void showUserConfig() {
    final config = Config().config;
    final configPath = Config().configPath.trim();
    final flutterPath =
        config.flutterPath?.trim() ?? "No Custom Flutter Path Found";

    print('\n🔧 Current Configuration Overview\n');

    print('${getStatusEmoji(configPath.isNotEmpty)} Configuration File Path:');
    print(
        '   ${highlight(configPath.isNotEmpty ? configPath : "No configuration file path specified.")}\n');

    print('${getStatusEmoji(flutterPath.isNotEmpty)} Flutter Path:');
    print('   ${highlight(flutterPath)}\n');

    print('☁️ Upload Options:');
    print('   GitHub:');
    print(
        '      ${getStatusEmoji(config.uploadOptions.github.enabled)} Enabled: ${highlight(config.uploadOptions.github.enabled ? "Yes" : "No")}');
    if (config.uploadOptions.github.enabled) {
      print(
          '      Token: ${highlight(config.uploadOptions.github.token ?? "Not set")}');
      print(
          '      Repo: ${highlight(config.uploadOptions.github.repo ?? "Not set")}');
      print('      Tag: ${highlight(config.uploadOptions.github.tag)}\n');
    }

    print('   Google Drive:');
    print(
        '      ${getStatusEmoji(config.uploadOptions.googleDrive.enabled)} Enabled: ${highlight(config.uploadOptions.googleDrive.enabled ? "Yes" : "No")}');
    if (config.uploadOptions.googleDrive.enabled) {
      print(
          '      Client ID: ${highlight(config.uploadOptions.googleDrive.clientId ?? "Not set")}');
      print(
          '      Client Secret: ${highlight(config.uploadOptions.googleDrive.clientSecret ?? "Not set")}\n');
    }

    print('🎨 QR Code Settings:');
    print(
        '   ${getStatusEmoji(config.qrCode.enabled)} QR Code: ${highlight(config.qrCode.enabled ? "Enabled" : "Disabled")}');
    print('   Save Path: ${highlight(config.qrCode.savePath)}');
    print(
        '   Save QR Image: ${highlight(config.qrCode.saveFile ? "Yes" : "No")}');
    print('   Image Size: ${highlight(config.qrCode.size.toString())}');
    print(
        '   Show in Console: ${highlight(config.qrCode.showInCommand ? "Yes" : "No")}');
    print(
        '   Error Correction Level: ${highlight(config.qrCode.errorCorrectionLevel.toString())}\n');

    print(
        '✨ Use this information to ensure your configuration is set up correctly.');
  }

  static String getStatusEmoji(bool isSuccessful) {
    return isSuccessful ? '✅' : '⚠️';
  }

  static String highlight(String text) {
    return '\x1B[36m$text\x1B[0m'; // ANSI escape code for cyan text
  }

  /// For debug print only.
  ///
  /// Make sure to remove all these print before PR or Deployment.
  static void debugPrint(String message) {
    print('Debug Print, Delete me before deploying: $message');
  }
}
