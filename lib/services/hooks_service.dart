import 'dart:io';

import 'package:flutter_release_x/helpers/helpers.dart';
import 'package:flutter_release_x/models/app_config_model.dart';

/// Marker embedded in every hook script written by FRX.
/// Used to identify and safely remove FRX-managed hooks.
const _kFrxHookMarker = '# MANAGED BY FRX (Flutter Release X) — DO NOT EDIT';

/// Result of running an individual hook step.
class HookStepResult {
  final String stepName;
  final bool passed;
  final bool skipped;
  final bool warned;
  final Duration duration;
  final String? note;

  const HookStepResult({
    required this.stepName,
    required this.passed,
    this.skipped = false,
    this.warned = false,
    required this.duration,
    this.note,
  });
}

/// Result of running an entire hook.
class HookRunResult {
  final String hookName;
  final bool success;
  final List<HookStepResult> stepResults;
  final Duration totalDuration;
  final String? pipelineRan;

  const HookRunResult({
    required this.hookName,
    required this.success,
    this.stepResults = const [],
    required this.totalDuration,
    this.pipelineRan,
  });
}

/// Service responsible for installing, uninstalling, listing, and running
/// FRX-managed git hooks.
class FlutterReleaseXHooksService {
  // ───────────────────────────────────────── INSTALL ────────────────────────

  /// Installs all **enabled** hooks from [hooksConfig] into `.git/hooks/`.
  ///
  /// - Creates `.git/hooks/` if it doesn't exist.
  /// - Writes a shell script (macOS/Linux) or batch/ps1 shim (Windows).
  /// - Makes the script executable on Unix systems.
  /// - Idempotent: re-running replaces existing FRX-managed scripts.
  /// - Skips any non-FRX hook file already present (won't clobber custom hooks).
  static Future<void> install({
    required HooksConfigModel hooksConfig,
    String? configPath,
    String? projectDir,
  }) async {
    // Locate .git directory
    final gitDir = await _findGitDir(projectDir ?? Directory.current.path);
    if (gitDir == null) {
      print(
          '❌ No .git directory found. Are you running this inside a git repository?');
      exit(1);
    }

    final hooksDir =
        Directory('${gitDir.path}${Platform.pathSeparator}hooks');
    if (!hooksDir.existsSync()) {
      hooksDir.createSync(recursive: true);
      print('📁 Created .git/hooks/ directory');
    }

    final enabledHooks = hooksConfig.enabledHooks;
    if (enabledHooks.isEmpty) {
      print('');
      print('ℹ️  No hooks have enabled: true in your config.');
      print(
          '   Set enabled: true under a hook in config.yaml and re-run "frx hooks install".');
      return;
    }

    int installed = 0;
    int skipped = 0;

    print('');
    print('🔧 Installing ${enabledHooks.length} hook(s)...');
    print('');

    for (final entry in enabledHooks.entries) {
      final hookName = entry.key;
      final hookFile = File(
          '${hooksDir.path}${Platform.pathSeparator}$hookName');

      // Check if an existing, non-FRX hook script is already there
      if (hookFile.existsSync()) {
        final existing = hookFile.readAsStringSync();
        if (!existing.contains(_kFrxHookMarker)) {
          print(
              '   ⚠️  Skipping "$hookName" — a custom hook already exists and was NOT written by FRX.');
          print(
              '      To replace it, manually remove .git/hooks/$hookName then re-run.');
          skipped++;
          continue;
        }
      }

      final script = Platform.isWindows
          ? _buildWindowsScript(hookName, configPath)
          : _buildUnixScript(hookName, configPath);

      hookFile.writeAsStringSync(script);

      // Make executable on Unix
      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', hookFile.path]);
      }

      print('   ✅ Installed: .git/hooks/$hookName');
      installed++;
    }

