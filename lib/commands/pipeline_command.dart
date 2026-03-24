import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_release_x/configs/config.dart';
import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:flutter_release_x/models/app_config_model.dart';

/// The `frx pipeline` command for managing and inspecting pipelines.
///
/// Subcommands:
/// - `list` — List all available pipelines with descriptions
/// - `validate` — Validate config and show detailed errors
/// - `run <name>` — Run a specific pipeline
class FlutterReleaseXPipelineCommand extends Command {
  @override
  String get description =>
      'Manage, inspect, and run pipelines. Use subcommands: list, validate, run.';

  @override
  String get name => 'pipeline';

  FlutterReleaseXPipelineCommand() {
    addSubcommand(_PipelineListCommand());
    addSubcommand(_PipelineValidateCommand());
    addSubcommand(_PipelineRunCommand());
    addSubcommand(_PipelineHelpCommand());
  }
}

/// `frx pipeline list` — Lists all available pipelines.
class _PipelineListCommand extends Command {
  @override
  String get description =>
      'List all available pipelines with their descriptions and step counts.';

  @override
  String get name => 'list';

  _PipelineListCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to the configuration file.',
      defaultsTo: 'config.yaml',
    );
  }

  @override
  Future<void> run() async {
    final configPath = argResults?['config'];
    FlutterReleaseXConfig().loadConfig(configPath);

    final config = FlutterReleaseXConfig().config;
    final pipelines = config.resolvedPipelines;

    if (pipelines == null || pipelines.isEmpty) {
      print('');
      print('📦 No pipelines configured.');
      print('');
      print('   To get started, add pipelines to your config.yaml:');
      print('');
      print('   pipelines:');
      print('     build:');
      print('       description: "Build the app"');
      print('       steps:');
      print('         - name: "Build APK"');
      print('           command: "flutter build apk --release"');
      print('');
      print('   Or use the legacy format:');
      print('   pipeline_steps:');
      print('     - name: "Build APK"');
      print('       command: "flutter build apk --release"');
      print('');
      print(
          '   📖 Docs: https://frx.elpisverse.com/docs/configuration#advance-pipeline');
      return;
    }

    print('');
    print(
        '╔═══════════════════════════════════════════════════════════════════════╗');
    print(
        '║                      Available Pipelines                            ║');
    print(
        '╠══════════════════════════╦═══════╦════════════════════════════════════╣');
    print(
        '║ Pipeline                 ║ Steps ║ Description                       ║');
    print(
        '╠══════════════════════════╬═══════╬════════════════════════════════════╣');

    for (final entry in pipelines.entries) {
      final pipeline = entry.value;
      final name = pipeline.name.length > 24
          ? '${pipeline.name.substring(0, 21)}...'
          : pipeline.name.padRight(24);
      final steps = pipeline.steps.length.toString().padRight(5);
      final desc = (pipeline.description ?? '—').length > 35
          ? '${pipeline.description!.substring(0, 32)}...'
          : (pipeline.description ?? '—').padRight(35);
      print('║ $name ║ $steps ║ $desc ║');
    }

    print(
        '╚══════════════════════════╩═══════╩════════════════════════════════════╝');
    print('');

    // Show available step features
    print('💡 Available step features:');
    print('   env, working_directory, timeout, retry, retry_delay, condition,');
    print('   continue_on_error, allow_failure, notify_slack, notify_teams,');
    print('   upload_output, output_path, custom_exit_condition, description');
    print('');
    print('   Run a pipeline: frx pipeline run <name>');
    print('   Validate config: frx pipeline validate');
    print('');
  }
}

/// `frx pipeline validate` — Validates pipeline configuration.
class _PipelineValidateCommand extends Command {
  @override
  String get description =>
      'Validate pipeline configuration and show detailed, actionable error messages.';

  @override
  String get name => 'validate';

