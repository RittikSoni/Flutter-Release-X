import 'dart:io';

import 'package:flutter_release_x/constants/kenums.dart';
import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:flutter_release_x/services/upload_services.dart';

Future<void> flutterReleaseXpromptUploadOption(String artifactPath) async {
  final isGitHubAvailable = FlutterReleaseXHelpers.isUploadOptionAvailable(
      FlutterReleaseXKenumUploadOptions.github);
  final isGoogleDriveAvailable = FlutterReleaseXHelpers.isUploadOptionAvailable(
      FlutterReleaseXKenumUploadOptions.googleDrive);

  print('------------------------');
  print('Choose an upload option:');
  print('------------------------');
  print(
      '1. GitHub Releases ${isGitHubAvailable ? "" : FlutterReleaseXHelpers.highlight("(❌ Not Configured)")}');
  print(
      '2. Google Drive ${isGoogleDriveAvailable ? "" : FlutterReleaseXHelpers.highlight("(❌ Not Configured)")}');
  print('3. AWS');
  print('4. Gitlab');
  print('5. Play Store');
  print('6. App Store');
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
      await FlutterReleaseXUploadService.uploadToAWS(artifactPath);
      exit(0);
    case '4':
      await FlutterReleaseXUploadService.uploadToGitlab(artifactPath);
      exit(0);
    case '5':
      await FlutterReleaseXUploadService.uploadToPlayStore(artifactPath);
      exit(0);
    case '6':
      await FlutterReleaseXUploadService.uploadToAppStore(artifactPath);
      exit(0);
    default:
      print('Invalid choice. Please try again.');
      exit(0);
  }
}
