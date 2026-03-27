import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/services/hooks_service.dart';

/// `frx hooks` — manage git hooks powered by FRX.
///
/// Subcommands:
///   install    Install enabled hooks into .git/hooks/
///   uninstall  Remove FRX-managed hooks from .git/hooks/
///   list       Show configured hooks and their install status
///   run        Manually trigger a hook (also called by the git hook script)
///   validate   Validate your hooks configuration
class FlutterReleaseXHooksCommand extends Command {
  @override
  String get name => 'hooks';

  @override
  String get description =>
      'Manage git hooks (pre-commit, pre-push, etc.) powered by FRX pipelines.\n'
      '   Opt-in per hook via "enabled: true" in config.yaml.';

  FlutterReleaseXHooksCommand() {
    addSubcommand(_HooksInstallCommand());
    addSubcommand(_HooksUninstallCommand());
    addSubcommand(_HooksListCommand());
    addSubcommand(_HooksRunCommand());
    addSubcommand(_HooksValidateCommand());
  }
}

// ─────────────────────────────────────────── install ──────────────────────────

class _HooksInstallCommand extends Command {
  @override
  String get name => 'install';

  @override
  String get description =>
      'Install FRX-managed git hooks into .git/hooks/ for all enabled hooks.';

  _HooksInstallCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to the FRX config file.',
      defaultsTo: 'config.yaml',
    );
    argParser.addOption(
      'dir',
      abbr: 'd',
      help: 'Project root directory (default: current directory).',
      defaultsTo: '.',
    );
    argParser.addFlag(
      'dry-run',
      help: 'Preview what would be installed without writing any files.',
      negatable: false,
      defaultsTo: false,
    );
  }

  @override
  Future<void> run() async {
    final configPath = argResults!['config'] as String;
    final projectDir = _resolveDir(argResults!['dir'] as String);
    final dryRun = argResults!['dry-run'] as bool;

    FlutterReleaseXConfig().loadConfig(configPath);
    final hooksConfig = FlutterReleaseXConfig().config.hooks;

    if (dryRun) {
      _printDryRun(hooksConfig, projectDir);
      return;
    }

    await FlutterReleaseXHooksService.install(
      hooksConfig: hooksConfig,
      configPath: configPath,
      projectDir: projectDir,
    );
  }

  void _printDryRun(dynamic hooksConfig, String projectDir) {
    print('');
    print('🔍 Dry-run mode — no files will be written.');
    print('');
    final enabled = hooksConfig.enabledHooks;
    if (enabled.isEmpty) {
      print('   No enabled hooks found in config.');
    } else {
      print('   Would install:');
      for (final name in enabled.keys) {
        print('   → .git/hooks/$name');
      }
    }
    print('');
  }
}

// ─────────────────────────────────────────── uninstall ────────────────────────

class _HooksUninstallCommand extends Command {
  @override
  String get name => 'uninstall';

  @override
  String get description => 'Remove FRX-managed git hooks from .git/hooks/.';

  _HooksUninstallCommand() {
    argParser.addOption(
      'hook',
      abbr: 'H',
      help:
          'Name of a specific hook to remove (e.g. pre-commit). Omit to remove all FRX hooks.',
    );
    argParser.addOption(
      'dir',
      abbr: 'd',
      help: 'Project root directory (default: current directory).',
      defaultsTo: '.',
    );
  }

  @override
  Future<void> run() async {
    final hookName = argResults!['hook'] as String?;
    final projectDir = _resolveDir(argResults!['dir'] as String);

    await FlutterReleaseXHooksService.uninstall(
      hookName: hookName,
      projectDir: projectDir,
    );
  }
}

// ─────────────────────────────────────────────── list ─────────────────────────

class _HooksListCommand extends Command {
  @override
  String get name => 'list';

  @override
  String get description =>
      'List all configured hooks with their enabled status and install state.';

