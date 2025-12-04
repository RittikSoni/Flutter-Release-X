import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:path/path.dart' as path;

class FlutterReleaseXUpdateCheckService {
  static final dio = Dio();
  static const String pubDevApiUrl =
      'https://pub.dev/api/packages/flutter_release_x';
  static const String cacheFileName = '.frx_update_cache';
  static const Duration cacheValidity =
      Duration(hours: 24); // Check once per day

  /// Get the cache file path in the user's home directory
  static String _getCacheFilePath() {
    final homeDir = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        Platform.environment['APPDATA'] ??
        Directory.current.path;
    return path.join(homeDir, cacheFileName);
  }

  /// Check if cache is still valid
  static bool _isCacheValid() {
    try {
      final cacheFile = File(_getCacheFilePath());
      if (!cacheFile.existsSync()) return false;

      final lastModified = cacheFile.lastModifiedSync();
      final now = DateTime.now();
      return now.difference(lastModified) < cacheValidity;
    } catch (e) {
      return false;
    }
  }

  /// Read cached version info
  static Future<String?> _readCachedVersion() async {
    try {
      if (!_isCacheValid()) return null;

      final cacheFile = File(_getCacheFilePath());
      if (!cacheFile.existsSync()) return null;

      final content = await cacheFile.readAsString();
      final lines = content.split('\n');
      if (lines.length >= 2) {
        final timestamp = DateTime.parse(lines[0]);
        final now = DateTime.now();
        if (now.difference(timestamp) < cacheValidity) {
          return lines[1].trim();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Write version info to cache
  static Future<void> _writeCache(String latestVersion) async {
    try {
      final cacheFile = File(_getCacheFilePath());
      await cacheFile.writeAsString(
        '${DateTime.now().toIso8601String()}\n$latestVersion',
      );
    } catch (e) {
      // Silently fail if cache write fails
    }
  }

  /// Compare two version strings (semantic versioning)
  /// Returns: -1 if current < latest, 0 if equal, 1 if current > latest
  static int _compareVersions(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    // Pad with zeros if needed
    while (currentParts.length < latestParts.length) {
      currentParts.add(0);
    }
    while (latestParts.length < currentParts.length) {
      latestParts.add(0);
    }

    for (int i = 0; i < currentParts.length; i++) {
      if (currentParts[i] < latestParts[i]) return -1;
      if (currentParts[i] > latestParts[i]) return 1;
    }
    return 0;
  }

  /// Check for updates from pub.dev
  /// Returns the latest version if available, null otherwise
  static Future<String?> checkForUpdates({bool forceCheck = false}) async {
    try {
      // Check cache first unless forced
      if (!forceCheck) {
        final cachedVersion = await _readCachedVersion();
        if (cachedVersion != null) {
          return cachedVersion;
        }
      }

      // Query pub.dev API
      final response = await dio.get(
        pubDevApiUrl,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final latestVersion = data['latest']?['version'] as String?;

        if (latestVersion != null) {
          // Cache the result
          await _writeCache(latestVersion);
          return latestVersion;
        }
      }
      return null;
    } catch (e) {
      // Silently fail - don't interrupt user's workflow
      return null;
    }
  }

  /// Check if an update is available
  /// Returns true if a newer version is available
  static Future<bool> isUpdateAvailable({bool forceCheck = false}) async {
    final latestVersion = await checkForUpdates(forceCheck: forceCheck);
    if (latestVersion == null) return false;

    final currentVersion = FlutterReleaseXKstrings.version;
    return _compareVersions(currentVersion, latestVersion) < 0;
  }

  /// Get update message to display to user
  static Future<String?> getUpdateMessage({bool forceCheck = false}) async {
    final latestVersion = await checkForUpdates(forceCheck: forceCheck);
    if (latestVersion == null) return null;

    final currentVersion = FlutterReleaseXKstrings.version;
    final comparison = _compareVersions(currentVersion, latestVersion);

    if (comparison < 0) {
      // Update available
      return '''
📦 A new version of FRX is available!
   Current: $currentVersion
   Latest:  $latestVersion
   
   Update with: dart pub global activate flutter_release_x
   Or visit: ${FlutterReleaseXKstrings.packageLink}
''';
    } else if (comparison > 0) {
      // Running a newer version (development/pre-release)
      return null;
    } else {
      // Up to date
      return '✅ You are using the latest version of FRX ($currentVersion)';
    }
  }

  /// Clear the update cache
  static Future<void> clearCache() async {
    try {
      final cacheFile = File(_getCacheFilePath());
      if (cacheFile.existsSync()) {
        await cacheFile.delete();
      }
    } catch (e) {
      // Silently fail
    }
  }
}
