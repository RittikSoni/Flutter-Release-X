import 'dart:io';

import 'package:flutter_release_x/constants/kstrings.dart';

class FlutterReleaseXAppConfigModel {
  final String? flutterPath;
  final UploadOptionsModel uploadOptions;
  final QrCodeModel qrCode;

  /// Legacy flat pipeline steps list. Preserved for backward compatibility.
  final List<PipelineStepModel>? pipelineSteps;

  /// New named pipelines map. Takes precedence over [pipelineSteps].
  final Map<String, PipelineModel>? pipelines;

  /// Git hooks configuration (optional, opt-in). Keyed by hook name, e.g. "pre-commit".
  final HooksConfigModel hooks;

  // Constructor with default values
  FlutterReleaseXAppConfigModel({
    this.flutterPath,
    UploadOptionsModel? uploadOptions,
    QrCodeModel? qrCode,
    this.pipelineSteps,
    this.pipelines,
    HooksConfigModel? hooks,
  })  : uploadOptions =
            uploadOptions ?? UploadOptionsModel(), // Default for uploadOptions
        qrCode = qrCode ?? QrCodeModel(), // Default for qrCode
        hooks = hooks ?? HooksConfigModel();

  /// Returns the resolved pipelines map.
  ///
  /// If `pipelines` is set, returns it directly.
  /// If only legacy `pipelineSteps` is set, wraps it in a "default" pipeline.
  /// Returns null if neither is configured.
  Map<String, PipelineModel>? get resolvedPipelines {
    if (pipelines != null && pipelines!.isNotEmpty) {
      return pipelines;
    }
    if (pipelineSteps != null && pipelineSteps!.isNotEmpty) {
      return {
        'default': PipelineModel(
          name: 'default',
          description: 'Default pipeline (from pipeline_steps)',
          steps: pipelineSteps!,
        ),
      };
    }
    return null;
  }

  // Factory constructor to create an instance from a YAML file
  factory FlutterReleaseXAppConfigModel.fromYaml(dynamic yamlPath) {
    final yamlMap = Map<String, dynamic>.from(yamlPath);

    // Parse legacy pipeline_steps
    List<PipelineStepModel>? legacySteps;
    if (yamlMap['pipeline_steps'] != null) {
      try {
        legacySteps = List<PipelineStepModel>.from(
          (yamlMap['pipeline_steps'] as List).map(
            (step) =>
                PipelineStepModel.fromYaml(Map<String, dynamic>.from(step)),
          ),
        );
      } catch (e) {
        print('⚠️ Warning: Failed to parse "pipeline_steps": $e');
        print(
            '   Ensure pipeline_steps is a list of steps, each with "name" and "command".');
      }
    }

    // Parse new pipelines map
    Map<String, PipelineModel>? namedPipelines;
    if (yamlMap['pipelines'] != null) {
      try {
        final pipelinesYaml =
            Map<String, dynamic>.from(yamlMap['pipelines'] as Map);
        namedPipelines = {};
        for (final entry in pipelinesYaml.entries) {
          final pipelineData = Map<String, dynamic>.from(entry.value as Map);
          namedPipelines[entry.key] =
              PipelineModel.fromYaml(entry.key, pipelineData);
        }
      } catch (e) {
        print('⚠️ Warning: Failed to parse "pipelines": $e');
        print(
            '   Ensure pipelines is a map of named pipelines, each with "steps".');
        print('   Example:');
        print('   pipelines:');
        print('     build:');
        print('       description: "Build the app"');
        print('       steps:');
        print('         - name: "Build APK"');
        print('           command: "flutter build apk --release"');
      }
    }

    // Show helpful message if both formats are detected
    if (legacySteps != null && namedPipelines != null) {
      print(
          '💡 Both "pipeline_steps" and "pipelines" found in config. Using "pipelines" (the new format).');
      print(
          '   Consider migrating your "pipeline_steps" to the "pipelines" format for better organization.');
    }

    // Parse hooks config
    HooksConfigModel? hooksConfig;
    if (yamlMap['hooks'] != null) {
      try {
        hooksConfig = HooksConfigModel.fromYaml(yamlMap['hooks'] as Map? ?? {});
      } catch (e) {
        print('⚠️ Warning: Failed to parse "hooks": $e');
        print(
            '   Ensure hooks is a map of hook names (e.g. pre-commit) with steps.');
      }
    }

    return FlutterReleaseXAppConfigModel(
      flutterPath: yamlMap['flutter_path'],
      uploadOptions: UploadOptionsModel.fromYaml(yamlMap['upload_options']),
      qrCode: QrCodeModel.fromYaml(yamlMap['qr_code']),
      pipelineSteps: legacySteps,
      pipelines: namedPipelines,
      hooks: hooksConfig,
    );
  }