  _HooksListCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to the FRX config file.',
      defaultsTo: 'config.yaml',
    );
    argParser.addOption(
      'dir',
      abbr: 'd',
      help: 'Project root directory (default: current directory).',
      defaultsTo: '.',
    );
  }

  @override
  Future<void> run() async {
    final configPath = argResults!['config'] as String;
    final projectDir = _resolveDir(argResults!['dir'] as String);

    FlutterReleaseXConfig().loadConfig(configPath);
    final hooksConfig = FlutterReleaseXConfig().config.hooks;

    await FlutterReleaseXHooksService.list(
      hooksConfig: hooksConfig,
      projectDir: projectDir,
    );
  }
}

// ─────────────────────────────────────────────── run ──────────────────────────

class _HooksRunCommand extends Command {
  @override
  String get name => 'run';

  @override
  String get description =>
      'Manually run a hook by name. This is also called by the git hook script.\n'
      '   Usage: frx hooks run pre-commit';

  _HooksRunCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to the FRX config file.',
      defaultsTo: 'config.yaml',
    );
  }

  @override
  Future<void> run() async {
    final configPath = argResults!['config'] as String;

    if (argResults!.rest.isEmpty) {
      print('');
      print('❌ Usage: frx hooks run <hook-name>');
      print('');
      print('   Example: frx hooks run pre-commit');
      print('');
      print('   Available hook names:');
      for (final name in [
        'pre-commit',
        'commit-msg',
        'pre-push',
        'post-commit',
        'prepare-commit-msg',
      ]) {
        print('     $name');
      }
      print('');
      exit(1);
    }

    final hookName = argResults!.rest.first.trim().toLowerCase();

    FlutterReleaseXConfig().loadConfig(configPath);
    final hooksConfig = FlutterReleaseXConfig().config.hooks;

    await FlutterReleaseXHooksService.runHook(
      hookName: hookName,
      hooksConfig: hooksConfig,
      configPath: configPath,
      exitOnFailure: true,
    );
  }
}

// ────────────────────────────────────────────── validate ──────────────────────

class _HooksValidateCommand extends Command {
  @override
  String get name => 'validate';

  @override
  String get description =>
      'Validate your hooks configuration and show actionable errors.';

  _HooksValidateCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to the FRX config file.',
      defaultsTo: 'config.yaml',
    );
  }

  @override
  Future<void> run() async {
    final configPath = argResults!['config'] as String;

    FlutterReleaseXConfig().loadConfig(configPath);
    final hooksConfig = FlutterReleaseXConfig().config.hooks;

    print('');
    print('🔍 Validating hooks configuration...');
    print('');

    if (hooksConfig.isEmpty) {
      print('ℹ️  No hooks configured in config.yaml.');
      print('');
      print('   Add a hooks: section to get started. Example:');
      print('');
      print('   hooks:');
      print('     pre-commit:');
      print('       enabled: true');
      print('       steps:');
      print('         - name: "Analyze"');
      print('           command: "flutter analyze"');
      print('');
      return;
    }

    final valid = FlutterReleaseXHooksService.validateConfig(hooksConfig);

    if (valid) {
      print('✅ All hooks are valid!');
      print('');
      for (final entry in hooksConfig.hooks.entries) {
        final h = entry.value;
        final status = h.enabled ? '✅ enabled' : '⏸️  disabled';
        final source = h.hasPipeline
            ? '→ pipeline: ${h.runPipeline}'
            : '${h.steps.length} step(s)';
        print('   ${entry.key} — $status — $source');
      }
    } else {
      print('❌ Validation failed. Fix the errors above and try again.');
    }
    print('');
  }
}

// ─────────────────────────────────────────────── utils ────────────────────────

String _resolveDir(String dir) {
  if (dir == '.') return Directory.current.path;
  final d = Directory(dir);
  if (!d.existsSync()) {
    print('❌ Directory "$dir" does not exist.');
    exit(1);
  }
  return d.absolute.path;
}
