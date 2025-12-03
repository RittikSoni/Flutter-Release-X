import 'dart:async';
import 'dart:io';

import 'package:flutter_release_x/commands/prompt_storage_options.dart';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/constants/kenums.dart';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/models/app_config_model.dart';
import 'package:flutter_release_x/services/slack_service.dart';
import 'package:flutter_release_x/state_management/upload_state.dart';
import 'package:qr/qr.dart';
import 'package:image/image.dart' as img;
import 'package:yaml/yaml.dart';

class FlutterReleaseXHelpers {
  // ───────────────────────────────────── LOADERS  ─────────────────────────────────────
  static const List<String> earthFrames = [
    '🌍',
    '🌎',
    '🌏'
  ]; // Earth rotation frames
  static const List<String> spinnerFrames = ['|', '/', '-', '\\'];

//  ───────────────────────────────────── TIMER  ─────────────────────────────────────
  /// Store the timer for stopping later
  static Timer? _loadingTimer;

//  ─────────────────────────────────────  SLACK  ─────────────────────────────────────
  static Future<void> notifySlack({
    String? customSlackMsg,
    bool? shareLink,
    bool? shareQr,
  }) async {
    final slackService = FlutterReleaseXSlackService();
    final uploadState = FlutterReleaseXUploadState();

    final String? downloadLink = uploadState.uploadLink;
    final slackConfig = FlutterReleaseXConfig().config.uploadOptions.slack;
    final bool isSlackEnabled = slackConfig.enabled;
    final String? slackBotToken = slackConfig.botUserOauthToken;
    final String? channelId = slackConfig.defaultChannelId;
    final String? customMessage = customSlackMsg ?? slackConfig.customMessage;
    final List<String>? mentionUsers = slackConfig.mentionUsers;
    final bool isShareDownloadLink = shareLink ?? slackConfig.shareLink;
    final bool isShareQR = shareQr ?? slackConfig.shareQR;
    final File qrFile = File('./release-qr-code.png');

    if (isSlackEnabled && slackBotToken != null && channelId != null) {
      try {
        FlutterReleaseXHelpers.showLoading('🔔 Sharing on Slack...');

        await slackService.sendLinkAndQr(
          slackBotToken: slackBotToken,
          fileSizeInBytes: qrFile.lengthSync(),
          file: qrFile,
          channelId: channelId,
          message: customMessage ?? '🎉 Your app is ready for download!',
          mentions: mentionUsers,
          downloadLink: downloadLink ?? FlutterReleaseXKstrings.packageLink,
          isShareQR: isShareQR,
          isShareDownloadLink: isShareDownloadLink,
        );
      } catch (e, s) {
        showHighlight(
          firstMessage: 'Slack error:',
          highLightmessage: e.toString(),
          lastMessage: s.toString(),
        );
        exit(0);
      } finally {
        FlutterReleaseXHelpers.stopLoading();
      }
    }
  }

  //  ───────────────────────────────────── QR  ─────────────────────────────────────

  /// Get the QR error correction level
  ///
  /// Default value is 'low'.
  static int getQrCorrectionLevel(String qrCorrectionLevel) {
    switch (qrCorrectionLevel) {
      case 'low':
        return QrErrorCorrectLevel.L;
      case 'medium':
        return QrErrorCorrectLevel.M;
      case 'quartile':
        return QrErrorCorrectLevel.Q;
      case 'high':
        return QrErrorCorrectLevel.H;
      default:
        return QrErrorCorrectLevel.L;
    }
  }