  // Convert AppConfig to a Map (for saving back to a file)
  Map<String, dynamic> toMap() {
    return {
      'flutter_path': flutterPath,
      'upload_options': uploadOptions.toMap(),
      'qr_code': qrCode.toMap(),
      'pipeline_steps': pipelineSteps?.map((step) => step.toMap()).toList(),
      'pipelines': pipelines?.map((key, val) => MapEntry(key, val.toMap())),
      'hooks': hooks.toMap(),
    };
  }
}

class UploadOptionsModel {
  final GithubModel github;
  final GoogleDriveModel googleDrive;
  final DiawiModel diawi;
  final SlackModel slack;
  final TeamsModel teams;
  final AWSModel aws;
  final GitlabModel gitlab;
  final PlayStoreModel playStore;
  final AppStoreModel appStore;

  UploadOptionsModel({
    GithubModel? github,
    GoogleDriveModel? googleDrive,
    DiawiModel? diawi,
    SlackModel? slack,
    TeamsModel? teams,
    AWSModel? aws,
    GitlabModel? gitlab,
    PlayStoreModel? playStore,
    AppStoreModel? appStore,
  })  : github = github ?? GithubModel(), // Default for github
        googleDrive =
            googleDrive ?? GoogleDriveModel(), // Default for googleDrive
        diawi = diawi ?? DiawiModel(), // Default for diawi
        slack = slack ?? SlackModel(),
        teams = teams ?? TeamsModel(),
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
      teams: TeamsModel.fromYaml(map['teams'] ?? <dynamic, dynamic>{}),
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
      'teams': teams.toMap(),
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

class TeamsModel {
  final bool enabled;
  final bool shareQR;
  final bool shareLink;
  final String? webhookUrl;
  final String? customMessage;
  final List<String>? mentionUsers;

  TeamsModel({
    this.enabled = false,
    this.shareQR = true,
    this.shareLink = true,
    this.webhookUrl,
    this.customMessage,
    this.mentionUsers,
  });

  // Factory constructor to create an instance from YAML
  factory TeamsModel.fromYaml(Map<dynamic, dynamic>? yamlMap) {
    final map = yamlMap ?? <dynamic, dynamic>{};
    return TeamsModel(
      enabled: map['enabled'] ?? false,
      shareQR: map['share_QR'] ?? true,
      shareLink: map['share_link'] ?? true,
      webhookUrl: map['webhook_url'],
      customMessage: map['custom_message'],
      mentionUsers: map['mention_users'] != null
          ? List<String>.from(map['mention_users'])
          : null,
    );
  }

  // Method to convert the object to a Map
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'share_QR': shareQR,
      'share_link': shareLink,
      'webhook_url': webhookUrl,
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

  /// Human-readable description shown in pipeline logs.
  final String? description;

  /// Flag to enable uploading for this step.
  ///
  /// Defaults to `false`
  final bool uploadOutput;

  /// Path of the save artifact.
  final String? outputPath;

  /// Flag to notify Slack after this step.
  ///
  /// Defaults to `false`
  final bool notifySlack;

  /// Flag to notify Microsoft Teams after this step.
  ///
  /// Defaults to `false`
  final bool notifyTeams;

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
  ///       custom_exit_condition: "No issues found!"
  ///       stop_on_failure: true
  /// ```
  final String? customExitCondition;

