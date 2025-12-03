import 'dart:io';

import 'package:flutter_release_x/constants/kenums.dart';
import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:flutter_release_x/services/upload_services.dart';

Future<void> flutterReleaseXpromptUploadOption(String artifactPath) async {
  final isGitHubAvailable = FlutterReleaseXHelpers.isUploadOptionAvailable(
      FlutterReleaseXKenumUploadOptions.github);
  final isGoogleDriveAvailable = FlutterReleaseXHelpers.isUploadOptionAvailable(
      FlutterReleaseXKenumUploadOptions.googleDrive);
  final isDiawiAvailable = FlutterReleaseXHelpers.isUploadOptionAvailable(
      FlutterReleaseXKenumUploadOptions.diawi);
  final isAWSAvailable = FlutterReleaseXHelpers.isUploadOptionAvailable(
      FlutterReleaseXKenumUploadOptions.aws);
  final isGitlabAvailable = FlutterReleaseXHelpers.isUploadOptionAvailable(
      FlutterReleaseXKenumUploadOptions.gitlab);
  final isPlayStoreAvailable = FlutterReleaseXHelpers.isUploadOptionAvailable(
      FlutterReleaseXKenumUploadOptions.playStore);
  final isAppStoreAvailable = FlutterReleaseXHelpers.isUploadOptionAvailable(
      FlutterReleaseXKenumUploadOptions.appStore);

  print('------------------------');
  print('Choose an upload option:');
  print('------------------------');
  print(
      '1. GitHub Releases ${isGitHubAvailable ? "" : FlutterReleaseXHelpers.highlight("(❌ Not Configured)")}');
  print(
      '2. Google Drive ${isGoogleDriveAvailable ? "" : FlutterReleaseXHelpers.highlight("(❌ Not Configured)")}');
  print(
      '3. Diawi ${isDiawiAvailable ? "" : FlutterReleaseXHelpers.highlight("(❌ Not Configured)")}');
  print(
      '4. AWS ${isAWSAvailable ? "" : FlutterReleaseXHelpers.highlight("(❌ Not Configured)")}');
  print(
      '5. Gitlab ${isGitlabAvailable ? "" : FlutterReleaseXHelpers.highlight("(❌ Not Configured)")}');
  print(
      '6. Play Store ${isPlayStoreAvailable ? "" : FlutterReleaseXHelpers.highlight("(❌ Not Configured)")}');
  print(
      '7. App Store ${isAppStoreAvailable ? "" : FlutterReleaseXHelpers.highlight("(❌ Not Configured)")}');
  stdout.write('Enter the number of your choice: ');

  String? choice = stdin.readLineSync();
  switch (choice) {
    case '1':
      if (isGitHubAvailable) {
        await FlutterReleaseXUploadService.uploadToGitHub(artifactPath);
        break;
      }
      print('Please configure it first.');
      exit(0);
    case '2':
      if (isGoogleDriveAvailable) {
        await FlutterReleaseXUploadService.uploadToGoogleDrive(artifactPath);
        break;
      }
      print('Please configure it first.');
      exit(0);
    case '3':
      if (isDiawiAvailable) {
        await FlutterReleaseXUploadService.uploadToDiawi(artifactPath);
        break;
      }
      print('Please configure it first.');
      exit(0);
    case '4':
      if (isAWSAvailable) {
        await FlutterReleaseXUploadService.uploadToAWS(artifactPath);
        break;
      }
      print('Please configure it first.');
      exit(0);
    case '5':
      if (isGitlabAvailable) {
        await FlutterReleaseXUploadService.uploadToGitlab(artifactPath);
        break;
      }
      print('Please configure it first.');
      exit(0);
    case '6':
      if (isPlayStoreAvailable) {
        await FlutterReleaseXUploadService.uploadToPlayStore(artifactPath);
        break;
      }
      print('Please configure it first.');
      exit(0);
    case '7':
      if (isAppStoreAvailable) {
        await FlutterReleaseXUploadService.uploadToAppStore(artifactPath);
        break;
      }
      print('Please configure it first.');
      exit(0);
    default:
      print('Invalid choice. Please try again.');
      exit(0);
  }
}
