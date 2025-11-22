// ignore_for_file: unnecessary_getters_setters

class FlutterReleaseXUploadState {
  static final FlutterReleaseXUploadState _instance =
      FlutterReleaseXUploadState._internal();
  String? _uploadLink;

  FlutterReleaseXUploadState._internal();

  factory FlutterReleaseXUploadState() => _instance;

  String? get uploadLink => _uploadLink;
  set uploadLink(String? link) {
    _uploadLink = link;
  }
}