  _PipelineValidateCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to the configuration file.',
      defaultsTo: 'config.yaml',
    );
  }

  @override
  Future<void> run() async {
    final configPath = argResults?['config'];
    FlutterReleaseXConfig().loadConfig(configPath);

    final config = FlutterReleaseXConfig().config;
    final pipelines = config.resolvedPipelines;

    if (pipelines == null || pipelines.isEmpty) {
      print('');
      print('⚠️ No pipelines to validate.');
      print(
          '   Add "pipelines:" or "pipeline_steps:" to your config.yaml first.');
      return;
    }

    print('');
    print('🔍 Validating ${pipelines.length} pipeline(s)...');
    print('');

    final errors = PipelineConfigValidator.validate(pipelines);

    if (errors.isEmpty) {
      print('✅ All pipelines are valid!');
      print('');

      // Print a summary of what was validated
      for (final entry in pipelines.entries) {
        final p = entry.value;
        print(
            '   ✅ "${entry.key}" — ${p.steps.length} steps${p.description != null ? ' (${p.description})' : ''}');

        for (final step in p.steps) {
          final features = <String>[];
          if (step.env != null) features.add('env');
          if (step.workingDirectory != null) features.add('working_dir');
          if (step.timeout != null) features.add('timeout:${step.timeout}s');
          if (step.retry > 0) features.add('retry:${step.retry}');
          if (step.condition != null) features.add('conditional');
          if (step.continueOnError) features.add('continue_on_error');
          if (step.allowFailure) features.add('allow_failure');
          if (step.uploadOutput) features.add('upload');
          if (step.notifySlack) features.add('slack');
          if (step.notifyTeams) features.add('teams');

          final featureStr =
              features.isNotEmpty ? ' [${features.join(', ')}]' : '';
          print('      • ${step.name}$featureStr');
        }
        print('');
      }
    } else {
      final errorCount = errors.where((e) => !e.isWarning).length;
      final warningCount = errors.where((e) => e.isWarning).length;

      print('Found $errorCount error(s) and $warningCount warning(s):');
      print('');

      for (final error in errors) {
        print('   ${error.toString()}');
      }

      print('');
      if (errorCount > 0) {
        print('❌ Fix the errors above before running the pipeline.');
      } else {
        print(
            '⚠️ Warnings found but pipeline can still run. Consider addressing them.');
      }
      print('');
    }
  }
}

/// `frx pipeline run <name>` — Runs a specific pipeline.
class _PipelineRunCommand extends Command {
  @override
  String get description => 'Run a specific pipeline by name.';

  @override
  String get name => 'run';

  _PipelineRunCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to the configuration file.',
      defaultsTo: 'config.yaml',
    );
  }

  @override
  Future<void> run() async {
    final configPath = argResults?['config'];
    FlutterReleaseXConfig().loadConfig(configPath);

    String? pipelineName;
    if (argResults!.rest.isNotEmpty) {
      pipelineName = argResults!.rest.first;
    }

    final config = FlutterReleaseXConfig().config;
    final pipelines = config.resolvedPipelines;

    if (pipelines == null || pipelines.isEmpty) {
      print('❌ No pipelines configured in config.');
      print('   Use "frx pipeline list" to see available pipelines.');
      exit(1);
    }

    // Validate before running
    final errors = PipelineConfigValidator.validate(pipelines);
    final criticalErrors = errors.where((e) => !e.isWarning).toList();

    if (criticalErrors.isNotEmpty) {
      print('');
      print(
          '❌ Pipeline validation failed with ${criticalErrors.length} error(s):');
      print('');
      for (final error in criticalErrors) {
        print('   ${error.toString()}');
      }
      print('');
      print(
          '   Fix the errors and try again. Run "frx pipeline validate" for full details.');
      exit(1);
    }

    // Show warnings but continue
    final warnings = errors.where((e) => e.isWarning).toList();
    if (warnings.isNotEmpty) {
      print('');
      print('⚠️ ${warnings.length} warning(s) found:');
      for (final w in warnings) {
        print('   ${w.toString()}');
      }
      print('');
    }

    await FlutterReleaseXHelpers.executePipeline(pipelineName: pipelineName);
    exit(0);
  }
}

/// `frx pipeline help` — Shows detailed pipeline feature reference.
class _PipelineHelpCommand extends Command {
  @override
  String get description =>
      'Show detailed help about pipeline features and configuration options.';

  @override
  String get name => 'help-all';