  /// Per-step environment variables merged into the process environment.
  final Map<String, String>? env;

  /// Working directory for this step's command execution.
  final String? workingDirectory;

  /// Timeout in seconds. The step is killed if it exceeds this duration.
  /// Must be a positive integer when specified.
  final int? timeout;

  /// Number of retry attempts on failure. Defaults to `0` (no retries).
  /// Must be >= 0.
  final int retry;

  /// Seconds to wait between retries. Defaults to `5`.
  /// Must be > 0.
  final int retryDelay;

  /// If `true`, pipeline continues even if this step fails.
  /// The step is marked as failed in the summary but doesn't halt execution.
  ///
  /// Defaults to `false`
  final bool continueOnError;

  /// If `true`, a failed step is marked as "warning" instead of "failure"
  /// in the pipeline summary. Implies `continue_on_error: true`.
  ///
  /// Defaults to `false`
  final bool allowFailure;

  /// Shell command to evaluate before running this step.
  /// Step is only executed if this command exits with code 0.
  /// If the condition fails, the step is skipped (not failed).
  final String? condition;

  PipelineStepModel({
    required this.name,
    required this.command,
    this.dependsOn = const [],
    this.description,
    this.uploadOutput = false,
    this.outputPath,
    this.notifySlack = false,
    this.notifyTeams = false,
    this.customExitCondition,
    this.stopOnFailure = true,
    this.env,
    this.workingDirectory,
    this.timeout,
    this.retry = 0,
    this.retryDelay = 5,
    this.continueOnError = false,
    this.allowFailure = false,
    this.condition,
  });

  factory PipelineStepModel.fromYaml(Map<String, dynamic> yamlMap) {
    final stepMap = Map<String, dynamic>.from(yamlMap);
    if (yamlMap['name'] == null || yamlMap['command'] == null) {
      print(
          '❌ Pipeline step is missing required fields. Each step must have "name" and "command".');
      if (yamlMap['name'] == null) {
        print('   → Missing: "name" (a descriptive name for this step)');
      }
      if (yamlMap['command'] == null) {
        print('   → Missing: "command" (the shell command to execute)');
      }
      print('   Step data: $yamlMap');
      exit(1);
    }

    // Parse env map safely
    Map<String, String>? envMap;
    if (stepMap['env'] != null) {
      try {
        envMap = Map<String, String>.from(
          (stepMap['env'] as Map).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
        );
      } catch (e) {
        print(
            '⚠️ Warning: Step "${yamlMap['name']}" has invalid "env" format. Expected key-value pairs.');
        print('   Example: env: { MY_VAR: "value" }');
      }
    }

    // Parse and validate timeout
    int? timeout;
    if (stepMap['timeout'] != null) {
      timeout = _parseIntSafe(stepMap['timeout'], 'timeout', yamlMap['name']);
      if (timeout != null && timeout <= 0) {
        print(
            '⚠️ Warning: Step "${yamlMap['name']}" has timeout: $timeout — must be a positive number. Ignoring timeout.');
        timeout = null;
      }
    }

    // Parse and validate retry
    int retry = 0;
    if (stepMap['retry'] != null) {
      retry = _parseIntSafe(stepMap['retry'], 'retry', yamlMap['name']) ?? 0;
      if (retry < 0) {
        print(
            '⚠️ Warning: Step "${yamlMap['name']}" has retry: $retry — must be >= 0. Defaulting to 0.');
        retry = 0;
      }
    }

    // Parse and validate retry_delay
    int retryDelay = 5;
    if (stepMap['retry_delay'] != null) {
      retryDelay = _parseIntSafe(
              stepMap['retry_delay'], 'retry_delay', yamlMap['name']) ??
          5;
      if (retryDelay <= 0) {
        print(
            '⚠️ Warning: Step "${yamlMap['name']}" has retry_delay: $retryDelay — must be > 0. Defaulting to 5.');
        retryDelay = 5;
      }
    }

    return PipelineStepModel(
      name: yamlMap['name'],
      command: yamlMap['command'],
      dependsOn: List<String>.from(stepMap['depends_on'] ?? []),
      description: yamlMap['description'],
      uploadOutput: yamlMap['upload_output'] ?? false,
      outputPath: yamlMap['output_path'],
      notifySlack: yamlMap['notify_slack'] ?? false,
      notifyTeams: yamlMap['notify_teams'] ?? false,
      stopOnFailure: yamlMap['stop_on_failure'] ?? true,
      customExitCondition: yamlMap['custom_exit_condition'],
      env: envMap,
      workingDirectory: yamlMap['working_directory'],
      timeout: timeout,
      retry: retry,
      retryDelay: retryDelay,
      continueOnError: yamlMap['continue_on_error'] ?? false,
      allowFailure: yamlMap['allow_failure'] ?? false,
      condition: yamlMap['condition'],
    );
  }

