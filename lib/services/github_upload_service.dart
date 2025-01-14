import 'dart:convert';
import 'dart:io';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/services/individual_upload_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class GitHubUploaderService {
  static Future<void> uploadToGitHub(String apkPath) async {
    final config = Config().config;

    final gitHubConfig = config.uploadOptions.github;
    final gitHubToken = config.uploadOptions.github.token;
    final gitHubRepo = config.uploadOptions.github.repo;
    final gitHubTag = config.uploadOptions.github.tag;

    if (!gitHubConfig.enabled) {
      return;
    } else if (gitHubToken == null) {
      print('❌ GitHub token not found. Please check your config yaml file.');
      return;
    } else if (gitHubRepo == null) {
      print('❌ GitHub Repo not found. Please check your config yaml file.');
      return;
    }

    final tag = gitHubTag; // Use a dynamic versioning system if needed
    final releaseName = 'Release $tag';
    final releaseDescription =
        '🚀 Release built using Flutter Release X. For more details, visit: https://pub.dev/packages/flutter_release_x';
    final fileName = 'app-release.apk';

    try {
      final release = await _findReleaseByTag(gitHubRepo, tag, gitHubToken);
      if (release != null) {
        // If release exists, delete it and re-create the release
        await _deleteRelease(gitHubRepo, release['id'], gitHubToken);
        await _createAndUploadNewRelease(gitHubRepo, tag, releaseName,
            releaseDescription, apkPath, fileName, gitHubToken);
      } else {
        // If release doesn't exist, create a new release
        await _createAndUploadNewRelease(gitHubRepo, tag, releaseName,
            releaseDescription, apkPath, fileName, gitHubToken);
      }
    } catch (e) {
      print('❌ Error: $e');
      exit(0);
    }
  }

  static Future<Map<String, dynamic>?> _findReleaseByTag(
      String repo, String tag, String token) async {
    final url = 'https://api.github.com/repos/$repo/releases/tags/$tag';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
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
  }

  static Future<void> _deleteRelease(
      String repo, int releaseId, String token) async {
    final url = 'https://api.github.com/repos/$repo/releases/$releaseId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 204) {
      print('✅ Existing release deleted successfully.');
    } else {
      print(
          '❌ Failed to delete the release: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  static Future<void> _createAndUploadNewRelease(
    String repo,
    String tag,
    String releaseName,
    String releaseDescription,
    String apkPath,
    String fileName,
    String token,
  ) async {
    final releaseUrl = 'https://api.github.com/repos/$repo/releases';
    final response = await http.post(
      Uri.parse(releaseUrl),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
      body: jsonEncode({
        'tag_name': tag,
        'name': releaseName,
        'body': releaseDescription,
        'draft': false,
        'prerelease': false,
      }),
    );

    if (response.statusCode == 201) {
      final releaseData = jsonDecode(response.body);
      await _uploadApkToRelease(
          releaseData['upload_url'], apkPath, fileName, token);
    } else {
      print(
          '❌ Failed to create release: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  static Future<void> _uploadApkToRelease(
      String uploadUrl, String apkPath, String fileName, String token) async {
    final url = uploadUrl.replaceAll('{?name,label}', '?name=$fileName');
    final apkFile = File(apkPath);

    // Create a multipart request
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll({
        'Authorization': 'token $token',
      })
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        await apkFile.readAsBytes(),
        filename: fileName,
        contentType: MediaType('application', 'octet-stream'),
      ));

    final response = await request.send();

    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final uploadData = jsonDecode(responseBody);
      final downloadUrl = uploadData['browser_download_url'];
      print('✅ APK uploaded successfully to GitHub.');

      IndividualUploadService.updateUrlLinkState(downloadUrl);
    } else {
      print(
          '❌ Failed to upload APK: ${response.statusCode} ${response.reasonPhrase}');
    }
  }
}