  /// Generate a QR code and displays & save it.
  /// Optionally, print a download link.
  ///
  ///
  /// Default values for [generateQr] and [generateLink] are true.
  static Future<void> generateQrCodeAndLink({
    String? url,
    bool? generateLink = true,
  }) async {
    final qrConfig = FlutterReleaseXConfig().config.qrCode;
    final isQrEnable = qrConfig.enabled;
    final isQrShowInConsole = qrConfig.showInCommand;
    final qrImgSize = qrConfig.size;
    final isQrSaveFile = qrConfig.saveFile;
    final qrImgSavePath = qrConfig.savePath;
    final qrCorrectionLevel = qrConfig.errorCorrectionLevel;

    // Directly accessing UploadState and updating it
    final uploadState = FlutterReleaseXUploadState();

    final String? uploadLink = uploadState.uploadLink;

    if (isQrEnable && (uploadLink != null || url != null)) {
      final qrCode = QrCode.fromData(
        data: url ?? uploadLink.toString(),
        errorCorrectLevel: getQrCorrectionLevel(qrCorrectionLevel),
      );
      final qrImg = QrImage(qrCode);

      if (isQrShowInConsole) {
        printQrCode(qrImg);
      }

      // Create an empty image with the same dimensions as the QR code
      final qrImage =
          img.Image(width: qrCode.moduleCount, height: qrCode.moduleCount);

      // Loop through each module of the QR code and set the pixel
      for (int x = 0; x < qrCode.moduleCount; x++) {
        for (int y = 0; y < qrCode.moduleCount; y++) {
          // Set pixel to black (0xFF000000) for dark modules, white (0xFFFFFFFF) for light modules
          qrImage.setPixel(
            x,
            y,
            qrImg.isDark(y, x)
                ? img.ColorFloat16.rgb(255, 255, 255)
                : img.ColorFloat16.rgb(0, 0, 0),
          );
        }
      }
      if (isQrSaveFile) {
        final scaledImage = img.copyResize(
          qrImage,
          width: qrImgSize,
          height: qrImgSize,
        );
        final file = File(qrImgSavePath);
        file.writeAsBytesSync(img.encodePng(scaledImage));
        showHighlight(
          firstMessage: 'QR code saved to',
          highLightmessage: qrImgSavePath,
        );
      }
    }
    if (generateLink == true && (uploadLink != null || url != null)) {
      FlutterReleaseXHelpers.showHighlight(
        firstMessage: '📥 Download the APK here:',
        highLightmessage: url ?? uploadLink,
      );
    }
  }

  /// Print the QR code to the console
  static void printQrCode(QrImage qr) {
    for (int y = 0; y < qr.moduleCount; y++) {
      String row = '';
      for (int x = 0; x < qr.moduleCount; x++) {
        row += qr.isDark(y, x)
            ? '██'
            : '  '; // Use '██' for black and '  ' for white
      }
      print(row);
    }
  }

//  ───────────────────────────────────── CORE  ─────────────────────────────────────

  static String getFlutterPath() {
    final config = FlutterReleaseXConfig().config;
    final flutterPath = config.flutterPath;

    if (flutterPath == null) {
      print(
        '⚠️ Custom Flutter Path configuration not found. We recommend specifying it in the your config yaml file for better functionality.',
      );
      return FlutterReleaseXKstrings.defaultFlutterBinPath;
    }

    return flutterPath;
  }

