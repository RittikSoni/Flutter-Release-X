import 'dart:io';

import 'package:flutter_release_x/constants/kstrings.dart';

class AppConfigModel {
  final String? flutterPath;
  final UploadOptions uploadOptions;
  final QrCode qrCode;

  // Constructor with default values
  AppConfigModel({
    this.flutterPath,
    UploadOptions? uploadOptions,
    QrCode? qrCode,
  })  : uploadOptions =
            uploadOptions ?? UploadOptions(), // Default for uploadOptions
        qrCode = qrCode ?? QrCode(); // Default for qrCode

  // Factory constructor to create an instance from a YAML file
  factory AppConfigModel.fromYaml(yamlPath) {
    final yamlMap = Map<String, dynamic>.from(yamlPath);

    return AppConfigModel(
      flutterPath: yamlMap['flutter_path'],
      uploadOptions: UploadOptions.fromYaml(yamlMap['upload_options']),
      qrCode: QrCode.fromYaml(yamlMap['qr_code']),
    );
  }

  // Convert AppConfig to a Map (for saving back to a file)
  Map<String, dynamic> toMap() {
    return {
      'flutter_path': flutterPath,
      'upload_options': uploadOptions.toMap(),
      'qr_code': qrCode.toMap(),
    };
  }

  // Optionally, save this configuration back to the file
  void saveToFile() {
    final yamlContent = '''
flutter_path: $flutterPath
upload_options:
  github:
    enabled: ${uploadOptions.github.enabled}
    token: ${uploadOptions.github.token}
    repo: ${uploadOptions.github.repo}
  google_drive:
    enabled: ${uploadOptions.googleDrive.enabled}
    credentials_path: ${uploadOptions.googleDrive.credentialsPath}
    client_id: ${uploadOptions.googleDrive.clientId}
    client_secret: ${uploadOptions.googleDrive.clientSecret}
qr_code:
  enabled: ${qrCode.enabled}
  save_file: ${qrCode.saveFile}
  show_in_command: ${qrCode.showInCommand}
  size: ${qrCode.size}
  error_correction_level: ${qrCode.errorCorrectionLevel}
  save_path: ${qrCode.savePath}
''';
    File('config.yaml').writeAsStringSync(yamlContent);
  }
}

class UploadOptions {
  final Github github;
  final GoogleDrive googleDrive;
  final Slack slack;

  UploadOptions({
    Github? github,
    GoogleDrive? googleDrive,
    Slack? slack,
  })  : github = github ?? Github(), // Default for github
        googleDrive = googleDrive ?? GoogleDrive(), // Default for googleDrive
        slack = slack ?? Slack();

  factory UploadOptions.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return UploadOptions(
      github: Github.fromYaml(yamlMap['github']),
      googleDrive: GoogleDrive.fromYaml(yamlMap['google_drive']),
      slack: Slack.fromYaml(yamlMap['slack']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'github': github.toMap(),
      'google_drive': googleDrive.toMap(),
      'slack': googleDrive.toMap(),
    };
  }
}

class Github {
  final bool enabled;
  final String? token;
  final String? repo;
  final String tag;

  Github({
    this.enabled = false, // Default for enabled
    this.token,
    this.repo,
    String? tag,
  }) : tag = tag ?? 'v0.0.1';

  factory Github.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return Github(
      enabled: yamlMap['enabled'] ?? false,
      token: yamlMap['token'],
      repo: yamlMap['repo'],
      tag: yamlMap['tag'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'token': token,
      'repo': repo,
      'tag': tag,
    };
  }
}

class Slack {
  final bool enabled;
  final bool shareQR;
  final bool shareLink;
  final String? botUserOauthToken;
  final String? defaultChannelId;
  final String? customMessage;
  final List<String>? mentionUsers;

  Slack({
    this.enabled = false,
    this.shareQR = true,
    this.shareLink = true,
    this.botUserOauthToken,
    this.defaultChannelId,
    this.customMessage,
    this.mentionUsers,
  });

  // Factory constructor to create an instance from YAML
  factory Slack.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return Slack(
      enabled: yamlMap['enabled'] ?? false,
      shareQR: yamlMap['share_QR'] ?? true,
      shareLink: yamlMap['share_link'] ?? true,
      botUserOauthToken: yamlMap['bot_user_oauth_token'],
      defaultChannelId: yamlMap['default_channel_id'],
      customMessage: yamlMap['custom_message'],
      mentionUsers: yamlMap['mention_users'] != null
          ? List<String>.from(yamlMap['mention_users'])
          : null,
    );
  }

  // Method to convert the object to a Map
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'share_QR': shareQR,
      'share_link': shareLink,
      'bot_user_oauth_token': botUserOauthToken,
      'default_channel_id': defaultChannelId,
      'custom_message': customMessage,
      'mention_users': mentionUsers,
    };
  }
}

class GoogleDrive {
  final bool enabled;
  final String? credentialsPath;
  final String? clientId;
  final String? clientSecret;

  GoogleDrive({
    this.enabled = false, // Default for enabled
    this.credentialsPath,
    this.clientId,
    this.clientSecret,
  });

  factory GoogleDrive.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return GoogleDrive(
      enabled: yamlMap['enabled'] ?? false,
      credentialsPath: yamlMap['credentials_path'],
      clientId: yamlMap['client_id'],
      clientSecret: yamlMap['client_secret'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'credentials_path': credentialsPath,
      'client_id': clientId,
      'client_secret': clientSecret,
    };
  }
}

class QrCode {
  final bool enabled;
  final bool saveFile;
  final bool showInCommand;
  final int size;
  final String errorCorrectionLevel;
  final String savePath;

  QrCode({
    this.enabled = true, // Default for enabled
    this.saveFile = true, // Default for saveFile
    this.showInCommand = true, // Default for showInCommand
    this.size = 256, // Default for size
    this.errorCorrectionLevel = 'low', // Default for errorCorrectionLevel
    this.savePath = Kstrings.qrCodeSavePath, // Default for savePath
  });

  factory QrCode.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return QrCode(
      enabled: yamlMap['enabled'] ?? true,
      saveFile: yamlMap['save_file'] ?? true,
      showInCommand: yamlMap['show_in_command'] ?? true,
      size: yamlMap['size'] ?? 256,
      errorCorrectionLevel: yamlMap['error_correction_level'] ?? 'low',
      savePath: yamlMap['save_path'] ?? Kstrings.qrCodeSavePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'save_file': saveFile,
      'show_in_command': showInCommand,
      'size': size,
      'error_correction_level': errorCorrectionLevel,
      'save_path': savePath,
    };
  }
}
