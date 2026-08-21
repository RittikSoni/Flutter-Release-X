import 'dart:convert';
import 'dart:io';
import 'package:flutter_release_x/models/app_config_model.dart';
import 'package:flutter_release_x/models/build_record_model.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:yaml/yaml.dart';

class FlutterReleaseXVersionTrackingService {
  final TrackVersionModel config;

  FlutterReleaseXVersionTrackingService(this.config);

  static Future<String> getPubspecVersion() async {
    final pubspecFile = File('pubspec.yaml');
    if (await pubspecFile.exists()) {
      try {
        final content = await pubspecFile.readAsString();
        final yaml = loadYaml(content);
        return yaml['version']?.toString() ?? 'unknown';
      } catch (e) {
        return 'unknown';
      }
    }
    return 'unknown';
  }

  static Future<void> bumpPubspecVersion() async {
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) return;

    try {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content);
      final currentVersion = yaml['version']?.toString();
      
      if (currentVersion != null) {
        String newVersion = _incrementVersionString(currentVersion);
        
        // Find the line starting with "version: " and replace it
        final lines = content.split('\n');
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('version:')) {
            lines[i] = 'version: $newVersion';
            break;
          }
        }
        await pubspecFile.writeAsString(lines.join('\n'));
        print('✅ Auto-bumped pubspec.yaml version to $newVersion');
      }
    } catch (e) {
      print('⚠️ Failed to bump pubspec.yaml version: $e');
    }
  }

  static String _incrementVersionString(String version) {
    if (version.contains('+')) {
      final parts = version.split('+');
      final base = parts[0];
      final buildNum = int.tryParse(parts[1]) ?? 0;
      return '$base+${buildNum + 1}';
    } else {
      return '$version+1';
    }
  }

  static Future<String> resolveNextVersion(TrackVersionModel config) async {
    final currentPubspecVersion = await getPubspecVersion();
    if (currentPubspecVersion == 'unknown') return currentPubspecVersion;

    if (config.autoUpdatePubspec) {
      return currentPubspecVersion;
    }

    if (!config.local.enabled) return currentPubspecVersion;

    final file = File(config.local.path);
    if (!await file.exists()) return currentPubspecVersion;

    try {
      final contents = await file.readAsString();
      if (contents.isEmpty) return currentPubspecVersion;

      final List<dynamic> history = jsonDecode(contents);
      if (history.isEmpty) return currentPubspecVersion;

      final baseVersion = currentPubspecVersion.split('+')[0];
      int maxBuildNum = -1;

      for (var item in history) {
        final record = BuildRecordModel.fromJson(item);
        final recordBase = record.version.split('+')[0];
        if (recordBase == baseVersion) {
          if (record.version.contains('+')) {
            final parts = record.version.split('+');
            final num = int.tryParse(parts[1]) ?? 0;
            if (num > maxBuildNum) maxBuildNum = num;
          } else {
            if (maxBuildNum < 0) maxBuildNum = 0;
          }
        }
      }

      if (maxBuildNum >= 0) {
        int pubspecBuildNum = 0;
        if (currentPubspecVersion.contains('+')) {
          pubspecBuildNum = int.tryParse(currentPubspecVersion.split('+')[1]) ?? 0;
        }

        if (maxBuildNum >= pubspecBuildNum) {
          return '$baseVersion+${maxBuildNum + 1}';
        }
      }
    } catch (e) {
      // Ignore errors
    }

    return currentPubspecVersion;
  }

  static Future<String> getGitBranch() async {
    try {
      final res = await Process.run('git', ['branch', '--show-current']);
      if (res.exitCode == 0) return res.stdout.toString().trim();
    } catch (_) {}
    return 'unknown';
  }

  static Future<String> getGitCommit() async {
    try {
      final res = await Process.run('git', ['rev-parse', '--short', 'HEAD']);
      if (res.exitCode == 0) return res.stdout.toString().trim();
    } catch (_) {}
    return 'unknown';
  }

  /// Main entry point to track a build
  Future<void> track(BuildRecordModel record) async {
    if (!config.enabled) return;

    // Fetch changelog if possible
    final changelog = await _getChangelogSinceLastBuild();
    
    final finalRecord = BuildRecordModel(
      version: record.version,
      platform: record.platform,
      buildType: record.buildType,
      timestamp: record.timestamp,
      gitBranch: record.gitBranch,
      gitCommit: record.gitCommit,
      status: record.status,
      changelog: changelog,
      downloadLink: record.downloadLink,
      localBuildPath: record.localBuildPath,
    );

    if (config.local.enabled) {
      await _trackLocal(finalRecord);
    }

    if (config.googleSheets.enabled) {
      await _trackGoogleSheets(finalRecord);
    }
  }

  /// Appends the build record to a local JSON file
  Future<void> _trackLocal(BuildRecordModel record) async {
    final file = File(config.local.path);
    List<dynamic> history = [];

    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          history = jsonDecode(contents);
        }
      } catch (e) {
        print('⚠️ Could not parse local history file. Overwriting...');
      }
    }

    history.add(record.toJson());
    await file.writeAsString(jsonEncode(history), mode: FileMode.write);
    print('✅ Build version history saved locally to ${config.local.path}');
  }

  /// Fetches the changelog since the last tracked commit
  Future<String?> _getChangelogSinceLastBuild() async {
    final file = File(config.local.path);

    try {
      String? lastCommit;
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          final List<dynamic> history = jsonDecode(contents);
          if (history.isNotEmpty) {
            final lastRecord = BuildRecordModel.fromJson(history.last);
            if (lastRecord.gitCommit.isNotEmpty && lastRecord.gitCommit != 'unknown') {
              lastCommit = lastRecord.gitCommit;
            }
          }
        }
      }

      ProcessResult result;
      if (lastCommit != null) {
        result = await Process.run('git', ['log', '$lastCommit..HEAD', '--pretty=format:- %s']);
      } else {
        result = await Process.run('git', ['log', '-n', '5', '--pretty=format:- %s']);
      }

      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      // Ignore errors for changelog generation
    }
    return null;
  }

  // Path to store the credentials file for sheets
  final String credentialsFilePath = '.frx_google_sheets_credentials.json';

  /// Appends the build record to a Google Sheet
  Future<void> _trackGoogleSheets(BuildRecordModel record) async {
    final clientIdStr = config.googleSheets.clientId;
    final clientSecretStr = config.googleSheets.clientSecret;
    final spreadsheetId = config.googleSheets.spreadsheetId;
    final sheetName = config.googleSheets.sheetName ?? 'Builds';

    if (clientIdStr == null || clientSecretStr == null || spreadsheetId == null) {
      print('⚠️ Google Sheets tracking enabled, but clientId, clientSecret, or spreadsheetId is missing.');
      return;
    }

    final credentials = auth.ClientId(clientIdStr, clientSecretStr);
    auth.AutoRefreshingAuthClient? client;

    // Check if credentials are already stored
    if (await File(credentialsFilePath).exists()) {
      try {
        final jsonString = await File(credentialsFilePath).readAsString();
        final jsonCredentials = auth.AccessCredentials.fromJson(json.decode(jsonString));
        client = auth.autoRefreshingClient(credentials, jsonCredentials, http.Client());
      } catch (e) {
        print('⚠️ Error using stored sheets credentials: $e');
      }
    }

    if (client == null) {
      try {
        client = await auth.clientViaUserConsent(
          credentials,
          [sheets.SheetsApi.spreadsheetsScope],
          (url) {
            FlutterReleaseXHelpers.showHighlight(
              firstMessage: 'Please visit the following URL to authenticate for Google Sheets:',
              highLightmessage: url,
            );
          },
        );
        final accessCredentials = client.credentials;
        await File(credentialsFilePath).writeAsString(json.encode(accessCredentials.toJson()));
      } catch (e) {
        print('⚠️ Error authenticating with Google Sheets: $e');
        return;
      }
    }

    final sheetsApi = sheets.SheetsApi(client);

    try {
      final valueRange = sheets.ValueRange(
        values: [
          [
            record.formattedTimestamp,
            record.version,
            record.platform,
            record.buildType,
            record.gitBranch,
            record.gitCommit,
            record.status,
            record.changelog ?? '',
            record.downloadLink ?? '',
            record.localBuildPath ?? '',
          ]
        ],
      );

      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        '$sheetName!A1',
        valueInputOption: 'USER_ENTERED',
      );
      print('✅ Build version history appended to Google Sheet.');
    } catch (e) {
      print('⚠️ Error appending to Google Sheets: $e');
    }
  }
}
