import 'dart:convert';
import 'dart:io';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/services/individual_upload_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class FlutterReleaseXGitlabUploadService {
  static Future<String?> uploadToGitlab(String filePath) async {
    final config = FlutterReleaseXConfig().config;
    final gitlabConfig = config.uploadOptions.gitlab;

    if (!gitlabConfig.enabled) {
      return null;
    }

    final token = gitlabConfig.token;
    final projectId = gitlabConfig.projectId;
    final tag = gitlabConfig.tag;
    final host = gitlabConfig.host ?? 'https://gitlab.com';
    final ref = gitlabConfig.ref ?? 'main';

    if (token == null || token.isEmpty) {
      print('❌ GitLab token not found. Please check your config yaml file.');
      return null;
    }

    if (projectId == null || projectId.isEmpty) {
      print(
          '❌ GitLab Project ID not found. Please check your config yaml file.');
      return null;
    }

    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('❌ File not found: $filePath');
        return null;
      }

      final fileName = path.basename(filePath);
      final apiBaseUrl = '$host/api/v4';

      // Check if release exists for the tag
      final existingRelease = await _findReleaseByTag(
          apiBaseUrl, projectId, tag ?? 'v0.0.1', token);

      if (existingRelease != null) {
        // Delete existing release
        await _deleteRelease(apiBaseUrl, projectId, tag ?? 'v0.0.1', token);
      }

      // Create new release
      final release = await _createRelease(
          apiBaseUrl, projectId, tag ?? 'v0.0.1', fileName, token, ref);

      if (release == null) {
        print('❌ Failed to create GitLab release');
        return null;
      }

      // Upload file as release asset
      final downloadUrl = await _uploadReleaseAsset(
          apiBaseUrl, projectId, tag ?? 'v0.0.1', filePath, fileName, token);

      if (downloadUrl != null) {
        FlutterReleaseXIndividualUploadService.updateUrlLinkState(downloadUrl);
        return downloadUrl;
      }

      return null;
    } catch (e) {
      print('❌ Error uploading to GitLab: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _findReleaseByTag(
      String apiBaseUrl, String projectId, String tag, String token) async {
    try {
      final url = Uri.parse(
          '$apiBaseUrl/projects/$projectId/releases/$tag');
      final response = await http.get(
        url,
        headers: {
          'PRIVATE-TOKEN': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null; // Release not found
      } else {
        throw Exception(
            'Failed to find release: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      // If it's a 404, return null
      if (e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  static Future<void> _deleteRelease(
      String apiBaseUrl, String projectId, String tag, String token) async {
    try {
      final url = Uri.parse(
          '$apiBaseUrl/projects/$projectId/releases/$tag');
      final response = await http.delete(
        url,
        headers: {
          'PRIVATE-TOKEN': token,
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('✅ Existing release deleted successfully.');
      } else {
        print(
            '⚠️ Failed to delete existing release: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('⚠️ Error deleting release: $e');
      // Continue anyway
    }
  }

  static Future<Map<String, dynamic>?> _createRelease(
      String apiBaseUrl,
      String projectId,
      String tag,
      String fileName,
      String token,
      String ref) async {
    try {
      final url = Uri.parse('$apiBaseUrl/projects/$projectId/releases');
      final response = await http.post(
        url,
        headers: {
          'PRIVATE-TOKEN': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tag_name': tag,
          'ref': ref, // Required: branch or commit SHA from which to create the tag
          'name': 'Release $tag',
          'description':
              '🚀 Release built using Flutter Release X. For more details, visit: https://pub.dev/packages/flutter_release_x',
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print(
            '❌ Failed to create release: ${response.statusCode} ${response.reasonPhrase}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating release: $e');
      return null;
    }
  }

  static Future<String?> _uploadReleaseAsset(
      String apiBaseUrl,
      String projectId,
      String tag,
      String filePath,
      String fileName,
      String token) async {
    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();

      // GitLab requires base64 encoding for release assets
      final base64Content = base64Encode(fileBytes);

      final url = Uri.parse(
          '$apiBaseUrl/projects/$projectId/releases/$tag/assets/links');
      final response = await http.post(
        url,
        headers: {
          'PRIVATE-TOKEN': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': fileName,
          'url': 'data:application/octet-stream;base64,$base64Content',
        }),
      );

      if (response.statusCode == 201) {
        // Get the release page URL
        final releaseUrl = '$apiBaseUrl/projects/$projectId/releases/$tag';
        return releaseUrl;
      } else {
        // Try alternative method: upload as generic package
        return await _uploadAsPackage(
            apiBaseUrl, projectId, filePath, fileName, token);
      }
    } catch (e) {
      print('❌ Error uploading asset: $e');
      // Try alternative method
      return await _uploadAsPackage(
          apiBaseUrl, projectId, filePath, fileName, token);
    }
  }

  static Future<String?> _uploadAsPackage(
      String apiBaseUrl,
      String projectId,
      String filePath,
      String fileName,
      String token) async {
    try {
      final file = File(filePath);
      final packageName = 'flutter-release-x';
      final packageVersion = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload as generic package
      final url = Uri.parse(
          '$apiBaseUrl/projects/$projectId/packages/generic/$packageName/$packageVersion/$fileName');
      final request = http.MultipartRequest('PUT', url)
        ..headers.addAll({
          'PRIVATE-TOKEN': token,
        })
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          await file.readAsBytes(),
          filename: fileName,
          contentType: MediaType('application', 'octet-stream'),
        ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Return the package download URL
        return url.toString();
      } else {
        print(
            '❌ Failed to upload package: ${response.statusCode} ${response.reasonPhrase}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading as package: $e');
      return null;
    }
  }
}