  /// Check if Flutter is available in the system
  static Future<bool> checkFlutterAvailability() async {
    try {
      final String flutterPath = getFlutterPath();
      final result = await Process.run(flutterPath, ['--version']);

      if (result.exitCode == 0) {
        return true;
      } else {
        print('Flutter not found: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('Flutter not found: $e');
      return false;
    }
  }

  /// Import env data.
  Future<Map<String, String>> loadGlobalEnv() async {
    final config = loadYaml('config.yaml');
    final Map<String, String> env = {};
    if (config['pipeline']['global_env'] != null) {
      config['pipeline']['global_env'].forEach((key, value) {
        env[key] = value;
      });
    }
    return env;
  }

  /// Execute Pipeline stages commands with improved robustness.
  static Future<ProcessResult> executeCommand(
    String command, {
    Map<String, String>? env,
    String? exitCondition,
  }) async {
    if (command.trim().isEmpty) {
      print('⚠️ Error: Command is empty. Skipping execution.');
      return ProcessResult(0, 1, '', 'Command is empty');
    }

    final shellType = Platform.isWindows ? 'powershell' : 'bash';
    final shellFlag = Platform.isWindows ? '-Command' : '-c';

    print('🔧 Executing Command: $command');

    // Start the process
    final process = await Process.start(
      shellType,
      [shellFlag, command],
      environment: env,
      runInShell: true,
    );

    // Store output in memory
    StringBuffer stdoutBuffer = StringBuffer();
    StringBuffer stderrBuffer = StringBuffer();

    // Listen to stdout
    stdout.write('📜 Output:');
    final stdoutSubscription =
        process.stdout.transform(SystemEncoding().decoder).listen((data) {
      stdout.write(data);
      stdoutBuffer.write(data);
    });

    // Listen to stderr
    final stderrSubscription =
        process.stderr.transform(SystemEncoding().decoder).listen((data) {
      stderr.write('⚠️ Error: $data');
      stderrBuffer.write(data);
    });

    // Wait for completion
    final exitCode = await process.exitCode;

    // Cancel subscriptions
    await stdoutSubscription.cancel();
    await stderrSubscription.cancel();

    // Get collected output
    final stdoutData = stdoutBuffer.toString();
    final stderrData = stderrBuffer.toString();

    // Custom exit condition handling
    if (exitCondition != null) {
      final customCondition = RegExp(exitCondition);
      if (customCondition.hasMatch(stdoutData) ||
          customCondition.hasMatch(stderrData)) {
        print("❌ Custom exit condition matched. Stopping the pipeline.");
        return ProcessResult(
            process.pid, 1, stdoutData, 'Custom exit condition matched');
      }
    }

    return ProcessResult(process.pid, exitCode, stdoutData, stderrData);
  }

  /// Executes Pipeline Step
  static Future<bool> _executeStep(
    PipelineStepModel step,
  ) async {
    print('🔧 Executing step: ${step.name}');

    /// Executed command result.
    ///
    /// `ProcessResult`
    final result = await executeCommand(step.command,
        exitCondition: step.customExitCondition);

    if (result.exitCode == 0) {
      return true;
    } else {
      print('❌ Step failed: ${step.name}');
      print('Error: ${result.stderr}');
      return false;
    }
  }

  /// Execute Pipeline
  static Future<void> executePipeline() async {
    final config = FlutterReleaseXConfig().config;

    final List<PipelineStepModel>? stages = config.pipelineSteps;

    for (final stage in stages!) {
      final String stageName = stage.name;
      print('\n🚀 Starting stage: $stageName');

      final success = await _executeStep(
        stage,
      );

      if (!success) {
        print('❌ Pipeline failed at step: $stageName');
        return;
      }

      /// Upload artifact, if `outputPath != null && uploadOutput = true`.
      if (stage.uploadOutput && stage.outputPath != null) {
        // Upload artifact to Cloud.
        await flutterReleaseXpromptUploadOption(stage.outputPath!);

        /// Generate QR code and link.
        await generateQrCodeAndLink();
      }

      /// Notify slack, if `notifySlack = true`.
      if (stage.notifySlack) {
        /// Notify Slack.
        await notifySlack();
      }

      print('✅ Stage completed: $stageName \n');
    }

    print('🎉 Pipeline executed successfully!');
  }

//  ───────────────────────────────────── UTILS  ─────────────────────────────────────

  /// Show Loading Spinner (Defaults to Earth 🌍)
  static void showLoading(String message, {bool useEarth = true}) {
    final frames = useEarth ? earthFrames : spinnerFrames;
    int i = 0;

    // Ensure no previous loader is running
    stopLoading();

    _loadingTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      stdout.write('\r$message ${frames[i % frames.length]}');
      i++;
    });
  }

  /// Stop the Loading Spinner
  static void stopLoading() {
    if (_loadingTimer != null) {
      // Cancel the spinner timer
      _loadingTimer!.cancel();
      _loadingTimer = null;

      // Clear the line after stopping
      stdout.write('\r \r');
    }
  }

