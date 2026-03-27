import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:flutter_release_x/constants/kstrings.dart';

class FlutterReleaseXInitCommand extends Command {
  @override
  final name = 'init';
  @override
  final description =
      'Initialize a new FRX project by creating a starter config.yaml file with helpful comments and examples.';

  FlutterReleaseXInitCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Custom name for the config file (default: config.yaml)',
      defaultsTo: 'config.yaml',
    );
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite existing config file if it exists',
      negatable: false,
      defaultsTo: false,
    );
  }

  @override
  void run() {
    final configFileName = argResults?['config'] as String? ?? 'config.yaml';
    final force = argResults?['force'] ?? false;

    final configFile = File(configFileName);

    // Check if config file already exists
    if (configFile.existsSync() && !force) {
      print('⚠️  Config file "$configFileName" already exists!');
      print('');
      print('   To overwrite it, use: frx init --force');
      print('   Or specify a different name: frx init --config my-config.yaml');
      exit(1);
    }

    // Generate the starter config content
    final configContent = _generateStarterConfig();

    try {
      // Write the config file
      configFile.writeAsStringSync(configContent);
      print('✅ Successfully created "$configFileName"!');
      print('');
      print('📝 Next steps:');
      print('   1. Open "$configFileName" and configure your settings');
      print('   2. Add your API keys and tokens for cloud uploads');
      print('   3. Run "frx build" to start building and releasing!');
      print('');
      print(
          '📖 For detailed setup instructions, visit: ${FlutterReleaseXKstrings.documentaion} or ${FlutterReleaseXKstrings.documentaion2}');
    } catch (e) {
      print('❌ Failed to create config file: $e');
      exit(1);
    }
  }

  String _generateStarterConfig() {
    return '''# Flutter Release X Configuration
# This file configures how FRX builds, uploads, and distributes your Flutter apps.
# 
# 📖 Documentation: ${FlutterReleaseXKstrings.documentaion}
# 💡 Tip: Uncomment and fill in the sections you want to use!

# ──────────────────────────────────────────────────────────────────────────────
# FLUTTER PATH (Optional)
# ──────────────────────────────────────────────────────────────────────────────
# Specify the path to your Flutter binary if it's not in your PATH.
# Leave empty to use the default Flutter command from your PATH.
#
# Examples:
#   Windows: C:/dev/flutter/bin/flutter.bat
#   macOS/Linux: /Users/USER_NAME/development/flutter/bin/flutter
flutter_path: # Leave empty to use default

# ──────────────────────────────────────────────────────────────────────────────
# UPLOAD OPTIONS
# ──────────────────────────────────────────────────────────────────────────────
# Configure where you want to upload your builds.
# Set enabled: true and fill in the required credentials for each service.
upload_options:
  # ────────────────────────────────────────────────────────────────────────────
  # GitHub Releases
  # ────────────────────────────────────────────────────────────────────────────
  # Upload builds to GitHub Releases
  # Get token: https://github.com/settings/tokens/new (requires 'repo' scope)
  github:
    enabled: false
    token: # Required: YOUR_GITHUB_TOKEN
    repo: # Required: OWNER/REPO_NAME (e.g., username/my-app)
    tag: v0.0.1 # Optional: Release tag/version (default: v0.0.1)

  # ────────────────────────────────────────────────────────────────────────────
  # Google Drive
  # ────────────────────────────────────────────────────────────────────────────
  # Upload builds to Google Drive
  # Setup: https://console.cloud.google.com/ (enable Drive API, create OAuth credentials)
  google_drive:
    enabled: false
    client_id: # Required: YOUR_CLIENT_ID
    client_secret: # Required: YOUR_CLIENT_SECRET

  # ────────────────────────────────────────────────────────────────────────────
  # Diawi
  # ────────────────────────────────────────────────────────────────────────────
  # Upload IPA/APK to Diawi for fast ad-hoc distribution
  # Get token: https://dashboard.diawi.com/profile/api
  diawi:
    enabled: false
    token: # Required: YOUR_DIAWI_TOKEN
    wall_of_apps: false # Optional: Display on Diawi wall of apps (default: false)
    find_by_udid: false # Optional: Allow finding by UDID (default: false)
    callback_url: "" # Optional: URL to notify when upload completes
    installation_notifications: false # Optional: Enable installation notifications (default: false)
    password: "" # Optional: Password protection for download link
    comment: "" # Optional: Comment/description for the upload

  # ────────────────────────────────────────────────────────────────────────────
  # AWS S3
  # ────────────────────────────────────────────────────────────────────────────
  # Upload builds to AWS S3 bucket
  # Setup: Create IAM user with S3 upload permissions, create S3 bucket
  aws:
    enabled: false
    access_key_id: # Required: YOUR_AWS_ACCESS_KEY_ID
    secret_access_key: # Required: YOUR_AWS_SECRET_ACCESS_KEY
    region: us-east-1 # Optional: AWS region (default: us-east-1)
    bucket_name: # Required: your-bucket-name
    key_prefix: flutter-release-x # Optional: Prefix for uploaded files (default: empty)

  # ────────────────────────────────────────────────────────────────────────────
  # GitLab
  # ────────────────────────────────────────────────────────────────────────────
  # Upload releases to GitLab
  # Get token: https://gitlab.com/-/user_settings/personal_access_tokens (requires 'api' scope)
  gitlab:
    enabled: false
    token: # Required: YOUR_GITLAB_TOKEN
    project_id: # Required: "12345678" (found in project settings)
    tag: v0.0.1 # Optional: Release tag (default: v0.0.1)
    ref: main # Optional: Branch or commit SHA (default: main)
    host: https://gitlab.com # Optional: GitLab host URL (default: https://gitlab.com, use for self-hosted instances)

  # ────────────────────────────────────────────────────────────────────────────
  # Google Play Store
  # ────────────────────────────────────────────────────────────────────────────
  # Upload AAB to Google Play Store
  # Setup: Create service account in Google Cloud, grant access in Play Console
  play_store:
    enabled: false
    service_account_json_path: # Required: ./path/to/service-account.json
    package_name: # Required: com.example.app
    track: internal # Optional: Release track - internal, alpha, beta, or production (default: internal)
    release_name: # Optional: Custom release name (e.g., "Release v1.0.0")

  # ────────────────────────────────────────────────────────────────────────────
  # Apple App Store
  # ────────────────────────────────────────────────────────────────────────────
  # Upload IPA to App Store Connect
  # Setup: Generate API key in App Store Connect, download .p8 file
  app_store:
    enabled: false
    api_key_path: # Required: ./path/to/AuthKey_XXXXXXXXXX.p8
    api_issuer: # Required: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx (UUID format)
    app_id: # Required: "1234567890" (App Store Connect App ID)
    bundle_id: # Optional: com.example.app (iOS app bundle identifier)

  # ────────────────────────────────────────────────────────────────────────────
  # Slack Notifications
  # ────────────────────────────────────────────────────────────────────────────
  # Send build notifications to Slack
  # Setup: Create Slack app, add bot token, get channel ID
  # Guide: See README.md for detailed Slack setup instructions
  slack:
    enabled: false
    bot_user_oauth_token: # Required: xoxb-XXXXXXXXX-XXXXXXXXX-XXXXXXXXXXXXX
    default_channel_id: # Required: CXXXXXXXXX (Slack channel ID)
    share_QR: true # Optional: Share QR code in Slack (default: true)
    share_link: true # Optional: Share download link in Slack (default: true)
    custom_message: "🚀 Check out the latest build! Download your app now!" # Optional: Custom message
    mention_users: [] # Optional: List of Slack user IDs to mention (e.g., ["U0XXXXXXX"])

  # ────────────────────────────────────────────────────────────────────────────
  # Microsoft Teams Notifications
  # ────────────────────────────────────────────────────────────────────────────
  # Send build notifications to Microsoft Teams
  # Setup: Create incoming webhook in Teams channel
  teams:
    enabled: false
    webhook_url: # Required: YOUR_WEBHOOK_URL
    share_QR: true # Optional: Share QR code in Teams (default: true)
    share_link: true # Optional: Share download link in Teams (default: true)
    custom_message: "🚀 Check out the latest build! Download your app now!" # Optional: Custom message
    mention_users: [] # Optional: List of user names (webhooks don't support @mentions)

# ──────────────────────────────────────────────────────────────────────────────
# QR CODE SETTINGS
# ──────────────────────────────────────────────────────────────────────────────
# Configure QR code generation for quick build sharing
# All fields are optional with sensible defaults
qr_code:
  enabled: true # Optional: Generate QR codes (default: true)
  save_file: true # Optional: Save QR code image to file (default: true)
  show_in_command: true # Optional: Display QR code in terminal (default: true)
  size: 256 # Optional: QR code size in pixels (default: 256)
  error_correction_level: low # Optional: Error correction level - low, medium, quartile, high (default: low)
  save_path: "./release-qr-code.png" # Optional: Path to save QR code (default: ./release-qr-code.png)

# ──────────────────────────────────────────────────────────────────────────────
# ADVANCED PIPELINE (Optional)
# ──────────────────────────────────────────────────────────────────────────────
# Define custom pipelines for advanced automation.
# If provided, pipelines override the default build flow.
#
# 📖 Run "frx pipeline help-all" for a complete feature reference.
#
# Pipeline Commands:
#   frx pipeline list              List all pipelines
#   frx pipeline validate          Validate config with detailed errors
#   frx pipeline run <name>        Run a specific pipeline
#   frx build --pipeline <name>    Run a pipeline via build command
#
# ──────────────────────────────────────────────────────────────────────────────
# FORMAT: Multiple Named Pipelines (recommended)
# ──────────────────────────────────────────────────────────────────────────────
#
# pipelines:
#   build:
#     description: "Build and release the app"
#     steps:
#       - name: "Install Deps"
#         command: "flutter pub get"
#         timeout: 120
#         description: "Install Flutter dependencies"
#
#       - name: "Build APK"
#         command: "flutter build apk --release"
#         timeout: 600
#         upload_output: true
#         output_path: "./build/app/outputs/flutter-apk/app-release.apk"
#         notify_slack: true
#
#   test:
#     description: "Run tests and linting"
#     steps:
#       - name: "Unit Tests"
#         command: "flutter test"
#         retry: 2
#         retry_delay: 3
#         timeout: 300
#
#       - name: "Lint"
#         command: "flutter analyze"
#         custom_exit_condition: "issues found"
#         allow_failure: true
#
# ──────────────────────────────────────────────────────────────────────────────
# FORMAT: Legacy (still supported, treated as a single "default" pipeline)
# ──────────────────────────────────────────────────────────────────────────────
#
# pipeline_steps:
#   - name: "Build APK"
#     command: "flutter build apk --release"
#     upload_output: true
#     output_path: "./build/app/outputs/flutter-apk/app-release.apk"
#
# ──────────────────────────────────────────────────────────────────────────────
# STEP FIELDS REFERENCE
# ──────────────────────────────────────────────────────────────────────────────
#
# Required:
#   name                    Step name (must be unique within pipeline)
#   command                 Shell command to execute
#
# Execution Control (all optional):
#   working_directory       Directory to run command in (default: current dir)
#   env                     Environment variables map, e.g. { MY_VAR: "value" }
#   timeout                 Timeout in seconds (kills step if exceeded)
#   retry                   Number of retry attempts on failure (default: 0)
#   retry_delay             Seconds between retries (default: 5)
#   condition               Shell command — run step only if this exits 0
#   stop_on_failure         Halt pipeline on failure (default: true)
#   continue_on_error       Continue pipeline despite failure (default: false)
#   allow_failure           Mark as warning instead of failure (default: false)
#   custom_exit_condition   Regex/text in output that triggers failure
#   depends_on              List of step names that must run first
#
# Output & Notifications (all optional):
#   upload_output           Upload artifact after step (default: false)
#   output_path             Path to artifact to upload
#   notify_slack            Notify Slack after step (default: false)
#   notify_teams            Notify Microsoft Teams after step (default: false)
#   description             Human-readable description shown in logs
#
# ──────────────────────────────────────────────────────────────────────────────
# FULL-FEATURED EXAMPLE
# ──────────────────────────────────────────────────────────────────────────────
#
# pipelines:
#   ci:
#     description: "Full CI/CD pipeline"
#     steps:
#       - name: "Install Deps"
#         command: "flutter pub get"
#         timeout: 120
#         description: "Install Flutter dependencies"
#
#       - name: "Lint"
#         command: "flutter analyze"
#         custom_exit_condition: "issues found"
#         allow_failure: true
#         description: "Run static analysis (warnings only)"
#
#       - name: "Unit Tests"
#         command: "flutter test"
#         retry: 2
#         retry_delay: 3
#         timeout: 300
#         description: "Run unit tests with retry"
#
#       - name: "Build APK"
#         command: "flutter build apk --release"
#         timeout: 600
#         upload_output: true
#         output_path: "./build/app/outputs/flutter-apk/app-release.apk"
#         notify_slack: true
#         notify_teams: true
#         env:
#           BUILD_NUMBER: "42"
#           FLAVOR: "production"
#
#       - name: "Deploy Staging"
#         command: "./scripts/deploy.sh"
#         condition: "test -f ./scripts/deploy.sh"
#         working_directory: "./deploy"
#         env:
#           DEPLOY_ENV: staging
#         continue_on_error: true
#         description: "Deploy to staging (optional)"
#
# ──────────────────────────────────────────────────────────────────────────────
# REACT / NEXT.JS / VITE PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipelines:
#   web_build:
#     description: "Build and deploy web app"
#     steps:
#       - name: "Install Dependencies"
#         command: "npm ci"
#         timeout: 120
#       - name: "Run Tests"
#         command: "npm test"
#         retry: 1
#         custom_exit_condition: "Tests failed"
#       - name: "Build Production"
#         command: "npm run build"
#         upload_output: true
#         output_path: "./dist"
#         notify_slack: true
#
# ──────────────────────────────────────────────────────────────────────────────
# PYTHON / DJANGO / FASTAPI PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipelines:
#   python_ci:
#     description: "Python CI pipeline"
#     steps:
#       - name: "Install Dependencies"
#         command: "pip install -r requirements.txt"
#       - name: "Run Tests"
#         command: "pytest"
#         custom_exit_condition: "FAILED"
#         retry: 1
#       - name: "Lint Code"
#         command: "flake8 ."
#         allow_failure: true
#       - name: "Build Package"
#         command: "python setup.py sdist bdist_wheel"
#         upload_output: true
#         output_path: "./dist"
#         notify_slack: true
#
# ──────────────────────────────────────────────────────────────────────────────
# DOCKER / CONTAINER PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipelines:
#   docker_build:
#     description: "Build and push Docker image"
#     steps:
#       - name: "Build Docker Image"
#         command: "docker build -t myapp:latest ."
#         timeout: 600
#       - name: "Run Container Tests"
#         command: "docker run --rm myapp:latest npm test"
#         retry: 1
#       - name: "Save Docker Image"
#         command: "docker save myapp:latest -o myapp.tar"
#         upload_output: true
#         output_path: "./myapp.tar"
#
# Uncomment and customize as needed:
# pipelines: {}

# ──────────────────────────────────────────────────────────────────────────────
# GIT HOOKS (Optional — Opt-In)
# ──────────────────────────────────────────────────────────────────────────────
# Run commands automatically on git events (pre-commit, pre-push, etc.)
# Similar to Husky, but powered by FRX pipelines & steps.
#
# 📖 Get started:
#   1. Configure your hooks below (set enabled: true)
#   2. Run: frx hooks install       → writes scripts to .git/hooks/
#   3. Run: frx hooks list          → see all hooks and their status
#   4. Run: frx hooks run pre-commit → manually test a hook
#   5. Run: frx hooks uninstall     → remove all FRX-managed hooks
#
# ──────────────────────────────────────────────────────────────────────────────
# SUPPORTED HOOK NAMES (any git hook name is valid)
# ──────────────────────────────────────────────────────────────────────────────
#   pre-commit       — runs before a commit is created (most common)
#   commit-msg       — validates the commit message
#   prepare-commit-msg — edits the commit message template
#   pre-push         — runs before git push
#   post-commit      — runs after a commit is created
#   pre-merge-commit — runs before a merge commit
#   ... and all other standard git hooks
#
# ──────────────────────────────────────────────────────────────────────────────
# STEP FIELDS (same pattern as pipeline steps)
# ──────────────────────────────────────────────────────────────────────────────
#   name             (required) Step label shown in output
#   command          (required) Shell command to run
#   description      (optional) Human-readable description
#   allow_failure    (optional) If true, step failure is a warning (default: false)
#   env              (optional) Environment variables: { KEY: value }
#   working_directory (optional) Override working directory for this step
#   timeout          (optional) Kill step after N seconds
#
# ──────────────────────────────────────────────────────────────────────────────
# EXAMPLE: Inline Steps
# ──────────────────────────────────────────────────────────────────────────────
# hooks:
#   pre-commit:
#     enabled: true
#     description: "Lint and test before every commit"
#     stop_on_failure: true
#     steps:
#       - name: "Analyze"
#         command: "flutter analyze"
#         description: "Run static analysis"
#
#       - name: "Format Check"
#         command: "dart format --set-exit-if-changed ."
#         allow_failure: true   # Warn but don't block commit
#
#       - name: "Unit Tests"
#         command: "flutter test"
#         timeout: 120
#
#   commit-msg:
#     enabled: false
#     description: "Enforce conventional commit message format"
#     steps:
#       - name: "Validate Message"
#         command: "grep -qE '^(feat|fix|docs|style|refactor|test|chore)(\\(.+\\))?: .+' \$1 || (echo 'Invalid commit message format' && exit 1)"
#
#   pre-push:
#     enabled: false
#     description: "Full test suite before push"
#     steps:
#       - name: "Tests"
#         command: "flutter test"
#         timeout: 300
#
# ──────────────────────────────────────────────────────────────────────────────
# EXAMPLE: Delegate to an FRX Pipeline
# ──────────────────────────────────────────────────────────────────────────────
# hooks:
#   pre-push:
#     enabled: true
#     run_pipeline: ci   # Runs the "ci" pipeline defined in pipelines: above
#
# ──────────────────────────────────────────────────────────────────────────────
#
# hooks: {}   # Uncomment and configure to enable hooks
''';
  }
}
