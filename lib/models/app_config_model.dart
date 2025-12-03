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
  final DiawiModel diawi;
  final SlackModel slack;
  final AWSModel aws;
  final GitlabModel gitlab;
  final PlayStoreModel playStore;
  final AppStoreModel appStore;

  UploadOptionsModel({
    GithubModel? github,
    GoogleDriveModel? googleDrive,
    DiawiModel? diawi,
    SlackModel? slack,
    AWSModel? aws,
    GitlabModel? gitlab,
    PlayStoreModel? playStore,
    AppStoreModel? appStore,
  })  : github = github ?? GithubModel(), // Default for github
        googleDrive =
            googleDrive ?? GoogleDriveModel(), // Default for googleDrive
        diawi = diawi ?? DiawiModel(), // Default for diawi
        slack = slack ?? SlackModel(),
        aws = aws ?? AWSModel(), // Default for aws
        gitlab = gitlab ?? GitlabModel(), // Default for gitlab
        playStore = playStore ?? PlayStoreModel(), // Default for playStore
        appStore = appStore ?? AppStoreModel(); // Default for appStore

  factory UploadOptionsModel.fromYaml(Map<dynamic, dynamic>? yamlMap) {
    final map = yamlMap ?? <dynamic, dynamic>{};
    return UploadOptionsModel(
      github: GithubModel.fromYaml(map['github'] ?? <dynamic, dynamic>{}),
      googleDrive: GoogleDriveModel.fromYaml(
          map['google_drive'] ?? <dynamic, dynamic>{}),
      diawi: DiawiModel.fromYaml(map['diawi'] ?? <dynamic, dynamic>{}),
      slack: SlackModel.fromYaml(map['slack'] ?? <dynamic, dynamic>{}),
      aws: AWSModel.fromYaml(map['aws'] ?? <dynamic, dynamic>{}),
      gitlab: GitlabModel.fromYaml(map['gitlab'] ?? <dynamic, dynamic>{}),
      playStore:
          PlayStoreModel.fromYaml(map['play_store'] ?? <dynamic, dynamic>{}),
      appStore:
          AppStoreModel.fromYaml(map['app_store'] ?? <dynamic, dynamic>{}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'github': github.toMap(),
      'google_drive': googleDrive.toMap(),
      'diawi': diawi.toMap(),
      'slack': slack.toMap(),
      'aws': aws.toMap(),
      'gitlab': gitlab.toMap(),
      'play_store': playStore.toMap(),
      'app_store': appStore.toMap(),
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

class DiawiModel {
  final bool enabled;
  final String? token;
  final bool? wallOfApps;
  final bool? findByUdid;
  final String? callbackUrl;
  final bool? installationNotifications;
  final String? password;
  final String? comment;

  DiawiModel({
    this.enabled = false, // Default for enabled
    this.token,
    this.wallOfApps,
    this.findByUdid,
    this.callbackUrl,
    this.installationNotifications,
    this.password,
    this.comment,
  });

  factory DiawiModel.fromYaml(Map<dynamic, dynamic> yamlMap) {
    return DiawiModel(
      enabled: yamlMap['enabled'] ?? false,
      token: yamlMap['token'],
      wallOfApps: yamlMap['wall_of_apps'],
      findByUdid: yamlMap['find_by_udid'],
      callbackUrl: yamlMap['callback_url'],
      installationNotifications: yamlMap['installation_notifications'],
      password: yamlMap['password'],
      comment: yamlMap['comment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'token': token,
      'wall_of_apps': wallOfApps,
      'find_by_udid': findByUdid,
      'callback_url': callbackUrl,
      'installation_notifications': installationNotifications,
      'password': password,
      'comment': comment,
    };
  }
}

class AWSModel {
  final bool enabled;
  final String? accessKeyId;
  final String? secretAccessKey;
  final String? region;
  final String? bucketName;
  final String? keyPrefix;

  AWSModel({
    this.enabled = false,
    this.accessKeyId,
    this.secretAccessKey,
    this.region,
    this.bucketName,
    this.keyPrefix,
  });

  factory AWSModel.fromYaml(Map<dynamic, dynamic>? yamlMap) {
    final map = yamlMap ?? <dynamic, dynamic>{};
    return AWSModel(
      enabled: map['enabled'] ?? false,
      accessKeyId: map['access_key_id'],
      secretAccessKey: map['secret_access_key'],
      region: map['region'],
      bucketName: map['bucket_name'],
      keyPrefix: map['key_prefix'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'access_key_id': accessKeyId,
      'secret_access_key': secretAccessKey,
      'region': region,
      'bucket_name': bucketName,
      'key_prefix': keyPrefix,
    };
  }
}

class GitlabModel {
  final bool enabled;
  final String? token;
  final String? projectId;
  final String? tag;
  final String? host;
  final String? ref;

  GitlabModel({
    this.enabled = false,
    this.token,
    this.projectId,
    String? tag,
    this.host,
    String? ref,
  })  : tag = tag ?? 'v0.0.1',
        ref = ref ?? 'main';

  factory GitlabModel.fromYaml(Map<dynamic, dynamic>? yamlMap) {
    final map = yamlMap ?? <dynamic, dynamic>{};
    return GitlabModel(
      enabled: map['enabled'] ?? false,
      token: map['token'],
      projectId: map['project_id'],
      tag: map['tag'],
      host: map['host'],
      ref: map['ref'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'token': token,
      'project_id': projectId,
      'tag': tag,
      'host': host,
      'ref': ref,
    };
  }
}

class PlayStoreModel {
  final bool enabled;
  final String? serviceAccountJsonPath;
  final String? packageName;
  final String? track;
  final String? releaseName;

  PlayStoreModel({
    this.enabled = false,
    this.serviceAccountJsonPath,
    this.packageName,
    this.track,
    this.releaseName,
  });

  factory PlayStoreModel.fromYaml(Map<dynamic, dynamic>? yamlMap) {
    final map = yamlMap ?? <dynamic, dynamic>{};
    return PlayStoreModel(
      enabled: map['enabled'] ?? false,
      serviceAccountJsonPath: map['service_account_json_path'],
      packageName: map['package_name'],
      track: map['track'],
      releaseName: map['release_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'service_account_json_path': serviceAccountJsonPath,
      'package_name': packageName,
      'track': track,
      'release_name': releaseName,
    };
  }
}

class AppStoreModel {
  final bool enabled;
  final String? apiKeyPath;
  final String? apiIssuer;
  final String? appId;
  final String? bundleId;

  AppStoreModel({
    this.enabled = false,
    this.apiKeyPath,
    this.apiIssuer,
    this.appId,
    this.bundleId,
  });

  factory AppStoreModel.fromYaml(Map<dynamic, dynamic>? yamlMap) {
    final map = yamlMap ?? <dynamic, dynamic>{};
    return AppStoreModel(
      enabled: map['enabled'] ?? false,
      apiKeyPath: map['api_key_path'],
      apiIssuer: map['api_issuer'],
      appId: map['app_id'],
      bundleId: map['bundle_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'api_key_path': apiKeyPath,
      'api_issuer': apiIssuer,
      'app_id': appId,
      'bundle_id': bundleId,
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
