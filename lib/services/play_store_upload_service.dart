import 'dart:convert';
import 'dart:io';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/services/individual_upload_service.dart';
import 'package:googleapis/androidpublisher/v3.dart' as androidpublisher;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:path/path.dart' as path;

class FlutterReleaseXPlayStoreUploadService {
  static Future<String?> uploadToPlayStore(String filePath) async {
    final config = FlutterReleaseXConfig().config;
    final playStoreConfig = config.uploadOptions.playStore;

    if (!playStoreConfig.enabled) {
      return null;
    }

    final serviceAccountJsonPath = playStoreConfig.serviceAccountJsonPath;
    final packageName = playStoreConfig.packageName;
    final track = playStoreConfig.track ?? 'internal';
    final releaseName = playStoreConfig.releaseName;

    if (serviceAccountJsonPath == null || serviceAccountJsonPath.isEmpty) {
      print(
          '❌ Google Play Store Service Account JSON path not found. Please check your config yaml file.');
      return null;
    }

    if (packageName == null || packageName.isEmpty) {
      print(
          '❌ Google Play Store Package Name not found. Please check your config yaml file.');
      return null;
    }

    try {
      final serviceAccountFile = File(serviceAccountJsonPath);
      if (!serviceAccountFile.existsSync()) {
        print('❌ Service account JSON file not found: $serviceAccountJsonPath');
        return null;
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        print('❌ File not found: $filePath');
        return null;
      }

      // Read service account credentials
      final serviceAccountJson =
          jsonDecode(await serviceAccountFile.readAsString());

      // Authenticate using service account
      final credentials =
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
      final client = await auth.clientViaServiceAccount(credentials,
          [androidpublisher.AndroidPublisherApi.androidpublisherScope]);

      try {
        final api = androidpublisher.AndroidPublisherApi(client);

        // Determine file type
        final fileExtension = path.extension(filePath).toLowerCase();
        final isAab = fileExtension == '.aab';
        final isApk = fileExtension == '.apk';

        if (!isAab && !isApk) {
          print(
              '❌ Unsupported file type. Only .aab and .apk files are supported.');
          return null;
        }

        // Create an edit
        final edit = androidpublisher.AppEdit();
        final editResponse = await api.edits.insert(edit, packageName);
        final editId = editResponse.id!;

        try {
          if (isAab) {
            // Upload AAB
            final media =
                androidpublisher.Media(file.openRead(), file.lengthSync());
            final uploadResponse = await api.edits.bundles.upload(
              packageName,
              editId,
              uploadMedia: media,
            );

            print('✅ AAB uploaded successfully');

            // Commit the edit to the specified track
            final trackRelease = androidpublisher.TrackRelease()
              ..versionCodes = [uploadResponse.versionCode.toString()]
              ..status = 'completed';

            if (releaseName != null && releaseName.isNotEmpty) {
              trackRelease.name = releaseName;
            }

            final trackUpdate = androidpublisher.Track()
              ..track = track
              ..releases = [trackRelease];

            await api.edits.tracks
                .update(trackUpdate, packageName, editId, track);
            await api.edits.commit(packageName, editId);

            final releaseUrl =
                'https://play.google.com/console/u/0/developers/${serviceAccountJson['project_id']}/app/$packageName/tracks/$track';
            FlutterReleaseXIndividualUploadService.updateUrlLinkState(
                releaseUrl);
            return releaseUrl;
          } else {
            // Upload APK
            final media =
                androidpublisher.Media(file.openRead(), file.lengthSync());
            final uploadResponse = await api.edits.apks.upload(
              packageName,
              editId,
              uploadMedia: media,
            );

            print('✅ APK uploaded successfully');

            // Commit the edit to the specified track
            final trackRelease = androidpublisher.TrackRelease()
              ..versionCodes = [uploadResponse.versionCode.toString()]
              ..status = 'completed';

            if (releaseName != null && releaseName.isNotEmpty) {
              trackRelease.name = releaseName;
            }

            final trackUpdate = androidpublisher.Track()
              ..track = track
              ..releases = [trackRelease];

            await api.edits.tracks
                .update(trackUpdate, packageName, editId, track);
            await api.edits.commit(packageName, editId);

            final releaseUrl =
                'https://play.google.com/console/u/0/developers/${serviceAccountJson['project_id']}/app/$packageName/tracks/$track';
            FlutterReleaseXIndividualUploadService.updateUrlLinkState(
                releaseUrl);
            return releaseUrl;
          }
        } catch (e) {
          // Delete the edit if something went wrong
          try {
            await api.edits.delete(packageName, editId);
          } catch (_) {
            // Ignore deletion errors
          }
          rethrow;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('❌ Error uploading to Google Play Store: $e');
      return null;
    }
  }
}
