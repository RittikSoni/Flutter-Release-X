import 'dart:io';

import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:flutter_release_x/services/github_upload_service.dart';
import 'package:flutter_release_x/services/google_drive_upload_service.dart';
import 'package:flutter_release_x/services/diawi_upload_service.dart';
import 'package:flutter_release_x/services/aws_upload_service.dart';
import 'package:flutter_release_x/services/gitlab_upload_service.dart';
import 'package:flutter_release_x/services/play_store_upload_service.dart';
import 'package:flutter_release_x/services/app_store_upload_service.dart';

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

  static Future<void> uploadToDiawi(String artifactPath) async {
    final config = FlutterReleaseXConfig().config;

    final diawiConfig = config.uploadOptions.diawi;
    final token = diawiConfig.token;
    final installationNotifications = diawiConfig.installationNotifications;
    final password = diawiConfig.password;
    final comment = diawiConfig.comment;

    if (!diawiConfig.enabled) {
      return;
    } else if (token == null || token.isEmpty) {
      print('❌ Diawi API Token not found. Please check your config yaml file.');
      return;
    }

    final uploader = FlutterReleaseXDiawiUploadService(
      apiToken: token,
      wallOfApps: diawiConfig.wallOfApps ?? false,
      findByUdid: diawiConfig.findByUdid ?? false,
      installationNotifications: installationNotifications ?? false,
      password: password,
      comment: comment,
      callbackUrl: diawiConfig.callbackUrl,
    );

    FlutterReleaseXHelpers.showLoading('☁️ Uploading to Diawi...');
    final link = await uploader.uploadToDiawi(artifactPath);
    FlutterReleaseXHelpers.stopLoading();

    if (link != null) {
      print('✅ Successfully uploaded to Diawi!');
      print('🔗 Download Link: $link');
    } else {
      print('❌ Failed to upload to Diawi.');
    }
  }

  static Future<void> uploadToAWS(String artifactPath) async {
    final config = FlutterReleaseXConfig().config;
    final awsConfig = config.uploadOptions.aws;

    if (!awsConfig.enabled) {
      return;
    }

    FlutterReleaseXHelpers.showLoading('☁️ Uploading to AWS...');
    final link =
        await FlutterReleaseXAWSUploadService.uploadToAWS(artifactPath);
    FlutterReleaseXHelpers.stopLoading();

    if (link != null) {
      print('✅ Successfully uploaded to AWS!');
      print('🔗 Download Link: $link');
    } else {
      print('❌ Failed to upload to AWS.');
    }
  }

  static Future<void> uploadToGitlab(String artifactPath) async {
    final config = FlutterReleaseXConfig().config;
    final gitlabConfig = config.uploadOptions.gitlab;

    if (!gitlabConfig.enabled) {
      return;
    }

    FlutterReleaseXHelpers.showLoading('☁️ Uploading to GitLab...');
    final link =
        await FlutterReleaseXGitlabUploadService.uploadToGitlab(artifactPath);
    FlutterReleaseXHelpers.stopLoading();

    if (link != null) {
      print('✅ Successfully uploaded to GitLab!');
      print('🔗 Download Link: $link');
    } else {
      print('❌ Failed to upload to GitLab.');
    }
  }

  static Future<void> uploadToPlayStore(String artifactPath) async {
    final config = FlutterReleaseXConfig().config;
    final playStoreConfig = config.uploadOptions.playStore;

    if (!playStoreConfig.enabled) {
      return;
    }

    FlutterReleaseXHelpers.showLoading('📱 Uploading to Google Play Store...');
    final result =
        await FlutterReleaseXPlayStoreUploadService.uploadToPlayStore(
            artifactPath);
    FlutterReleaseXHelpers.stopLoading();

    if (result != null) {
      print('✅ Successfully uploaded to Google Play Store!');
      print('🔗 Release: $result');
    } else {
      print('❌ Failed to upload to Google Play Store.');
    }
  }

  static Future<void> uploadToAppStore(String artifactPath) async {
    final config = FlutterReleaseXConfig().config;
    final appStoreConfig = config.uploadOptions.appStore;

    if (!appStoreConfig.enabled) {
      return;
    }

    FlutterReleaseXHelpers.showLoading('🍎 Uploading to App Store...');
    final result = await FlutterReleaseXAppStoreUploadService.uploadToAppStore(
        artifactPath);
    FlutterReleaseXHelpers.stopLoading();

    if (result != null) {
      print('✅ Successfully uploaded to App Store!');
      print('🔗 Version: $result');
    } else {
      print('❌ Failed to upload to App Store.');
    }
  }
}
