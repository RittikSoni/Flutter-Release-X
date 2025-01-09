// ignore_for_file: unnecessary_getters_setters

class UploadState {
  static final UploadState _instance = UploadState._internal();
  String? _uploadLink;

  UploadState._internal();

  factory UploadState() => _instance;

  String? get uploadLink => _uploadLink;
  set uploadLink(String? link) {
    _uploadLink = link;
  }
}