  @override
  Future<void> run() async {
    print('''

╔═══════════════════════════════════════════════════════════════════════╗
║                  FRX Pipeline — Feature Reference                   ║
╚═══════════════════════════════════════════════════════════════════════╝

📦 PIPELINE COMMANDS
   frx pipeline list              List all pipelines with descriptions
   frx pipeline validate          Validate config with detailed errors  
   frx pipeline run <name>        Run a specific pipeline by name
   frx pipeline help-all          Show this help reference
   frx build --pipeline <name>    Run a pipeline via the build command

📝 CONFIG FORMATS

   ┌─ New Format (recommended) ────────────────────────────────────────┐
   │ pipelines:                                                        │
   │   build:                                                          │
   │     description: "Build and release"                              │
   │     steps:                                                        │
   │       - name: "Build APK"                                         │
   │         command: "flutter build apk --release"                    │
   │                                                                   │
   │   test:                                                           │
   │     description: "Run tests"                                      │
   │     steps:                                                        │
   │       - name: "Unit Tests"                                        │
   │         command: "flutter test"                                   │
   └───────────────────────────────────────────────────────────────────┘

   ┌─ Legacy Format (still supported) ─────────────────────────────────┐
   │ pipeline_steps:                                                    │
   │   - name: "Build APK"                                             │
   │     command: "flutter build apk --release"                        │
   └───────────────────────────────────────────────────────────────────┘

⚙️ STEP FIELDS REFERENCE

   Required:
   ┌────────────────────────┬──────────────────────────────────────────┐
   │ name                   │ Step name (must be unique in pipeline)   │
   │ command                │ Shell command to execute                 │
   └────────────────────────┴──────────────────────────────────────────┘

   Execution Control:
   ┌────────────────────────┬───────────┬──────────────────────────────┐
   │ Field                  │ Default   │ Description                  │
   ├────────────────────────┼───────────┼──────────────────────────────┤
   │ working_directory      │ (cwd)     │ Directory to run command in  │
   │ env                    │ {}        │ Environment variables map    │
   │ timeout                │ (none)    │ Timeout in seconds           │
   │ retry                  │ 0         │ Number of retry attempts     │
   │ retry_delay            │ 5         │ Seconds between retries      │
   │ condition              │ (none)    │ Run only if command exits 0  │
   │ stop_on_failure        │ true      │ Halt pipeline on failure     │
   │ continue_on_error      │ false     │ Continue despite failure     │
   │ allow_failure          │ false     │ Mark as warning, not failure │
   │ custom_exit_condition  │ (none)    │ Regex/text to match as fail  │
   │ depends_on             │ []        │ Steps that must run first    │
   └────────────────────────┴───────────┴──────────────────────────────┘

   Output & Notifications:
   ┌────────────────────────┬───────────┬──────────────────────────────┐
   │ upload_output          │ false     │ Upload artifact after step   │
   │ output_path            │ (none)    │ Path to artifact to upload   │
   │ notify_slack           │ false     │ Notify Slack after step      │
   │ notify_teams           │ false     │ Notify Teams after step      │
   │ description            │ (none)    │ Human-readable description   │
   └────────────────────────┴───────────┴──────────────────────────────┘

💡 FULL-FEATURED EXAMPLE

   pipelines:
     ci:
       description: "Full CI pipeline"
       steps:
         - name: "Install Deps"
           command: "flutter pub get"
           timeout: 120
           description: "Install Flutter dependencies"

         - name: "Lint"
           command: "flutter analyze"
           custom_exit_condition: "issues found"
           allow_failure: true

         - name: "Unit Tests"
           command: "flutter test"
           retry: 2
           retry_delay: 3
           timeout: 300

         - name: "Build APK"
           command: "flutter build apk --release"
           timeout: 600
           upload_output: true
           output_path: "./build/app/outputs/flutter-apk/app-release.apk"
           notify_slack: true
           notify_teams: true
           env:
             BUILD_NUMBER: "42"

         - name: "Deploy Staging"
           command: "./scripts/deploy.sh"
           condition: "test -f ./scripts/deploy.sh"
           working_directory: "./deploy"
           env:
             DEPLOY_ENV: staging
           continue_on_error: true

📖 Full docs: https://frx.elpisverse.com
''');
  }
}
