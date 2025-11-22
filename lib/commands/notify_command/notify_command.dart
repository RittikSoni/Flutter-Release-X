import 'package:args/command_runner.dart';
import 'package:flutter_release_x/configs/config.dart';

import 'package:flutter_release_x/helpers/helpers.dart';

class FlutterReleaseXNotifyCommand extends Command {
  @override
  String get description =>
      'Send notifications to popular platforms like Slack and more.';

  @override
  String get name => 'notify';

  FlutterReleaseXNotifyCommand() {
    argParser.addOption(
      'platform',
      abbr: 'p',
      help: 'Specify the platform to notify (e.g., slack).',
      allowed: ['slack'],
      defaultsTo: 'slack',
    );
    argParser.addOption(
      'message',
      abbr: 'm',
      help: 'Message to send to the platform.',
    );
  }

  @override
  Future<void> run() async {
    // Load config dynamically or use persisted one
    FlutterReleaseXConfig().loadConfig('config.yaml');

    final platform = argResults?['platform'] as String?;
    final message = argResults?['message'] as String?;

    switch (platform) {
      case 'slack':
        await FlutterReleaseXHelpers.notifySlack(
          customSlackMsg: message,
          shareLink: false,
          shareQr: false,
        );
        break;
      default:
        print('❌ Unsupported platform: $platform');
        return;
    }
  }
}
