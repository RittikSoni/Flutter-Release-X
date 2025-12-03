import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/services/individual_upload_service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class FlutterReleaseXAWSUploadService {
  static Future<String?> uploadToAWS(String filePath) async {
    final config = FlutterReleaseXConfig().config;
    final awsConfig = config.uploadOptions.aws;

    if (!awsConfig.enabled) {
      return null;
    }

    final accessKeyId = awsConfig.accessKeyId;
    final secretAccessKey = awsConfig.secretAccessKey;
    final region = awsConfig.region ?? 'us-east-1';
    final bucketName = awsConfig.bucketName;
    final keyPrefix = awsConfig.keyPrefix ?? '';

    if (accessKeyId == null || secretAccessKey == null) {
      print(
          '❌ AWS Access Key ID or Secret Access Key not found. Please check your config yaml file.');
      return null;
    }

    if (bucketName == null) {
      print('❌ AWS Bucket Name not found. Please check your config yaml file.');
      return null;
    }

    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('❌ File not found: $filePath');
        return null;
      }

      final fileName = path.basename(filePath);
      // Build the S3 key - ensure no leading slash
      final key = keyPrefix.isEmpty
          ? 'flutter-release-x/${DateTime.now().millisecondsSinceEpoch}_$fileName'
          : keyPrefix.endsWith('/')
              ? '$keyPrefix$fileName'
              : '$keyPrefix/$fileName';

      final fileBytes = await file.readAsBytes();
      final contentType = _getContentType(filePath);

      // Generate AWS Signature Version 4
      final now = DateTime.now().toUtc();
      final dateStamp = _formatDate(now);
      final amzDate = _formatDateTime(now);

      final host = '$bucketName.s3.$region.amazonaws.com';

      // For canonical URI, use the key as-is (AWS expects unencoded in signature)
      // For the actual URL, we'll let Uri.parse handle encoding
      final canonicalUri = '/$key';
      final canonicalQueryString = '';
      final canonicalHeaders = 'host:$host\nx-amz-date:$amzDate\n';
      final signedHeaders = 'host;x-amz-date';
      final payloadHash = sha256.convert(fileBytes).toString();

      final canonicalRequest = 'PUT\n'
          '$canonicalUri\n'
          '$canonicalQueryString\n'
          '$canonicalHeaders\n'
          '$signedHeaders\n'
          '$payloadHash';

      final algorithm = 'AWS4-HMAC-SHA256';
      final credentialScope = '$dateStamp/$region/s3/aws4_request';
      final stringToSign = '$algorithm\n'
          '$amzDate\n'
          '$credentialScope\n'
          '${sha256.convert(utf8.encode(canonicalRequest))}';

      // Calculate signature
      final kDate = _hmacSha256(
          utf8.encode('AWS4$secretAccessKey'), utf8.encode(dateStamp));
      final kRegion = _hmacSha256(kDate, utf8.encode(region));
      final kService = _hmacSha256(kRegion, utf8.encode('s3'));
      final kSigning = _hmacSha256(kService, utf8.encode('aws4_request'));
      final signature = _hmacSha256(kSigning, utf8.encode(stringToSign));

      final authorization =
          '$algorithm Credential=$accessKeyId/$credentialScope, '
          'SignedHeaders=$signedHeaders, Signature=${_hexEncode(signature)}';

      // Upload file - construct URL properly
      // AWS S3 accepts keys with slashes in the path component
      final uploadUrl = Uri.https(host, '/$key');
      final response = await http.put(
        uploadUrl,
        headers: {
          'Host': host,
          'x-amz-date': amzDate,
          'Authorization': authorization,
          'Content-Type': contentType,
        },
        body: fileBytes,
      );

      if (response.statusCode == 200) {
        print('✅ Successfully uploaded to AWS S3!');
        print('📦 Bucket: $bucketName');
        print('🔑 Key: $key');

        final downloadUrl = uploadUrl.toString();
        print('🔗 URL: $downloadUrl');

        // Note: The URL will only work if:
        // 1. The bucket has public read access, OR
        // 2. You use presigned URLs (not implemented yet)
        print(
            '💡 Note: If you get "NoSuchKey" or "AccessDenied" errors when accessing the URL,');
        print(
            '   make sure your S3 bucket has public read permissions or use presigned URLs.');

        FlutterReleaseXIndividualUploadService.updateUrlLinkState(downloadUrl);
        return downloadUrl;
      } else {
        print(
            '❌ Failed to upload to AWS S3: ${response.statusCode} ${response.reasonPhrase}');
        if (response.body.isNotEmpty) {
          print('Response: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      print('❌ Error uploading to AWS S3: $e');
      return null;
    }
  }

  static String _getContentType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.apk':
        return 'application/vnd.android.package-archive';
      case '.ipa':
        return 'application/octet-stream';
      case '.aab':
        return 'application/vnd.android.package-archive';
      case '.zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime date) {
    return '${_formatDate(date)}T'
        '${date.hour.toString().padLeft(2, '0')}'
        '${date.minute.toString().padLeft(2, '0')}'
        '${date.second.toString().padLeft(2, '0')}Z';
  }

  static List<int> _hmacSha256(List<int> key, List<int> data) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(data).bytes;
  }

  static String _hexEncode(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
