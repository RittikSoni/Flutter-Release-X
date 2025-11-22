import 'dart:io';

import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:flutter_release_x/services/github_upload_service.dart';
import 'package:flutter_release_x/services/google_drive_upload_service.dart';

class FlutterReleaseXUploadService {
  static Future<void> uploadToGitHub(String artifactPath) async {
    FlutterReleaseXHelpers.showLoading('☁️ Uploading APK to GitHub...');
    await FlutterReleaseXGitHubUploaderService.uploadToGitHub(artifactPath);
    FlutterReleaseXHelpers.stopLoading();
  }

  static Future<void> uploadToGoogleDrive(String artifactPath) async {
    final config = FlutterReleaseXConfig().config;

    final googleDriveConfig = config.uploadOptions.googleDrive;
    final clientId = googleDriveConfig.clientId;
    final clientSecret = googleDriveConfig.clientSecret;

    if (!googleDriveConfig.enabled) {
      return;
    } else if (clientId == null) {
      print(
          '❌ Google Drive Client ID not found. Please check your config yaml file.');
      return;
    } else if (clientSecret == null) {
      print(
          '❌ Google Drive Client Secret not found. Please check your config yaml file.');
      return;
    }

    final uploader = FlutterReleaseXGoogleDriveUploader(
      clientId: clientId,
      clientSecret: clientSecret,
    );

    final bool isAuthenticated = await uploader.authenticate();
    if (isAuthenticated) {
      FlutterReleaseXHelpers.showLoading('☁️ Uploading APK to Google Drive...');

      await uploader.uploadToGoogleDrive(artifactPath);
      FlutterReleaseXHelpers.stopLoading();
    } else {
      print('Authentication failed. Please try again.');
      exit(0);
    }
  }

  static Future<void> uploadToAWS(String apkPath) async {
    print(
        '☁️ AWS upload coming soon—stay tuned! 💡 ${FlutterReleaseXKstrings.commingSoonTip}');
    // TODO: Implement AWS API upload logic
  }

  static Future<void> uploadToGitlab(String apkPath) async {
    print(
        '📱 Gitlab upload coming soon—stay tuned! 💡 ${FlutterReleaseXKstrings.commingSoonTip}');
    // TODO: Implement Gitlab API upload logic
  }

  static Future<void> uploadToPlayStore(String apkPath) async {
    print(
        '📱 Google Play Store upload coming soon—stay tuned! 💡 ${FlutterReleaseXKstrings.commingSoonTip}');
    // TODO: Implement Google Playstore API upload logic
  }

  static Future<void> uploadToAppStore(String apkPath) async {
    print(
        '🍎 App Store upload coming soon—stay tuned! 💡 ${FlutterReleaseXKstrings.commingSoonTip}');
    // TODO: Implement App Store API upload logic
  }
}