    print('');
    if (installed > 0) {
      print(
          '🎉 Done! $installed hook(s) installed${skipped > 0 ? ', $skipped skipped' : ''}.');
      print(
          '   Git will now run "frx hooks run <hook-name>" automatically.');
    } else if (skipped > 0) {
      print('⚠️  All hooks were skipped (custom hooks already present).');
    }
    print('');
  }

  // ─────────────────────────────────────── UNINSTALL ────────────────────────

  /// Removes FRX-managed hooks from `.git/hooks/`.
  ///
  /// If [hookName] is provided, removes only that hook.
  /// Otherwise removes all FRX-managed hooks.
  /// Non-FRX hooks are never touched.
  static Future<void> uninstall({
    String? hookName,
    String? projectDir,
  }) async {
    final gitDir = await _findGitDir(projectDir ?? Directory.current.path);
    if (gitDir == null) {
      print('❌ No .git directory found.');
      exit(1);
    }

    final hooksDir =
        Directory('${gitDir.path}${Platform.pathSeparator}hooks');
    if (!hooksDir.existsSync()) {
      print('ℹ️  No .git/hooks/ directory found — nothing to uninstall.');
      return;
    }

    final toRemove = <String>[];

    if (hookName != null) {
      toRemove.add(hookName.trim().toLowerCase());
    } else {
      // Find all FRX-managed hook files
      for (final entity in hooksDir.listSync()) {
        if (entity is File) {
          try {
            final content = entity.readAsStringSync();
            if (content.contains(_kFrxHookMarker)) {
              toRemove.add(entity.path.split(Platform.pathSeparator).last);
            }
          } catch (_) {
            // Ignore unreadable files
          }
        }
      }
    }

    if (toRemove.isEmpty) {
      print('ℹ️  No FRX-managed hooks found to uninstall.');
      return;
    }

    print('');
    print('🗑️  Uninstalling ${toRemove.length} hook(s)...');
    print('');

    int removed = 0;
    for (final name in toRemove) {
      final hookFile = File(
          '${hooksDir.path}${Platform.pathSeparator}$name');
      if (!hookFile.existsSync()) {
        print('   ⚠️  "$name" not found — skipping.');
        continue;
      }
      final content = hookFile.readAsStringSync();
      if (!content.contains(_kFrxHookMarker)) {
        print(
            '   ⚠️  "$name" was not installed by FRX — skipping to avoid data loss.');
        continue;
      }
      hookFile.deleteSync();
      print('   🗑️  Removed: .git/hooks/$name');
      removed++;
    }

    print('');
    print('✅ Done! $removed hook(s) removed.');
    print('');
  }

  // ──────────────────────────────────────────── LIST ────────────────────────

  /// Prints a summary table of all hooks in [hooksConfig] and their
  /// installation status on disk.
  static Future<void> list({
    required HooksConfigModel hooksConfig,
    String? projectDir,
  }) async {
    if (hooksConfig.isEmpty) {
      print('');
      print('📦 No hooks configured.');
      print('');
      print('   To get started, add a hooks section to your config.yaml:');
      print('');
      print('   hooks:');
      print('     pre-commit:');
      print('       enabled: true');
      print('       steps:');
      print('         - name: "Analyze"');
      print('           command: "flutter analyze"');
      print('');
      print(
          '   Run "frx hooks install" after adding your hooks.');
      print('');
      return;
    }

    final gitDir = await _findGitDir(projectDir ?? Directory.current.path);
    final hooksDir = gitDir != null
        ? Directory('${gitDir.path}${Platform.pathSeparator}hooks')
        : null;

    print('');
    print(
        '╔══════════════════════╦═════════╦═══════╦═══════════╦════════════════════════════╗');
    print(
        '║ Hook                 ║ Enabled ║ Steps ║ Installed ║ Source                     ║');
    print(
        '╠══════════════════════╬═════════╬═══════╬═══════════╬════════════════════════════╣');

    for (final entry in hooksConfig.hooks.entries) {
      final name = entry.key.padRight(20);
      final hook = entry.value;
      final enabled = hook.enabled ? '   ✅   ' : '   ❌   ';
      final steps = hook.steps.length.toString().padRight(5);

      // Check disk install status
      String installed = '    ❌    ';
      if (hooksDir != null) {
        final hookFile = File(
            '${hooksDir.path}${Platform.pathSeparator}${entry.key}');
        if (hookFile.existsSync()) {
          final content = hookFile.readAsStringSync();
          installed =
              content.contains(_kFrxHookMarker) ? '    ✅    ' : '  ⚠️ custom';
        }
      }

      final source = hook.hasPipeline
          ? '→ pipeline: ${hook.runPipeline}'.padRight(26)
          : (hook.hasSteps ? '${hook.steps.length} inline step(s)'.padRight(26) : '(none)'.padRight(26));

      print('║ $name ║$enabled║ $steps ║$installed ║ $source ║');
    }

    print(
        '╚══════════════════════╩═════════╩═══════╩═══════════╩════════════════════════════╝');
    print('');
    print('💡 Manage hooks:');
    print('   frx hooks install              Install all enabled hooks');
    print('   frx hooks uninstall            Remove all FRX-managed hooks');
    print(
        '   frx hooks uninstall --hook pre-commit   Remove a specific hook');
    print('   frx hooks run pre-commit       Manually trigger a hook');
    print('');
  }

  // ──────────────────────────────────────── RUN HOOK ────────────────────────

  /// Executes all steps of the hook named [hookName].
  ///
  /// Called both manually via `frx hooks run <name>` and automatically
  /// when git triggers the hook script.
  ///
  /// Returns a [HookRunResult] and exits with code 1 if the hook fails and
  /// [stopOnFailure] is `true` — this is what causes git to abort the commit.
  static Future<HookRunResult> runHook({
    required String hookName,
    required HooksConfigModel hooksConfig,
    String? configPath,
    bool exitOnFailure = true,
  }) async {
    final hook = hooksConfig.hooks[hookName];

    if (hook == null) {
      print(
          '❌ Hook "$hookName" is not configured in config.yaml.');
      print(
          '   Available hooks: ${hooksConfig.hooks.keys.join(', ')}');
      if (exitOnFailure) exit(1);
      return HookRunResult(
        hookName: hookName,
        success: false,
        totalDuration: Duration.zero,
      );
    }

    if (!hook.enabled) {
      print('ℹ️  Hook "$hookName" is disabled (enabled: false). Skipping.');
      return HookRunResult(
        hookName: hookName,
        success: true,
        totalDuration: Duration.zero,
      );
    }

    final totalStopwatch = Stopwatch()..start();

    print('');
    _printHookBanner(hookName, hook);

    final stepResults = <HookStepResult>[];
    bool overallSuccess = true;

    // ── Option A: delegate to a named FRX pipeline ───────────────────────────
    if (hook.hasPipeline) {
      print('   🔗 Delegating to FRX pipeline: "${hook.runPipeline}"');
      print('');
      try {
        await FlutterReleaseXHelpers.executePipeline(
            pipelineName: hook.runPipeline);
      } catch (e) {
        print('❌ Pipeline "${hook.runPipeline}" failed: $e');
        overallSuccess = false;
        if (hook.stopOnFailure && exitOnFailure) {
          _printSummary(hookName, stepResults, overallSuccess,
              totalStopwatch.elapsed, hook.runPipeline);
          exit(1);
        }
      }

      totalStopwatch.stop();
      _printSummary(hookName, stepResults, overallSuccess,
          totalStopwatch.elapsed, hook.runPipeline);

      return HookRunResult(
        hookName: hookName,
        success: overallSuccess,
        stepResults: stepResults,
        totalDuration: totalStopwatch.elapsed,
        pipelineRan: hook.runPipeline,
      );
    }

    // ── Option B: run inline steps ────────────────────────────────────────────
    if (!hook.hasSteps) {
      print('⚠️  Hook "$hookName" has no steps and no run_pipeline. Nothing to run.');
      totalStopwatch.stop();
      return HookRunResult(
        hookName: hookName,
        success: true,
        totalDuration: totalStopwatch.elapsed,
      );
    }

    for (int i = 0; i < hook.steps.length; i++) {
      final step = hook.steps[i];
      final stepStopwatch = Stopwatch()..start();

      print('   [${i + 1}/${hook.steps.length}] ▶  ${step.name}');
      if (step.description != null) {
        print('         ${step.description}');
      }

      // Validate working directory
      if (step.workingDirectory != null) {
        if (!Directory(step.workingDirectory!).existsSync()) {
          print(
              '   ❌ working_directory "${step.workingDirectory}" does not exist. Aborting step.');
          stepStopwatch.stop();
          final res = HookStepResult(
            stepName: step.name,
            passed: false,
            duration: stepStopwatch.elapsed,
            note: 'working_directory not found',
          );
          stepResults.add(res);
          if (!step.allowFailure && hook.stopOnFailure) {
            overallSuccess = false;
            if (exitOnFailure) {
              _printSummary(
                  hookName, stepResults, false, totalStopwatch.elapsed, null);
              exit(1);
            }
          }
          continue;
        }
      }

      final result = await FlutterReleaseXHelpers.executeCommand(
        step.command,
        env: step.env,
        workingDirectory: step.workingDirectory,
        timeoutSeconds: step.timeout,
      );

      stepStopwatch.stop();
      final elapsed = stepStopwatch.elapsed;

      if (result.exitCode == 0) {
        print(
            '   ✅ ${step.name} — passed (${_formatDuration(elapsed)})');
        stepResults.add(HookStepResult(
          stepName: step.name,
          passed: true,
          duration: elapsed,
        ));
      } else if (step.allowFailure) {
        print(
            '   ⚠️  ${step.name} — failed (allow_failure, continuing)');
        stepResults.add(HookStepResult(
          stepName: step.name,
          passed: false,
          warned: true,
          duration: elapsed,
          note: 'allowed failure',
        ));
      } else {
        print(
            '   ❌ ${step.name} — FAILED (exit code ${result.exitCode}) (${_formatDuration(elapsed)})');
        overallSuccess = false;
        stepResults.add(HookStepResult(
          stepName: step.name,
          passed: false,
          duration: elapsed,
        ));
        if (hook.stopOnFailure) {
          _printSummary(
              hookName, stepResults, false, totalStopwatch.elapsed, null);
          if (exitOnFailure) exit(1);
          break;
        }
      }
    }

    totalStopwatch.stop();
    _printSummary(
        hookName, stepResults, overallSuccess, totalStopwatch.elapsed, null);

    if (!overallSuccess && exitOnFailure) exit(1);

    return HookRunResult(
      hookName: hookName,
      success: overallSuccess,
      stepResults: stepResults,
      totalDuration: totalStopwatch.elapsed,
    );
  }

  // ────────────────────────────────────── HELPERS ───────────────────────────

  /// Finds the `.git` directory by walking up from [startDir].
  static Future<Directory?> _findGitDir(String startDir) async {
    var dir = Directory(startDir);
    while (true) {
      final gitDir =
          Directory('${dir.path}${Platform.pathSeparator}.git');
      if (gitDir.existsSync()) return gitDir;
      final parent = dir.parent;
      if (parent.path == dir.path) return null; // Reached filesystem root
      dir = parent;
    }
  }

  /// Generates a POSIX shell script that calls `frx hooks run <hookName>`.
  static String _buildUnixScript(String hookName, String? configPath) {
    final configArg =
        configPath != null && configPath != 'config.yaml'
            ? ' --config "$configPath"'
            : '';
    return '''#!/usr/bin/env bash
$_kFrxHookMarker
# Hook: $hookName
# Installed: ${DateTime.now().toIso8601String()}
#
# This script is automatically managed by FRX (Flutter Release X).
# Run "frx hooks uninstall" to remove it.

set -euo pipefail

# Locate frx executable
if command -v frx &> /dev/null; then
  FRX_CMD="frx"
elif command -v flutter_release_x &> /dev/null; then
  FRX_CMD="flutter_release_x"
else
  echo "⚠️  [FRX] frx not found in PATH. Skipping $hookName hook."
  echo "   Install FRX: dart pub global activate flutter_release_x"
  exit 0
fi

\$FRX_CMD hooks run $hookName$configArg
''';
  }

  /// Generates a Windows batch wrapper that calls `frx hooks run <hookName>`.
  static String _buildWindowsScript(String hookName, String? configPath) {
    final configArg =
        configPath != null && configPath != 'config.yaml'
            ? ' --config "$configPath"'
            : '';
    return '''@echo off
rem $_kFrxHookMarker
rem Hook: $hookName
rem Installed: ${DateTime.now().toIso8601String()}

where frx >nul 2>&1
if %errorlevel% equ 0 (
  frx hooks run $hookName$configArg
  exit /b %errorlevel%
) else (
  where flutter_release_x >nul 2>&1
  if %errorlevel% equ 0 (
    flutter_release_x hooks run $hookName$configArg
    exit /b %errorlevel%
  ) else (
    echo [FRX] frx not found in PATH. Skipping $hookName hook.
    exit /b 0
  )
)
''';
  }

  static void _printHookBanner(String hookName, HookModel hook) {
    final line = '═' * 60;
    print('╔$line╗');
    print('${'║  🪝  FRX Hook: $hookName'.padRight(61)}║');
    if (hook.description != null) {
      print('${'║  ${hook.description}'.padRight(61)}║');
    }
    print('╚$line╝');
    print('');
  }

  static void _printSummary(
    String hookName,
    List<HookStepResult> results,
    bool success,
    Duration total,
    String? pipeline,
  ) {
    print('');
    print('─' * 62);
    if (pipeline != null) {
      final icon = success ? '✅' : '❌';
      print('$icon  Hook "$hookName" → pipeline "$pipeline" '
          '${success ? 'passed' : 'FAILED'} (${_formatDuration(total)})');
    } else if (results.isNotEmpty) {
      final passed = results.where((r) => r.passed).length;
      final warned = results.where((r) => r.warned).length;
      final failed = results.where((r) => !r.passed && !r.warned).length;
      final icon = success ? '✅' : '❌';
      print(
          '$icon  Hook "$hookName" — $passed passed, $warned warned, $failed failed (${_formatDuration(total)})');

      for (final r in results) {
        final icon =
            r.passed ? '✅' : (r.warned ? '⚠️ ' : '❌');
        final note = r.note != null ? ' (${r.note})' : '';
        print('   $icon ${r.stepName}$note — ${_formatDuration(r.duration)}');
      }
    }
    print('─' * 62);
    print('');
  }

  static String _formatDuration(Duration d) {
    if (d.inSeconds < 1) return '${d.inMilliseconds}ms';
    if (d.inMinutes < 1) return '${d.inSeconds}s';
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }

  /// Validates the hook configuration and prints actionable errors.
  /// Returns `true` if validation passes.
  static bool validateConfig(HooksConfigModel hooksConfig) {
    if (hooksConfig.isEmpty) return true;

    bool valid = true;
    final errors = <String>[];
    final warnings = <String>[];

    for (final entry in hooksConfig.hooks.entries) {
      final name = entry.key;
      final hook = entry.value;

      if (!hook.hasSteps && !hook.hasPipeline) {
        warnings.add(
            'hooks.$name: No steps or run_pipeline. Hook will do nothing.');
      }

      if (hook.hasPipeline && hook.hasSteps) {
        warnings.add(
            'hooks.$name: Both run_pipeline and steps are set. Only run_pipeline will be used.');
      }

      for (int i = 0; i < hook.steps.length; i++) {
        final step = hook.steps[i];
        if (step.command.trim().isEmpty) {
          errors.add(
              'hooks.$name.steps[${i + 1}] "${step.name}": command is empty.');
          valid = false;
        }
        if (step.workingDirectory != null &&
            !Directory(step.workingDirectory!).existsSync()) {
          warnings.add(
              'hooks.$name.steps[${i + 1}] "${step.name}": working_directory "${step.workingDirectory}" does not exist yet.');
        }
      }
    }

    if (errors.isNotEmpty || warnings.isNotEmpty) {
      print('');
      for (final e in errors) { print('   ❌ $e'); }
      for (final w in warnings) { print('   ⚠️  $w'); }
      print('');
    }

    return valid;
  }
}
