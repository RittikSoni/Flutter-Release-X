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
# Define custom pipeline steps for advanced automation.
# If provided, this overrides the default build flow.
#
# Pipeline Step Fields:
#   - name: (Required) Name of the pipeline step
#   - command: (Required) Command to execute
#   - upload_output: (Optional) Upload artifact after step (default: false)
#   - output_path: (Optional) Path to artifact to upload
#   - notify_slack: (Optional) Send Slack notification after step (default: false)
#   - custom_exit_condition: (Optional) Stop pipeline if this text appears in output
#   - stop_on_failure: (Optional) Stop pipeline on failure (default: true)
#   - depends_on: (Optional) List of step names this step depends on
#
# Example pipelines for different frameworks:
#
# ──────────────────────────────────────────────────────────────────────────────
# FLUTTER / DART PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipeline_steps:
#   - name: "Install Dependencies"
#     command: "flutter pub get"
#     stop_on_failure: true
#
#   - name: "Run Tests"
#     command: "flutter test"
#     custom_exit_condition: "Test failed"
#     upload_output: false
#
#   - name: "Analyze Code"
#     command: "flutter analyze"
#     custom_exit_condition: "issues found"
#
#   - name: "Build APK"
#     command: "flutter build apk --release"
#     upload_output: true
#     output_path: "./build/app/outputs/flutter-apk/app-release.apk"
#     notify_slack: true
#
# ──────────────────────────────────────────────────────────────────────────────
# REACT / NEXT.JS / VITE PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipeline_steps:
#   - name: "Install Dependencies"
#     command: "npm install"
#     # or: "yarn install" or "pnpm install"
#
#   - name: "Run Tests"
#     command: "npm test"
#     custom_exit_condition: "Tests failed"
#
#   - name: "Lint Code"
#     command: "npm run lint"
#
#   - name: "Build Production"
#     command: "npm run build"
#     upload_output: true
#     output_path: "./dist"
#     notify_slack: true
#
# ──────────────────────────────────────────────────────────────────────────────
# PYTHON / DJANGO / FASTAPI PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipeline_steps:
#   - name: "Install Dependencies"
#     command: "pip install -r requirements.txt"
#     # or: "poetry install" or "pipenv install"
#
#   - name: "Run Tests"
#     command: "pytest"
#     # or: "python -m pytest" or "python manage.py test"
#     custom_exit_condition: "FAILED"
#
#   - name: "Lint Code"
#     command: "flake8 ."
#     # or: "pylint ." or "black --check ."
#
#   - name: "Build Package"
#     command: "python setup.py sdist bdist_wheel"
#     upload_output: true
#     output_path: "./dist"
#     notify_slack: true
#
# ──────────────────────────────────────────────────────────────────────────────
# .NET / C# PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipeline_steps:
#   - name: "Restore Packages"
#     command: "dotnet restore"
#
#   - name: "Run Tests"
#     command: "dotnet test"
#     custom_exit_condition: "Test Run Failed"
#
#   - name: "Build Solution"
#     command: "dotnet build --configuration Release"
#
#   - name: "Publish Application"
#     command: "dotnet publish -c Release -o ./publish"
#     upload_output: true
#     output_path: "./publish"
#     notify_slack: true
#
# ──────────────────────────────────────────────────────────────────────────────
# NODE.JS / EXPRESS PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipeline_steps:
#   - name: "Install Dependencies"
#     command: "npm ci"
#
#   - name: "Run Tests"
#     command: "npm test"
#
#   - name: "Build Application"
#     command: "npm run build"
#     upload_output: true
#     output_path: "./build"
#
# ──────────────────────────────────────────────────────────────────────────────
# VUE.JS / ANGULAR PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipeline_steps:
#   - name: "Install Dependencies"
#     command: "npm install"
#
#   - name: "Run Tests"
#     command: "npm run test:unit"
#
#   - name: "Build Production"
#     command: "npm run build"
#     upload_output: true
#     output_path: "./dist"
#     notify_slack: true
#
# ──────────────────────────────────────────────────────────────────────────────
# GO / GOLANG PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipeline_steps:
#   - name: "Download Dependencies"
#     command: "go mod download"
#
#   - name: "Run Tests"
#     command: "go test ./..."
#     custom_exit_condition: "FAIL"
#
#   - name: "Build Binary"
#     command: "go build -o app ./cmd/main.go"
#     upload_output: true
#     output_path: "./app"
#     notify_slack: true
#
# ──────────────────────────────────────────────────────────────────────────────
# DOCKER / CONTAINER PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipeline_steps:
#   - name: "Build Docker Image"
#     command: "docker build -t myapp:latest ."
#
#   - name: "Run Container Tests"
#     command: "docker run --rm myapp:latest npm test"
#
#   - name: "Save Docker Image"
#     command: "docker save myapp:latest -o myapp.tar"
#     upload_output: true
#     output_path: "./myapp.tar"
#
# ──────────────────────────────────────────────────────────────────────────────
# MIXED / CUSTOM PIPELINE
# ──────────────────────────────────────────────────────────────────────────────
# pipeline_steps:
#   - name: "Check Environment"
#     command: "node --version && python --version"
#
#   - name: "Run Script"
#     command: "./scripts/build.sh"
#     custom_exit_condition: "build failed"
#
#   - name: "Package Artifacts"
#     command: "tar -czf release.tar.gz ./dist"
#     upload_output: true
#     output_path: "./release.tar.gz"
#     notify_slack: true
#
# Uncomment and customize as needed:
# pipeline_steps: []
''';
  }
}
