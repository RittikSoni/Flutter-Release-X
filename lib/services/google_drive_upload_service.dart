// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:flutter_release_x/services/individual_upload_service.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class FlutterReleaseXGoogleDriveUploader {
  final String clientId;
  final String clientSecret;
  late auth.AutoRefreshingAuthClient _client;
  late drive.DriveApi _driveApi;

  FlutterReleaseXGoogleDriveUploader(
      {required this.clientId, required this.clientSecret});

  // Path to store the credentials file
  final String credentialsFilePath =
      FlutterReleaseXKstrings.googleDriveCredentialsSavePath;

  // Step 1: Authenticate via OAuth2
  Future<bool> authenticate() async {
    final credentials = auth.ClientId(clientId, clientSecret);

    // Check if credentials are already stored
    if (await File(credentialsFilePath).exists()) {
      try {
        // Read the credentials from the file
        final jsonString = await File(credentialsFilePath).readAsString();
        final jsonCredentials =
            auth.AccessCredentials.fromJson(json.decode(jsonString));

        // Create an authenticated client using the stored credentials
        _client = auth.autoRefreshingClient(
          credentials,
          jsonCredentials,
          http.Client(),
        );
        _driveApi = drive.DriveApi(_client);

        print('🔐 Reusing existing credentials. Authentication successful!');
        return true;
      } catch (e) {
        print('Error using stored credentials: $e');
        // Fall back to requesting new credentials if there is an error
      }
    }

    try {
      // Request new credentials if no valid stored credentials
      _client = await auth.clientViaUserConsent(
        credentials,
        [drive.DriveApi.driveFileScope],
        (url) {
          FlutterReleaseXHelpers.showHighlight(
            firstMessage: 'Please visit the following URL to authenticate:',
            highLightmessage: url,
          );
        },
      );
      _driveApi = drive.DriveApi(_client);

      // Save the credentials for future use
      final accessCredentials = _client.credentials;
      await File(credentialsFilePath)
          .writeAsString(json.encode(accessCredentials.toJson()));

      print('🔐 Authentication successful and credentials saved!');
      return true;
    } catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }

  /// Create FRX folder
  /// takes [name] folder name
  Future<String> _getOrCreateFolder(String name) async {
    // 1) Try to find an existing folder named `name`
    final q =
        "mimeType='application/vnd.google-apps.folder' and name='$name' and trashed=false";
    final list = await _driveApi.files.list(q: q, $fields: 'files(id, name)');
    if (list.files != null && list.files!.isNotEmpty) {
      return list.files!.first.id!;
    }

    // 2) Otherwise, create it
    final folder = drive.File()
      ..name = name
      ..mimeType = 'application/vnd.google-apps.folder';
    final created = await _driveApi.files.create(folder);
    return created.id!;
  }

// Step 4: Upload the file to Google Drive
  Future<void> uploadToGoogleDrive(String filePath) async {
    if (_driveApi == null) {
      print(
          'Google Drive API client not initialized. Please authenticate first.');
      return;
    }

    // === ensure FRX folder exists (or get its ID) ===
    final folderId = await _getOrCreateFolder('FRX');

    final file = File(filePath);
    final media = drive.Media(file.openRead(), file.lengthSync());

    final driveFile = drive.File()
      ..name = path.basename(filePath)
      ..mimeType = 'application/vnd.android.package-archive'
      ..parents = [folderId];

    try {
      // Upload the file
      final uploadedFile =
          await _driveApi.files.create(driveFile, uploadMedia: media);

      print('Upload successful to Google Drive!');

      // Set file permissions to make it shareable
      final permission = drive.Permission()
        ..type = 'anyone'
        ..role = 'reader';

      await _driveApi.permissions.create(
        permission,
        uploadedFile.id!,
      );

      // Retrieve the updated file metadata to get the webContentLink
      final updatedFile = await _driveApi.files.get(
        uploadedFile.id!,
        $fields: 'webContentLink',
      ) as drive.File;

      // Print the uploaded file's link
      if (updatedFile.webContentLink != null) {
        FlutterReleaseXIndividualUploadService.updateUrlLinkState(
            updatedFile.webContentLink!);
      } else {
        print('Upload link not available.');
      }
    } catch (e) {
      print('Error uploading to Google Drive: $e');
      exit(0);
    }
  }
}
