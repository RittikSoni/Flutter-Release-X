import 'dart:io';

import 'package:flutter_release_x/constants/kstrings.dart';

class FlutterReleaseXAppConfigModel {
  final String? flutterPath;
  final UploadOptionsModel uploadOptions;
  final QrCodeModel qrCode;
  final List<PipelineStepModel>? pipelineSteps;

  // Constructor with default values
  FlutterReleaseXAppConfigModel({
    this.flutterPath,
    UploadOptionsModel? uploadOptions,
    QrCodeModel? qrCode,
    this.pipelineSteps,
  })  : uploadOptions =
            uploadOptions ?? UploadOptionsModel(), // Default for uploadOptions
        qrCode = qrCode ?? QrCodeModel(); // Default for qrCode

  // Factory constructor to create an instance from a YAML file
  factory FlutterReleaseXAppConfigModel.fromYaml(dynamic yamlPath) {
    final yamlMap = Map<String, dynamic>.from(yamlPath);

    return FlutterReleaseXAppConfigModel(
      flutterPath: yamlMap['flutter_path'],
      uploadOptions: UploadOptionsModel.fromYaml(yamlMap['upload_options']),
      qrCode: QrCodeModel.fromYaml(yamlMap['qr_code']),
      pipelineSteps: yamlMap['pipeline_steps'] != null
          ? List<PipelineStepModel>.from(
              (yamlMap['pipeline_steps'] as List).map(
                (step) =>
                    PipelineStepModel.fromYaml(Map<String, dynamic>.from(step)),
              ),
            )
          : null,
    );
  }

  // Convert AppConfig to a Map (for saving back to a file)
  Map<String, dynamic> toMap() {
    return {
      'flutter_path': flutterPath,
      'upload_options': uploadOptions.toMap(),
      'qr_code': qrCode.toMap(),
      'pipeline_steps': pipelineSteps?.map((step) => step.toMap()).toList(),
    };
  }
}

class UploadOptionsModel {
  final GithubModel github;
  final GoogleDriveModel googleDrive;
  final SlackModel slack;

  UploadOptionsModel({
    GithubModel? github,
    GoogleDriveModel? googleDrive,
    SlackModel? slack,
  })  : github = github ?? GithubModel(), // Default for github
        googleDrive =
            googleDrive ?? GoogleDriveModel(), // Default for googleDrive
        slack = slack ?? SlackModel();

  factory UploadOptionsModel.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return UploadOptionsModel(
      github: GithubModel.fromYaml(yamlMap['github']),
      googleDrive: GoogleDriveModel.fromYaml(yamlMap['google_drive']),
      slack: SlackModel.fromYaml(yamlMap['slack']),
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

class GithubModel {
  final bool enabled;
  final String? token;
  final String? repo;
  final String tag;

  GithubModel({
    this.enabled = false, // Default for enabled
    this.token,
    this.repo,
    String? tag,
  }) : tag = tag ?? 'v0.0.1';

  factory GithubModel.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return GithubModel(
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

class SlackModel {
  final bool enabled;
  final bool shareQR;
  final bool shareLink;
  final String? botUserOauthToken;
  final String? defaultChannelId;
  final String? customMessage;
  final List<String>? mentionUsers;

  SlackModel({
    this.enabled = false,
    this.shareQR = true,
    this.shareLink = true,
    this.botUserOauthToken,
    this.defaultChannelId,
    this.customMessage,
    this.mentionUsers,
  });

  // Factory constructor to create an instance from YAML
  factory SlackModel.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return SlackModel(
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

class GoogleDriveModel {
  final bool enabled;
  final String? credentialsPath;
  final String? clientId;
  final String? clientSecret;

  GoogleDriveModel({
    this.enabled = false, // Default for enabled
    this.credentialsPath,
    this.clientId,
    this.clientSecret,
  });

  factory GoogleDriveModel.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return GoogleDriveModel(
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

class QrCodeModel {
  final bool enabled;
  final bool saveFile;
  final bool showInCommand;
  final int size;
  final String errorCorrectionLevel;
  final String savePath;

  QrCodeModel({
    this.enabled = true, // Default for enabled
    this.saveFile = true, // Default for saveFile
    this.showInCommand = true, // Default for showInCommand
    this.size = 256, // Default for size
    this.errorCorrectionLevel = 'low', // Default for errorCorrectionLevel
    this.savePath =
        FlutterReleaseXKstrings.qrCodeSavePath, // Default for savePath
  });

  factory QrCodeModel.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return QrCodeModel(
      enabled: yamlMap['enabled'] ?? true,
      saveFile: yamlMap['save_file'] ?? true,
      showInCommand: yamlMap['show_in_command'] ?? true,
      size: yamlMap['size'] ?? 256,
      errorCorrectionLevel: yamlMap['error_correction_level'] ?? 'low',
      savePath: yamlMap['save_path'] ?? FlutterReleaseXKstrings.qrCodeSavePath,
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

class PipelineStepModel {
  final String name;
  final String command;
  final List<String> dependsOn;

  /// Flag to enable uploading for this step.
  ///
  /// Defaults to `false`
  final bool uploadOutput;

  /// Path of the save artifact.
  final String? outputPath;

  /// Flag to notify Slack after this step
  ///
  /// Defaults to `false`
  final bool notifySlack;

  /// Defaults to `true`
  ///
  /// Whether to stop pipeline or not when any step fails.
  final bool? stopOnFailure;

  /// Custom Condition For exit condition
  ///
  /// e.g.
  /// ```yaml
  /// pipeline_steps:
  ///     - name: "Analyze Code"
  ///       command: "flutter analyze"
  ///       custom_exit_condition: "No issues found!" # Matches specific output to determine success
  ///       stop_on_failure: true
  /// ```
  final String? customExitCondition;

  PipelineStepModel({
    required this.name,
    required this.command,
    this.dependsOn = const [],
    this.uploadOutput = false, // Default to false if not specified
    this.outputPath, // Optional: Path of the artifact to upload
    this.notifySlack = false, // Default to false if not specified
    this.customExitCondition,
    this.stopOnFailure = true,
  });

  factory PipelineStepModel.fromYaml(Map<String, dynamic> yamlMap) {
    final stepMap = Map<String, dynamic>.from(yamlMap);
    if (yamlMap['name'] == null || yamlMap['command'] == null) {
      print('❌ Provide Stage name and command in pipeline');
      exit(1);
    }
    return PipelineStepModel(
      name: yamlMap['name'],
      command: yamlMap['command'],
      dependsOn: List<String>.from(stepMap['depends_on'] ?? []),
      uploadOutput: yamlMap['upload_output'] ?? false,
      outputPath: yamlMap['output_path'], // Load output path
      notifySlack: yamlMap['notify_slack'] ?? false,
      stopOnFailure: yamlMap['stop_on_failure'] ?? true,
      customExitCondition: yamlMap['custom_exit_condition'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'command': command,
      'depends_on': dependsOn,
      'upload_output': uploadOutput,
      'output_path': outputPath, // Save output path
      'notify_slack': notifySlack,
      'stop_on_failure': stopOnFailure,
      'custom_exit_condition': customExitCondition,
    };
  }
}
