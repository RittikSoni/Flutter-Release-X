import 'dart:io';

import 'package:flutter_release_x/services/upload_services.dart';

Future<void> promptUploadOption(String apkPath) async {
  print('Choose an upload option:');
  print('1. GitHub Releases');
  print('2. Google Drive');
  print('3. AWS');
  print('4. Play Store');
  print('5. App Store');
  stdout.write('Enter the number of your choice: ');

  String? choice = stdin.readLineSync();
  switch (choice) {
    case '1':
      await UploadService.uploadToGitHub(apkPath);
      break;
    case '2':
      await UploadService.uploadToGoogleDrive(apkPath);
      break;
    case '3':
      await UploadService.uploadToAWS(apkPath);
      break;
    case '4':
      await UploadService.uploadToPlayStore(apkPath);
      break;
    case '5':
      await UploadService.uploadToAppStore(apkPath);
      break;
    default:
      print('Invalid choice. Please try again.');
  }
}