  /// Print a highlighted message in the console.
  static void showHighlight({
    required String firstMessage,
    String? highLightmessage,
    String? lastMessage,
  }) {
    print('$firstMessage ${highlight(
      highLightmessage ?? "",
    )}  ${lastMessage ?? ""}');
  }

  static void showUserConfig() {
    final config = FlutterReleaseXConfig().config;
    final configPath = FlutterReleaseXConfig().configPath.trim();
    final flutterPath =
        config.flutterPath?.trim() ?? "No Custom Flutter Path Found";

    print('\n🔧 Current Configuration Overview\n');

    print('${getStatusEmoji(configPath.isNotEmpty)} Configuration File Path:');
    print(
        '   ${highlight(configPath.isNotEmpty ? configPath : "No configuration file path specified.")}\n');

    print('${getStatusEmoji(flutterPath.isNotEmpty)} Flutter Path:');
    print('   ${highlight(flutterPath)}\n');

    print('☁️ Upload Options:');
    print('   GitHub:');
    print(
        '      ${getStatusEmoji(config.uploadOptions.github.enabled)} Enabled: ${highlight(config.uploadOptions.github.enabled ? "Yes" : "No")}');
    if (config.uploadOptions.github.enabled) {
      print(
          '      Token: ${highlight(config.uploadOptions.github.token ?? "Not set")}');
      print(
          '      Repo: ${highlight(config.uploadOptions.github.repo ?? "Not set")}');
      print('      Tag: ${highlight(config.uploadOptions.github.tag)}\n');
    }

    print('   Google Drive:');
    print(
        '      ${getStatusEmoji(config.uploadOptions.googleDrive.enabled)} Enabled: ${highlight(config.uploadOptions.googleDrive.enabled ? "Yes" : "No")}');
    if (config.uploadOptions.googleDrive.enabled) {
      print(
          '      Client ID: ${highlight(config.uploadOptions.googleDrive.clientId ?? "Not set")}');
      print(
          '      Client Secret: ${highlight(config.uploadOptions.googleDrive.clientSecret ?? "Not set")}\n');
    }

    print('🎨 QR Code Settings:');
    print(
        '   ${getStatusEmoji(config.qrCode.enabled)} QR Code: ${highlight(config.qrCode.enabled ? "Enabled" : "Disabled")}');
    print('   Save Path: ${highlight(config.qrCode.savePath)}');
    print(
        '   Save QR Image: ${highlight(config.qrCode.saveFile ? "Yes" : "No")}');
    print('   Image Size: ${highlight(config.qrCode.size.toString())}');
    print(
        '   Show in Console: ${highlight(config.qrCode.showInCommand ? "Yes" : "No")}');
    print(
        '   Error Correction Level: ${highlight(config.qrCode.errorCorrectionLevel.toString())}\n');

    print(
        '✨ Use this information to ensure your configuration is set up correctly.');
  }

  static String getStatusEmoji(bool isSuccessful) {
    return isSuccessful ? '✅' : '⚠️';
  }

  static String highlight(String text) {
    return '\x1B[36m$text\x1B[0m'; // ANSI escape code for cyan text
  }

  /// For debug print only.
  ///
  /// Make sure to remove all these print before PR or Deployment.
  static void debugPrint(String message) {
    print('Debug Print, Delete me before deploying: $message');
  }

  /// Check Upload options availability
  ///
  /// Whether the upload option is configured or not.
  static bool isUploadOptionAvailable(
      FlutterReleaseXKenumUploadOptions option) {
    final config = FlutterReleaseXConfig().config;

    // GITHUB
    final gitHub = config.uploadOptions.github;
    final isGitHubEnabled = gitHub.enabled;
    final isGitHubRepoProvided =
        gitHub.repo != null && gitHub.repo!.trim().isNotEmpty;
    final isGitHubRepoToken =
        gitHub.token != null && gitHub.token!.trim().isNotEmpty;

    // GOOGLE DRIVE
    final googleDrive = config.uploadOptions.googleDrive;
    final isGoogleDriveEnabled = googleDrive.enabled;
    final isGoogleDriveClientIdProvided =
        googleDrive.clientId != null && googleDrive.clientId!.trim().isNotEmpty;
    final isGoogleDriveClientSecretProvided =
        googleDrive.clientSecret != null &&
            googleDrive.clientSecret!.trim().isNotEmpty;

    // DIAWI
    final diawi = config.uploadOptions.diawi;
    final isDiawiEnabled = diawi.enabled;
    final isDiawiTokenProvided =
        diawi.token != null && diawi.token!.trim().isNotEmpty;

    // AWS
    final aws = config.uploadOptions.aws;
    final isAWSEnabled = aws.enabled;
    final isAWSAccessKeyProvided =
        aws.accessKeyId != null && aws.accessKeyId!.trim().isNotEmpty;
    final isAWSSecretKeyProvided =
        aws.secretAccessKey != null && aws.secretAccessKey!.trim().isNotEmpty;
    final isAWSBucketProvided =
        aws.bucketName != null && aws.bucketName!.trim().isNotEmpty;

    // GITLAB
    final gitlab = config.uploadOptions.gitlab;
    final isGitlabEnabled = gitlab.enabled;
    final isGitlabTokenProvided =
        gitlab.token != null && gitlab.token!.trim().isNotEmpty;
    final isGitlabProjectIdProvided =
        gitlab.projectId != null && gitlab.projectId!.trim().isNotEmpty;

    // PLAY STORE
    final playStore = config.uploadOptions.playStore;
    final isPlayStoreEnabled = playStore.enabled;
    final isPlayStoreServiceAccountProvided = playStore.serviceAccountJsonPath != null &&
        playStore.serviceAccountJsonPath!.trim().isNotEmpty;
    final isPlayStorePackageNameProvided =
        playStore.packageName != null && playStore.packageName!.trim().isNotEmpty;

    // APP STORE
    final appStore = config.uploadOptions.appStore;
    final isAppStoreEnabled = appStore.enabled;
    final isAppStoreApiKeyProvided =
        appStore.apiKeyPath != null && appStore.apiKeyPath!.trim().isNotEmpty;
    final isAppStoreApiIssuerProvided =
        appStore.apiIssuer != null && appStore.apiIssuer!.trim().isNotEmpty;
    final isAppStoreAppIdProvided =
        appStore.appId != null && appStore.appId!.trim().isNotEmpty;

    switch (option) {
      case FlutterReleaseXKenumUploadOptions.github:
        if (isGitHubEnabled && isGitHubRepoProvided && isGitHubRepoToken) {
          return true;
        }
        return false;
      case FlutterReleaseXKenumUploadOptions.googleDrive:
        if (isGoogleDriveEnabled &&
            isGoogleDriveClientIdProvided &&
            isGoogleDriveClientSecretProvided) {
          return true;
        }
        return false;
      case FlutterReleaseXKenumUploadOptions.diawi:
        if (isDiawiEnabled && isDiawiTokenProvided) {
          return true;
        }
        return false;
      case FlutterReleaseXKenumUploadOptions.aws:
        if (isAWSEnabled &&
            isAWSAccessKeyProvided &&
            isAWSSecretKeyProvided &&
            isAWSBucketProvided) {
          return true;
        }
        return false;
      case FlutterReleaseXKenumUploadOptions.gitlab:
        if (isGitlabEnabled &&
            isGitlabTokenProvided &&
            isGitlabProjectIdProvided) {
          return true;
        }
        return false;
      case FlutterReleaseXKenumUploadOptions.playStore:
        if (isPlayStoreEnabled &&
            isPlayStoreServiceAccountProvided &&
            isPlayStorePackageNameProvided) {
          return true;
        }
        return false;
      case FlutterReleaseXKenumUploadOptions.appStore:
        if (isAppStoreEnabled &&
            isAppStoreApiKeyProvided &&
            isAppStoreApiIssuerProvided &&
            isAppStoreAppIdProvided) {
          return true;
        }
        return false;
    }
  }
}
