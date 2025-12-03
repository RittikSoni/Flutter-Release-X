import 'dart:io';
import 'dart:convert';
import 'package:flutter_release_x/services/individual_upload_service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class FlutterReleaseXDiawiUploadService {
  final String apiToken;
  final bool wallOfApps;
  final bool findByUdid;
  final bool? installationNotifications;
  final String? password;
  final String? comment;
  final String? callbackUrl;

  // Polling configuration
  static const int pollIntervalSeconds = 3;
  static const int maxPollAttempts = 100; // 5 minutes with 3-second intervals

  FlutterReleaseXDiawiUploadService({
    required this.apiToken,
    this.wallOfApps = false,
    this.findByUdid = false,
    this.installationNotifications = false,
    this.callbackUrl,
    this.password,
    this.comment,
  });

  /// Main upload method that handles both APK and IPA files
  Future<String?> uploadToDiawi(String filePath) async {
    try {
      // Validate file exists
      final file = File(filePath);
      if (!file.existsSync()) {
        print('❌ File not found: $filePath');
        return null;
      }

      // Detect file type
      final fileExtension = path.extension(filePath).toLowerCase();
      if (fileExtension != '.apk' && fileExtension != '.ipa') {
        print(
            '❌ Unsupported file type. Only .apk and .ipa files are supported.');
        return null;
      }

      print(
          '📤 Uploading ${fileExtension.substring(1).toUpperCase()} to Diawi...');

      // Step 1: Upload file and get job token
      final jobToken = await _uploadFile(file);
      if (jobToken == null) {
        print('❌ Failed to upload file to Diawi');
        return null;
      }

      print('✅ File uploaded successfully. Job token: $jobToken');
      print('⏳ Processing upload... This may take a few minutes.');

      // Step 2: Poll for status
      final downloadLink = await _pollForStatus(jobToken);
      if (downloadLink != null) {
        print('✅ Upload completed successfully!');
        FlutterReleaseXIndividualUploadService.updateUrlLinkState(downloadLink);
        return downloadLink;
      } else {
        print('❌ Failed to get download link from Diawi');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading to Diawi: $e');
      return null;
    }
  }

  /// Upload file to Diawi and get job token
  Future<String?> _uploadFile(File file) async {
    try {
      final uri = Uri.parse('https://upload.diawi.com/');
      final request = http.MultipartRequest('POST', uri);

      // Add token
      request.fields['token'] = apiToken;

      // Add optional parameters
      if (wallOfApps) {
        request.fields['wall_of_apps'] = '1';
      }
      if (findByUdid) {
        request.fields['find_by_udid'] = '1';
      }
      if (callbackUrl != null && callbackUrl!.isNotEmpty) {
        request.fields['callback_url'] = callbackUrl!;
      }
      if (installationNotifications != null && installationNotifications!) {
        request.fields['installation_notifications'] = '1';
      }
      if (password != null && password!.isNotEmpty) {
        request.fields['password'] = password!;
      }
      if (comment != null && comment!.isNotEmpty) {
        request.fields['comment'] = comment!;
      }

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: path.basename(file.path),
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['job'] as String?;
      } else {
        print('❌ Upload failed with status code: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error during file upload: $e');
      return null;
    }
  }

  /// Poll Diawi API for upload status
  Future<String?> _pollForStatus(String jobToken) async {
    try {
      final uri = Uri.parse('https://upload.diawi.com/status');

      for (int attempt = 1; attempt <= maxPollAttempts; attempt++) {
        await Future.delayed(Duration(seconds: pollIntervalSeconds));

        final response = await http.get(
          uri.replace(queryParameters: {'token': apiToken, 'job': jobToken}),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          final status = jsonResponse['status'];

          if (status == 2000) {
            // Success - file processed
            final hash = jsonResponse['hash'];
            return 'https://i.diawi.com/$hash';
          } else if (status == 2001) {
            // Still processing
            stdout.write(
                '\r⏳ Processing... (${attempt * pollIntervalSeconds}s elapsed)');
            continue;
          } else if (status == 4000) {
            // Error
            print(
                '\n❌ Diawi processing error: ${jsonResponse['message'] ?? 'Unknown error'}');
            return null;
          } else {
            // Unknown status
            print('\n⚠️ Unknown status: $status');
            continue;
          }
        } else {
          print('\n❌ Status check failed with code: ${response.statusCode}');
          return null;
        }
      }

      print(
          '\n❌ Timeout: Upload processing took too long (${maxPollAttempts * pollIntervalSeconds} seconds)');
      return null;
    } catch (e) {
      print('\n❌ Error polling status: $e');
      return null;
    }
  }

  /// Upload APK specifically
  Future<String?> uploadApk(String apkPath) async {
    if (!apkPath.toLowerCase().endsWith('.apk')) {
      print('❌ File is not an APK');
      return null;
    }
    return uploadToDiawi(apkPath);
  }

  /// Upload IPA specifically
  Future<String?> uploadIpa(String ipaPath) async {
    if (!ipaPath.toLowerCase().endsWith('.ipa')) {
      print('❌ File is not an IPA');
      return null;
    }
    return uploadToDiawi(ipaPath);
  }
}