  /// Safely parse an int from YAML, handling strings and invalid values.
  static int? _parseIntSafe(dynamic value, String fieldName, String stepName) {
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    print(
        '⚠️ Warning: Step "$stepName" has invalid "$fieldName" value: $value — expected an integer.');
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'command': command,
      'depends_on': dependsOn,
      'description': description,
      'upload_output': uploadOutput,
      'output_path': outputPath,
      'notify_slack': notifySlack,
      'notify_teams': notifyTeams,
      'stop_on_failure': stopOnFailure,
      'custom_exit_condition': customExitCondition,
      'env': env,
      'working_directory': workingDirectory,
      'timeout': timeout,
      'retry': retry,
      'retry_delay': retryDelay,
      'continue_on_error': continueOnError,
      'allow_failure': allowFailure,
      'condition': condition,
    };
  }
}

/// Represents a named pipeline containing a group of steps.
///
/// Pipelines allow users to organize multiple workflows (e.g., "build",
/// "test", "deploy") and select which one to run.
class PipelineModel {
  final String name;
  final String? description;
  final List<PipelineStepModel> steps;

  PipelineModel({
    required this.name,
    this.description,
    required this.steps,
  });

  factory PipelineModel.fromYaml(String name, Map<String, dynamic> yamlMap) {
    final stepsData = yamlMap['steps'];
    if (stepsData == null || stepsData is! List || stepsData.isEmpty) {
      print('❌ Pipeline "$name" must have at least one step defined.');
      print('   Example:');
      print('   pipelines:');
      print('     $name:');
      print('       steps:');
      print('         - name: "My Step"');
      print('           command: "echo hello"');
      exit(1);
    }

    return PipelineModel(
      name: name,
      description: yamlMap['description']?.toString(),
      steps: List<PipelineStepModel>.from(
        (stepsData).map(
          (step) => PipelineStepModel.fromYaml(Map<String, dynamic>.from(step)),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'steps': steps.map((step) => step.toMap()).toList(),
    };
  }
}

/// Validation result for a single issue found in pipeline configuration.
class PipelineValidationError {
  final String pipelineName;
  final String? stepName;
  final String message;
  final bool isWarning;

  PipelineValidationError({
    required this.pipelineName,
    this.stepName,
    required this.message,
    this.isWarning = false,
  });

  @override
  String toString() {
    final icon = isWarning ? '⚠️' : '❌';
    final location = stepName != null
        ? 'Pipeline "$pipelineName" → Step "$stepName"'
        : 'Pipeline "$pipelineName"';
    return '$icon $location: $message';
  }
}

/// Validates pipeline configuration and returns actionable error messages.
class PipelineConfigValidator {
  /// Validate all pipelines and return a list of issues found.
  /// Returns an empty list if everything is valid.
  static List<PipelineValidationError> validate(
      Map<String, PipelineModel> pipelines) {
    final errors = <PipelineValidationError>[];

    if (pipelines.isEmpty) {
      errors.add(PipelineValidationError(
        pipelineName: '(none)',
        message: 'No pipelines defined. Add at least one pipeline with steps.',
      ));
      return errors;
    }

    for (final entry in pipelines.entries) {
      final pipelineName = entry.key;
      final pipeline = entry.value;

      // Check for empty steps
      if (pipeline.steps.isEmpty) {
        errors.add(PipelineValidationError(
          pipelineName: pipelineName,
          message:
              'Pipeline has no steps. Add at least one step with "name" and "command".',
        ));
        continue;
      }

      // Check for duplicate step names within a pipeline
      final stepNames = <String>{};
      for (final step in pipeline.steps) {
        if (!stepNames.add(step.name)) {
          errors.add(PipelineValidationError(
            pipelineName: pipelineName,
            stepName: step.name,
            message:
                'Duplicate step name. Each step within a pipeline must have a unique name.',
          ));
        }
      }

      // Validate each step
      for (final step in pipeline.steps) {
        _validateStep(pipelineName, step, stepNames, errors);
      }
    }

    return errors;
  }

  static void _validateStep(
    String pipelineName,
    PipelineStepModel step,
    Set<String> allStepNames,
    List<PipelineValidationError> errors,
  ) {
    // Check empty command
    if (step.command.trim().isEmpty) {
      errors.add(PipelineValidationError(
        pipelineName: pipelineName,
        stepName: step.name,
        message:
            '"command" is empty. Provide a valid shell command to execute.',
      ));
    }

    // Check upload_output without output_path
    if (step.uploadOutput &&
        (step.outputPath == null || step.outputPath!.trim().isEmpty)) {
      errors.add(PipelineValidationError(
        pipelineName: pipelineName,
        stepName: step.name,
        message:
            'upload_output is true but no output_path specified. Add output_path to define the artifact location.',
      ));
    }

    // Check output_path points to a valid-looking path
    if (step.outputPath != null && step.outputPath!.trim().isNotEmpty) {
      final outputFile = File(step.outputPath!);
      final outputDir = Directory(step.outputPath!);
      if (!outputFile.existsSync() && !outputDir.existsSync()) {
        errors.add(PipelineValidationError(
          pipelineName: pipelineName,
          stepName: step.name,
          message:
              'output_path "${step.outputPath}" does not exist yet. It will be checked again after the step runs.',
          isWarning: true,
        ));
      }
    }

    // Validate working_directory exists
    if (step.workingDirectory != null &&
        step.workingDirectory!.trim().isNotEmpty) {
      final dir = Directory(step.workingDirectory!);
      if (!dir.existsSync()) {
        errors.add(PipelineValidationError(
          pipelineName: pipelineName,
          stepName: step.name,
          message:
              'working_directory "${step.workingDirectory}" does not exist. Create the directory or fix the path.',
        ));
      }
    }

    // Validate depends_on references exist
    for (final dep in step.dependsOn) {
      if (!allStepNames.contains(dep)) {
        errors.add(PipelineValidationError(
          pipelineName: pipelineName,
          stepName: step.name,
          message:
              'depends_on references "$dep" which is not a step in this pipeline. Available steps: ${allStepNames.join(", ")}',
        ));
      }
      // Self-dependency check
      if (dep == step.name) {
        errors.add(PipelineValidationError(
          pipelineName: pipelineName,
          stepName: step.name,
          message:
              'Step depends on itself. Remove self-reference from depends_on.',
        ));
      }
    }

    // Validate timeout
    if (step.timeout != null && step.timeout! <= 0) {
      errors.add(PipelineValidationError(
        pipelineName: pipelineName,
        stepName: step.name,
        message:
            'timeout is ${step.timeout} — must be a positive number of seconds (e.g., timeout: 60).',
      ));
    }

    // Validate retry
    if (step.retry < 0) {
      errors.add(PipelineValidationError(
        pipelineName: pipelineName,
        stepName: step.name,
        message: 'retry is ${step.retry} — must be >= 0 (e.g., retry: 3).',
      ));
    }

    // Validate retry_delay
    if (step.retryDelay <= 0) {
      errors.add(PipelineValidationError(
        pipelineName: pipelineName,
        stepName: step.name,
        message:
            'retry_delay is ${step.retryDelay} — must be > 0 seconds (e.g., retry_delay: 5).',
      ));
    }

    // Warn if retry > 0 but no retry_delay override
    if (step.retry > 5) {
      errors.add(PipelineValidationError(
        pipelineName: pipelineName,
        stepName: step.name,
        message:
            'retry is ${step.retry} — that\'s a lot of retries. Consider reducing to avoid long pipeline runs.',
        isWarning: true,
      ));
    }

    // Warn about conflicting settings
    if (step.allowFailure &&
        step.stopOnFailure == true &&
        !step.continueOnError) {
      errors.add(PipelineValidationError(
        pipelineName: pipelineName,
        stepName: step.name,
        message:
            'allow_failure is true but stop_on_failure is also true and continue_on_error is false. '
            'allow_failure implicitly enables continue_on_error. This is handled automatically, but consider setting continue_on_error: true explicitly.',
        isWarning: true,
      ));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOOKS MODELS
// ─────────────────────────────────────────────────────────────────────────────

/// All supported git hook names (for validation / user hints).
const _kValidHookNames = [
  'applypatch-msg',
  'pre-applypatch',
  'post-applypatch',
  'pre-commit',
  'pre-merge-commit',
  'prepare-commit-msg',
  'commit-msg',
  'post-commit',
  'pre-rebase',
  'post-checkout',
  'post-merge',
  'pre-push',
  'pre-receive',
  'update',
  'proc-receive',
  'post-receive',
  'post-update',
  'reference-transaction',
  'push-to-checkout',
  'pre-auto-gc',
  'post-rewrite',
  'sendemail-validate',
  'fsmonitor-watchman',
  'p4-changelist',
  'p4-prepare-changelist',
  'p4-post-changelist',
  'p4-pre-submit',
  'post-index-change',
];

/// Top-level hooks configuration — holds all configured git hooks.
class HooksConfigModel {
  /// Map keyed by git hook name (e.g. `pre-commit`, `pre-push`).
  final Map<String, HookModel> hooks;

  HooksConfigModel({Map<String, HookModel>? hooks})
      : hooks = hooks ?? <String, HookModel>{};

  bool get isEmpty => hooks.isEmpty;
  bool get isNotEmpty => hooks.isNotEmpty;

  /// Returns only `enabled` hooks.
  Map<String, HookModel> get enabledHooks =>
      Map.fromEntries(hooks.entries.where((e) => e.value.enabled));

  factory HooksConfigModel.fromYaml(Map<dynamic, dynamic> yamlMap) {
    final result = <String, HookModel>{};
    for (final entry in yamlMap.entries) {
      final hookName = entry.key.toString().trim().toLowerCase();

      // Warn about unknown hook names but still parse (user may know better)
      if (!_kValidHookNames.contains(hookName)) {
        print(
            '⚠️  [hooks] Unknown hook name: "$hookName". Valid names include: ${_kValidHookNames.take(6).join(', ')}, ...');
      }

      if (entry.value == null) continue;
      try {
        final hookMap = Map<String, dynamic>.from(entry.value as Map);
        result[hookName] = HookModel.fromYaml(hookName, hookMap);
      } catch (e) {
        print('⚠️  [hooks] Failed to parse hook "$hookName": $e');
      }
    }
    return HooksConfigModel(hooks: result);
  }

  Map<String, dynamic> toMap() =>
      hooks.map((key, val) => MapEntry(key, val.toMap()));
}

/// Configuration for a single git hook, e.g. `pre-commit`.
class HookModel {
  /// Git hook name, e.g. `pre-commit`.
  final String name;

  /// Whether this hook is installed/active. Defaults to `false`.
  final bool enabled;

  /// Inline steps to run sequentially.
  final List<HookStepModel> steps;

  /// If set, runs a named FRX pipeline instead of inline [steps].
  /// Pipeline must exist in the `pipelines:` section of config.yaml.
  final String? runPipeline;

  /// If `true` (default), abort git operation when any step fails (exit code != 0).
  final bool stopOnFailure;

  /// Optional human-readable description shown in `frx hooks list`.
  final String? description;

  HookModel({
    required this.name,
    this.enabled = false,
    this.steps = const [],
    this.runPipeline,
    this.stopOnFailure = true,
    this.description,
  });

  bool get hasSteps => steps.isNotEmpty;
  bool get hasPipeline => runPipeline != null && runPipeline!.trim().isNotEmpty;

  factory HookModel.fromYaml(String name, Map<String, dynamic> yamlMap) {
    final stepsData = yamlMap['steps'];
    final steps = <HookStepModel>[];
    if (stepsData != null && stepsData is List) {
      for (int i = 0; i < stepsData.length; i++) {
        try {
          steps.add(HookStepModel.fromYaml(
              Map<String, dynamic>.from(stepsData[i] as Map)));
        } catch (e) {
          print('⚠️  [hooks.$name] Failed to parse step #${i + 1}: $e');
        }
      }
    }

    final runPipeline = yamlMap['run_pipeline']?.toString().trim();
    final runPipelineNormalized =
        (runPipeline == null || runPipeline.isEmpty) ? null : runPipeline;

    // Validate: must have steps OR run_pipeline
    if (steps.isEmpty && runPipelineNormalized == null) {
      print(
          '⚠️  [hooks.$name] Hook has no steps and no run_pipeline. It will do nothing when triggered.');
    }

    return HookModel(
      name: name,
      enabled: yamlMap['enabled'] == true,
      steps: steps,
      runPipeline: runPipelineNormalized,
      stopOnFailure: yamlMap['stop_on_failure'] ?? true,
      description: yamlMap['description']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        if (description != null) 'description': description,
        'stop_on_failure': stopOnFailure,
        if (runPipeline != null) 'run_pipeline': runPipeline,
        if (steps.isNotEmpty) 'steps': steps.map((s) => s.toMap()).toList(),
      };
}

/// A single step within a git hook.
class HookStepModel {
  final String name;
  final String command;

  /// Per-step environment variables.
  final Map<String, String>? env;

  /// Working directory override.
  final String? workingDirectory;

  /// Timeout in seconds. Step is killed if exceeded.
  final int? timeout;

  /// If `true`, a failing step is logged but does NOT abort the hook.
  final bool allowFailure;

  /// Human-readable description.
  final String? description;

  HookStepModel({
    required this.name,
    required this.command,
    this.env,
    this.workingDirectory,
    this.timeout,
    this.allowFailure = false,
    this.description,
  });

  factory HookStepModel.fromYaml(Map<String, dynamic> yamlMap) {
    if (yamlMap['name'] == null || yamlMap['command'] == null) {
      final missing = <String>[];
      if (yamlMap['name'] == null) missing.add('name');
      if (yamlMap['command'] == null) missing.add('command');
      throw ArgumentError(
          'Hook step missing required field(s): ${missing.join(', ')}');
    }

    Map<String, String>? envMap;
    if (yamlMap['env'] != null) {
      try {
        envMap = Map<String, String>.from(
          (yamlMap['env'] as Map)
              .map((k, v) => MapEntry(k.toString(), v.toString())),
        );
      } catch (_) {
        print(
            '⚠️  [hooks step "${yamlMap['name']}"] Invalid env format. Ignoring env.');
      }
    }

    int? timeout;
    if (yamlMap['timeout'] != null) {
      timeout = yamlMap['timeout'] is int
          ? yamlMap['timeout'] as int
          : int.tryParse(yamlMap['timeout'].toString());
      if (timeout != null && timeout <= 0) timeout = null;
    }

    return HookStepModel(
      name: yamlMap['name'].toString(),
      command: yamlMap['command'].toString(),
      env: envMap,
      workingDirectory: yamlMap['working_directory']?.toString(),
      timeout: timeout,
      allowFailure: yamlMap['allow_failure'] == true,
      description: yamlMap['description']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'command': command,
        if (env != null) 'env': env,
        if (workingDirectory != null) 'working_directory': workingDirectory,
        if (timeout != null) 'timeout': timeout,
        'allow_failure': allowFailure,
        if (description != null) 'description': description,
      };
}
