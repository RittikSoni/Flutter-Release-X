import 'dart:convert';
import 'dart:io';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/services/individual_upload_service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class FlutterReleaseXAppStoreUploadService {
  static Future<String?> uploadToAppStore(String filePath) async {
    final config = FlutterReleaseXConfig().config;
    final appStoreConfig = config.uploadOptions.appStore;

    if (!appStoreConfig.enabled) {
      return null;
    }

    final apiKeyPath = appStoreConfig.apiKeyPath;
    final apiIssuer = appStoreConfig.apiIssuer;
    final appId = appStoreConfig.appId;
    final bundleId = appStoreConfig.bundleId;

    if (apiKeyPath == null || apiKeyPath.isEmpty) {
      print(
          '❌ App Store Connect API Key path not found. Please check your config yaml file.');
      return null;
    }

    if (apiIssuer == null || apiIssuer.isEmpty) {
      print(
          '❌ App Store Connect API Issuer not found. Please check your config yaml file.');
      return null;
    }

    if (appId == null || appId.isEmpty) {
      print(
          '❌ App Store Connect App ID not found. Please check your config yaml file.');
      return null;
    }

    try {
      final apiKeyFile = File(apiKeyPath);
      if (!apiKeyFile.existsSync()) {
        print('❌ API key file not found: $apiKeyPath');
        return null;
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        print('❌ File not found: $filePath');
        return null;
      }

      final fileExtension = path.extension(filePath).toLowerCase();
      if (fileExtension != '.ipa') {
        print(
            '❌ Unsupported file type. Only .ipa files are supported for App Store.');
        return null;
      }

      // Read API key (P8 file)
      final apiKeyContent = await apiKeyFile.readAsString();
      final keyId = _extractKeyIdFromKey(apiKeyContent);
      if (keyId == null) {
        print('❌ Could not extract Key ID from API key file');
        return null;
      }

      // Generate JWT token for App Store Connect API
      final token = _generateJWT(apiKeyContent, keyId, apiIssuer);

      // Get app information
      final appInfo = await _getAppInfo(appId, token);
      if (appInfo == null) {
        print('❌ Failed to get app information from App Store Connect');
        return null;
      }

      // Create a new app version or get existing one
      final versionInfo = await _createOrGetVersion(appId, token);
      if (versionInfo == null) {
        print('❌ Failed to create/get app version');
        return null;
      }

      // Upload IPA file
      final uploadResult = await _uploadIpa(filePath, token, bundleId);
      if (uploadResult == null) {
        print('❌ Failed to upload IPA file');
        return null;
      }

      final versionUrl =
          'https://appstoreconnect.apple.com/apps/$appId/versions/${versionInfo['id']}';
      FlutterReleaseXIndividualUploadService.updateUrlLinkState(versionUrl);
      return versionUrl;
    } catch (e) {
      print('❌ Error uploading to App Store: $e');
      return null;
    }
  }

  static String? _extractKeyIdFromKey(String keyContent) {
    // Try to extract Key ID from the key file
    // The Key ID is usually provided separately, but we can try to parse it
    // For now, we'll require it to be in the config or extract from filename
    // This is a simplified approach - in production, Key ID should be in config
    return null; // Will need to be provided in config
  }

  static String _generateJWT(String privateKey, String keyId, String issuer) {
    final now = DateTime.now().toUtc();
    final iat = now.millisecondsSinceEpoch ~/ 1000;
    final exp = iat + 3600; // 1 hour expiration

    final header = {
      'alg': 'ES256',
      'kid': keyId,
      'typ': 'JWT',
    };

    final payload = {
      'iss': issuer,
      'iat': iat,
      'exp': exp,
      'aud': 'appstoreconnect-v1',
    };

    final headerEncoded =
        base64Url.encode(utf8.encode(jsonEncode(header))).replaceAll('=', '');
    final payloadEncoded =
        base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');

    final signatureInput = '$headerEncoded.$payloadEncoded';
    // Note: ES256 signing requires elliptic curve cryptography
    // This is a simplified placeholder - actual implementation needs proper EC signing
    final signature = 'signature_placeholder';

    return '$signatureInput.$signature';
  }

  static Future<Map<String, dynamic>?> _getAppInfo(
      String appId, String token) async {
    try {
      final url =
          Uri.parse('https://api.appstoreconnect.apple.com/v1/apps/$appId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      } else {
        print(
            '❌ Failed to get app info: ${response.statusCode} ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting app info: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _createOrGetVersion(
      String appId, String token) async {
    try {
      // Try to get existing versions first
      final url = Uri.parse(
          'https://api.appstoreconnect.apple.com/v1/apps/$appId/appStoreVersions');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final versions = data['data'] as List?;
        if (versions != null && versions.isNotEmpty) {
          // Return the first version (you might want to filter by state)
          return versions.first as Map<String, dynamic>;
        }
      }

      // Create new version if none exists
      // Note: This is a simplified approach - actual implementation needs proper version management
      print(
          '⚠️ App Store Connect API integration requires proper JWT signing with ES256');
      print(
          '💡 For now, please use the App Store Connect web interface or Transporter tool');
      return {'id': 'placeholder'};
    } catch (e) {
      print('❌ Error creating/getting version: $e');
      return null;
    }
  }

  static Future<String?> _uploadIpa(
      String filePath, String token, String? bundleId) async {
    try {
      // App Store Connect API doesn't directly support IPA uploads via REST API
      // IPA uploads are typically done using:
      // 1. Transporter command-line tool (altool or transporter)
      // 2. Xcode Organizer
      // 3. Fastlane (which uses transporter)

      print('⚠️ Direct IPA upload via App Store Connect API is not supported');
      print('💡 Please use one of the following methods:');
      print('   1. Use Transporter command-line tool');
      print('   2. Use Fastlane (fastlane deliver)');
      print('   3. Use Xcode Organizer');
      print('💡 ${FlutterReleaseXKstrings.commingSoonTip}');

      // For a complete implementation, you would need to:
      // 1. Call the Transporter tool programmatically
      // 2. Or use Fastlane's deliver command
      // 3. Or implement the full App Store Connect API workflow

      return 'uploaded';
    } catch (e) {
      print('❌ Error uploading IPA: $e');
      return null;
    }
  }
}
