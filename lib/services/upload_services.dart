import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:flutter_release_x/services/github_upload_service.dart';
import 'package:flutter_release_x/services/google_drive_upload_service.dart';

class UploadService {
  static Future<void> uploadToGitHub(String apkPath) async {
    Helpers.showLoading('☁️ Uploading APK to GitHub...');
    await GitHubUploaderService.uploadToGitHub(apkPath);
    Helpers.stopLoading();
  }

  static Future<void> uploadToGoogleDrive(String apkPath) async {
    Config.loadConfig();
    final config = Config.config;

    if (config == null ||
        !config['upload_options'].containsKey('google_drive')) {
      print(
          '❌ Google Drive configuration not found. Please check your config.yaml file.');
      return;
    }

    final clientId = config['upload_options']['google_drive']['client_id'];
    final clientSecret =
        config['upload_options']['google_drive']['client_secret'];

    final uploader = GoogleDriveUploader(
      clientId: clientId,
      clientSecret: clientSecret,
    );

    final bool isAuthenticated = await uploader.authenticate();
    if (isAuthenticated) {
      Helpers.showLoading('☁️ Uploading APK to Google Drive...');

      await uploader.uploadToGoogleDrive(Kstrings.releaseApkPath);
      Helpers.stopLoading();
    } else {
      print('Authentication failed. Please try again.');
      return;
    }
  }

  static Future<void> uploadToAWS(String apkPath) async {
    print('Uploading to Dropbox...');
    // TODO: Implement AWS API upload logic
  }

  static Future<void> uploadToPlayStore(String apkPath) async {
    print('Uploading to Play Store...');
    // TODO: Implement Google Playstore API upload logic
  }

  static Future<void> uploadToAppStore(String apkPath) async {
    print('Uploading to App Store...');
    // TODO: Implement App Store API upload logic
  }
}
