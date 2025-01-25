import 'dart:io';

import 'package:flutter_release_x/constants/kenums.dart';
import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:flutter_release_x/services/upload_services.dart';

Future<void> promptUploadOption(String apkPath) async {
  final isGitHubAvailable =
      Helpers.isUploadOptionAvailable(KenumUploadOptions.github);
  final isGoogleDriveAvailable =
      Helpers.isUploadOptionAvailable(KenumUploadOptions.googleDrive);

  print('------------------------');
  print('Choose an upload option:');
  print('------------------------');
  print(
      '1. GitHub Releases ${isGitHubAvailable ? "" : Helpers.highlight("(❌ Not Configured)")}');
  print(
      '2. Google Drive ${isGoogleDriveAvailable ? "" : Helpers.highlight("(❌ Not Configured)")}');
  print('3. AWS');
  print('4. Gitlab');
  print('5. Play Store');
  print('6. App Store');
  stdout.write('Enter the number of your choice: ');

  String? choice = stdin.readLineSync();
  switch (choice) {
    case '1':
      if (isGitHubAvailable) {
        await UploadService.uploadToGitHub(apkPath);
        break;
      }
      print('Please configure it first.');
      exit(0);
    case '2':
      if (isGoogleDriveAvailable) {
        await UploadService.uploadToGoogleDrive(apkPath);
        break;
      }
      print('Please configure it first.');
      exit(0);
    case '3':
      await UploadService.uploadToAWS(apkPath);
      exit(0);
    case '4':
      await UploadService.uploadToGitlab(apkPath);
      exit(0);
    case '5':
      await UploadService.uploadToPlayStore(apkPath);
      exit(0);
    case '6':
      await UploadService.uploadToAppStore(apkPath);
      exit(0);
    default:
      print('Invalid choice. Please try again.');
      exit(0);
  }
}
