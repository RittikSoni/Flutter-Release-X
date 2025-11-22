import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/constants/kplatforms.dart';
import 'package:flutter_release_x/helpers/helpers.dart';

class FlutterReleaseXBuildCommand extends Command {
  @override
  String get description =>
      'Build release builds, upload to the cloud, generate a QR code, and share on Slack seamlessly. If an Advanced Pipeline is defined, it overrides the default flow.';

  @override
  String get name => 'build';

  FlutterReleaseXBuildCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to the configuration file.',
      defaultsTo: 'config.yaml',
    );
    argParser.addFlag(
      'show-config',
      abbr: 's',
      help: 'Show the current configuration file path.',
      negatable: false,
      defaultsTo: false,
    );
    argParser.addOption(
      'target',
      abbr: 't',
      help:
          'Specify target platforms (comma-separated): ios,android,web,macos,windows,linux or use "all" to build for all platforms.',
      defaultsTo: 'android',
    );
  }

  @override
  Future<void> run() async {
    final configPath = argResults?['config'];
    final showConfig = argResults?['show-config'] ?? false;
    final target = argResults?['target'] as String;

    // Load config dynamically or use persisted one
    FlutterReleaseXConfig().loadConfig(configPath);

    if (showConfig) {
      FlutterReleaseXHelpers.showUserConfig();
      return;
    }

    /// Supported platforms for flutter default flow.
    const validPlatforms = {
      'ios',
      'android',
      'web',
      'macos',
      'windows',
      'linux',
    };

    final platforms = target.toLowerCase() == 'all'
        ? validPlatforms
        : target.split(',').map((e) => e.trim()).toSet();

    // Validate platform input
    for (var platform in platforms) {
      if (!validPlatforms.contains(platform)) {
        print('❌ Unsupported platform: $platform');
        exit(1);
      }
    }

    /// If Advance Pipeline is disabled, use Default Flow
    if (FlutterReleaseXConfig().config.pipelineSteps == null) {
      await FlutterReleaseXKplatforms.buildAndProcessPlatforms(platforms);
    } else {
      /// Advance Pipeline is enabled, go with user's custom flow
      await FlutterReleaseXHelpers.executePipeline();
      exit(0);
    }
  }
}
