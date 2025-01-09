import 'package:flutter_release_x/state_management/upload_state.dart';

class IndividualUploadService {
  static void updateUrlLinkState(String downloadUrl) {
    /// Update the upload state with the download URL
    final uploadState = UploadState();
    uploadState.uploadLink = downloadUrl;
  }
}
