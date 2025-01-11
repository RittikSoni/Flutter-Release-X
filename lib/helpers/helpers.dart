import 'dart:async';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/state_management/upload_state.dart';
import 'package:qr/qr.dart';
import 'package:image/image.dart' as img;

class Helpers {
  /// Store the timer for stopping later
  static Timer? _loadingTimer;

  /// Generate a QR code and displays & save it.
  /// Optionally, print a download link.
  ///
  ///
  /// Default values for [generateQr] and [generateLink] are true.
  static Future<void> generateQrCodeAndLink({
    String? url,
    bool? generateQr = true,
    bool? generateLink = true,
  }) async {
    // Directly accessing UploadState and updating it
    final uploadState = UploadState();

    final String? uploadLink = uploadState.uploadLink;

    if (generateQr == true && (uploadLink != null || url != null)) {
      final qrCode = QrCode.fromData(
        data: url ?? uploadLink.toString(),
        errorCorrectLevel: QrErrorCorrectLevel.L,
      );
      final qrImg = QrImage(qrCode);
      printQrCode(qrImg);

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

      final scaledImage = img.copyResize(qrImage, width: 256, height: 256);
      final file = File(Kstrings.qrCodeSavePath);
      file.writeAsBytesSync(img.encodePng(scaledImage));
      showHighlight(
        firstMessage: 'QR code saved to',
        highLightmessage: Kstrings.qrCodeSavePath,
      );
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

  static String? getFlutterPath() {
    final config = Config().config;

    if (config.flutterPath == null) {
      print(
        '⚠️ Custom Flutter Path configuration not found. We recommend specifying it in the config.yaml file for better functionality.',
      );
      return null;
    }

    final flutterPath = config.flutterPath;
    return flutterPath;
  }

  /// Check if Flutter is available in the system
  static Future<bool> checkFlutterAvailability() async {
    try {
      final String? flutterPath = getFlutterPath();
      final result = await Process.run(flutterPath ?? 'flutter', ['--version']);

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
    final String? flutterPath = getFlutterPath();
    if (flutterPath == null) {
      return false;
    }
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
    print('🔧 Current configuration file path: ${Config().configPath}');
    print('Current configuration:');
    print(
        'Flutter Path: ${Config().config.flutterPath ?? "No Custom Flutter Path Found."}');
    print('Upload Options:');
    print('  GitHub Enabled: ${Config().config.uploadOptions.github.enabled}');
    print(
        '  Google Drive Enabled: ${Config().config.uploadOptions.googleDrive.enabled}');
    print('QR Code Settings:');
    print('  Enabled: ${Config().config.qrCode.enabled}');
    print('  Save Path: ${Config().config.qrCode.savePath}');
  }

  /// For debug print only.
  ///
  /// Make sure to remove all these print before PR or Deployment.
  static void debugPrint(String message) {
    print('Debug Print, Delete me before deploying: $message');
  }
}
