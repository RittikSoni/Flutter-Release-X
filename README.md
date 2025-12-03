# Flutter Release X

[![Pub Version](https://img.shields.io/pub/v/flutter_release_x.svg)](https://pub.dev/packages/flutter_release_x)
[![Pub Points](https://img.shields.io/pub/points/flutter_release_x.svg)](https://pub.dev/packages/flutter_release_x)
[![Issues](https://img.shields.io/github/issues/RittikSoni/Flutter-Release-X)](https://github.com/RittikSoni/Flutter-Release-X/issues)
[![📖 - docs](https://img.shields.io/badge/📖-docs-13D4D4)](https://frx.elpisverse.com)
[![License](https://img.shields.io/github/license/RittikSoni/Flutter-Release-X)](LICENSE)
[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/RittikSoni)
[![YouTube](https://img.shields.io/badge/YouTube-%23FF0000.svg?logo=YouTube&logoColor=white)](https://www.youtube.com/@king_rittik?sub_confirmation=1)
[![Discord](https://img.shields.io/badge/Discord-%235865F2.svg?logo=discord&logoColor=white)](https://discord.gg/Tmn6BKwSnr)

[![Flutter Release X](assets/frx_gif_banner.gif)](https://frx.elpisverse.com)

[![Watch the tutorial on YouTube](assets/flutter_release_x_tutorial.jpg)](https://youtu.be/8WuSyGD3Smg?si=_DOKxBANN-rXvggN)

**Flutter Release X** is a powerful command-line tool that transforms your Flutter app release process, quick and easy. Designed for efficiency and ease of use, it allows you to:

- **Simplify Your Workflow**: Replace complex CI/CD pipelines with a single command to effortlessly generate and distribute release builds.
- **Seamless Cloud Integration**: Easily configure cloud platforms like GitHub, Google Drive, AWS S3, GitLab, Google Play Store, Apple App Store, and Diawi by simply providing your API keys and tokens. Once configured, enjoy hassle-free, automatic uploads.
- **Instant Distribution**: Automatically generate QR codes and download links for your builds, enabling quick and easy distribution to your team or users with no additional effort.
- **Multi-Platform Support**: Build and distribute for Android, iOS, Web, macOS, Windows, and Linux from a single command.

With **Flutter Release X**, streamline your release process, enhance collaboration, and reduce time-to-market—all while focusing on what truly matters: building amazing apps.

## 📖 Documentation

📚 **[Read the Full FRX Docs](https://frx.elpisverse.com)**

Learn everything about FRX, from **setup to quick examples to advanced configurations**.

---

## Table of Contents

- [✨ What's New](#whats-new)
- [🌟 Features Overview](#features-overview)
- [💿 Installation](#installation)
- [🛠 Usage](#usage)
- [⚙️ Configuration](#configuration)
  - [Config file with example](#config-file)
  - [Flutter Path](#flutter-path)
  - [Upload Options](#upload-options)
    - [GitHub](#github)
    - [Google Drive](#google-drive)
    - [Diawi](#diawi)
    - [AWS S3](#aws-s3)
    - [GitLab](#gitlab)
    - [Google Play Store](#google-play-store)
    - [Apple App Store](#apple-app-store)
    - [Slack](#slack)
  - [QR Code Generation Settings](#qr-code-generation-settings)
  - [Advance Pipeline](#advance-pipeline)
- [✅ Steps for Setup](#steps-for-setup)
- [🌐 Cloud Integration](#cloud-integration)
  - [GitHub Setup](#github-configuration)
  - [Google Drive Setup](#google-drive-configuration)
  - [Diawi Setup](#diawi-configuration)
  - [AWS S3 Setup](#aws-s3-configuration)
  - [GitLab Setup](#gitlab-configuration)
  - [Google Play Store Setup](#google-play-store-configuration)
  - [Apple App Store Setup](#apple-app-store-configuration)
- [🔔 Notification Setup Guides](#notification-setup-guides)
  - [Slack Setup Guide](#slack-configuration-setup-guide)
  - [Microsoft Teams Setup Guide](#microsoft-teams-configuration-setup-guide)
- [📱 QR Code Configuration](#qr-code-configuration)
- [🔐 .gitignore Configuration](#recommended-gitignore-configuration)
- [⚖️ License](#license)
- [🌟 Want to Connect?](#want-to-connect)
- [🤝 Contributors](#contributors)
- [💖 Contribute or Support (optional)](#support-the-package-optional)

## What's New

| Feature                  | Description                                                                                                                                                             |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Advanced Pipeline**    | Automate and streamline your CI/CD pipeline with the new advanced pipeline feature, integrating multiple steps in one command.                                          |
| **Multi-Platform Build** | Build for all supported platforms (`ios, android, web, macos, windows, linux`) using `--target all` for faster releases or just specify it like `frx build -t ios,web`. |
| **Notification System**  | Send real-time notifications to popular platforms like Slack using `frx notify`.                                                                                        |

## Features Overview

The table below outlines the current status of various features. Features marked with **"Available via Advanced Pipeline"** are not part of the basic Flutter Release X setup but can be enabled through our Advanced Pipeline feature for enhanced automation.

| Feature                      | Status        | Description                                                                                                                                                                      | Achievable via Advanced Pipeline   |
| ---------------------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| ✨ **Advanced Pipeline**     | ✅ New        | Streamline and automate your entire CI/CD workflow in one command.                                                                                                               | —                                  |
| **APK Builds**               | ✅ Integrated | Fully integrated APK build process.                                                                                                                                              | —                                  |
| **GitHub Upload**            | ✅ Integrated | Directly upload your builds to a GitHub repository for seamless sharing.                                                                                                         | —                                  |
| **Google Drive Upload**      | ✅ Integrated | Securely store your builds in Google Drive.                                                                                                                                      | —                                  |
| **Upload Link Generation**   | ✅ Integrated | Automatically generate and share download links for your builds.                                                                                                                 | —                                  |
| **QR Code Generation**       | ✅ Integrated | Instantly generate QR codes for quick access to your build downloads.                                                                                                            | —                                  |
| **Slack Integration**        | ✅ Integrated | Keep your team updated by sharing builds directly on Slack.                                                                                                                      | —                                  |
| **iOS Builds**               | ✅ Integrated | iOS build support is not available by default.                                                                                                                                   | ✅ Available via Advanced Pipeline |
| **Windows Builds**           | ✅ Integrated | Windows build support is not available by default.                                                                                                                               | ✅ Available via Advanced Pipeline |
| **macOS Builds**             | ✅ Integrated | macOS build support is not available by default.                                                                                                                                 | ✅ Available via Advanced Pipeline |
| **Linux Builds**             | ✅ Integrated | Linux build support is not available by default.                                                                                                                                 | ✅ Available via Advanced Pipeline |
| **AWS S3 Upload**            | ✅ Integrated | Scalable cloud storage uploads through AWS S3 with support for custom regions and key prefixes.                                                                                  | —                                  |
| **GitLab Upload**            | ✅ Integrated | Direct upload to GitLab repositories for seamless version control and release management.                                                                                        | —                                  |
| **Google Play Store Upload** | ✅ Integrated | Streamline your Android app distribution via the Google Play Store with support for multiple tracks (internal, alpha, beta, production).                                         | —                                  |
| **Apple App Store Upload**   | ✅ Integrated | Simplify iOS app distribution with the Apple App Store Connect API integration.                                                                                                  | —                                  |
| **Diawi Upload**             | ✅ Integrated | Upload IPA/APK to Diawi for fast ad-hoc distribution - generates short install links and QR codes, with optional password protection and link expiry for secure tester installs. | —                                  |

> **Note:** Features marked as "Available via Advanced Pipeline" require configuration through the Advanced Pipeline option in Flutter Release X. For further details, please refer to the [Official frx documentation](https://frx.elpisverse.com).

> **Tip:** Checkout Cookbook for quick implementation [Cookbook](https://frx.elpisverse.com/docs/Cookbook/advance-cookbook)

## Installation

You can install Flutter Release X globally using `dart`:

```bash
dart pub global activate flutter_release_x
```

Alternatively, add it as a dependency in your `pubspec.yaml`:

```bash
dart pub add flutter_release_x
```

## Usage

Flutter Release X provides easy commands to build, upload, and manage your releases. Here are the main commands:

| Command                                           | Description                                                                                      |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `frx build`                                       | Builds the release APK, uploads to Cloud, and generates a QR code & link.                        |
| `frx build -s`                                    | Displays the current configuration settings. This helps verify if your setup is correct.         |
| `frx build -c <path_to_config>`                   | Use this flag to specify a custom configuration file path, overriding the default `config.yaml`. |
| `frx build --target all`                          | Builds release builds for all supported platforms (iOS, Android, Web, macOS, Windows, Linux).    |
| `frx notify --platform slack --message 'message'` | Sends a notification to Slack with a custom message.                                             |
| `frx notify --platform teams --message 'message'` | Sends a notification to Microsoft Teams with a custom message.                                   |

### Example

- To build the release APK, upload it to Cloud, and generate a QR code & Downloadable link:

  ```bash
  frx build
  ```

- To build release builds for all platforms, upload to Cloud, and generate a QR code & downloadable link:

  ```bash
  frx build --target all
  ```

- To build only for Android and iOS:

  ```bash
  frx build -t android,ios
  ```

- To notify on popular platforms like Slack or Microsoft Teams with a custom message:

  ```bash
  frx notify --platform slack --message ":rocket: New Release Available!"
  ```

  or

  ```bash
  frx notify -p slack -m ":rocket: New Release Available!"
  ```

- To notify Microsoft Teams:

  ```bash
  frx notify --platform teams --message ":rocket: New Release Available!"
  ```

  or

  ```bash
  frx notify -p teams -m ":rocket: New Release Available!"
  ```

- To verify your configuration, run:

  `--show-config`: Displays the current configuration settings. By default, it reads from `config.yaml`. If a custom file path is provided, it reads from the specified file. Use this option to verify that the setup is correctly configured.

  ```bash
  frx build -s
  ```

- `--config`: Use this flag to specify a custom configuration file path, overriding the default `config.yaml`. This allows you to point to a specific configuration file as needed.

  ```bash
  frx build -c config/file/path
  ```

## Configuration

Create a `config.yaml` file in the root directory of your project to specify your upload options and QR code generation settings:

## Config file

```yaml
# Path to Flutter binary
# Example for Windows: C:/dev/flutter/bin/flutter.bat
# Example for macOS: /Users/USER_NAME/development/flutter/bin/flutter
flutter_path: FLUTTER/BINARY/PATH

upload_options:
  github:
    enabled: true
    token: YOUR_GITHUB_TOKEN # Required: Personal Access Token for GitHub
    repo: REPO/PATH # Required: GitHub repository path, e.g., RittikSoni/Flutter-Release-X
    tag: v0.0.1 # Release tag (e.g., version number)

  google_drive:
    enabled: true
    client_id: YOUR_CLIENT_ID # Required: Google API Client ID
    client_secret: YOUR_CLIENT_SECRET # Required: Google API Client Secret

  diawi:
    enabled: true
    token: YOUR_DIAWI_TOKEN # Required: Diawi API Token (get from https://www.diawi.com/profile/api)
    wall_of_apps: false # Optional: Display on Diawi wall of apps (default: false)
    find_by_udid: false # Optional: Allow finding by UDID (default: false)
    callback_url: "" # Optional: URL to notify when upload completes
    installation_notifications: false # Optional: Enable installation notifications (default: false)
    password: "" # Optional: Password protection for the download link
    comment: "" # Optional: Comment/description for the upload

  aws:
    enabled: false
    access_key_id: YOUR_AWS_ACCESS_KEY_ID # Required: AWS Access Key ID
    secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY # Required: AWS Secret Access Key
    region: us-east-1 # Optional: AWS region (default: us-east-1)
    bucket_name: your-bucket-name # Required: S3 bucket name
    key_prefix: flutter-release-x # Optional: Prefix for uploaded files (default: empty)

  gitlab:
    enabled: false
    token: YOUR_GITLAB_TOKEN # Required: GitLab Personal Access Token
    project_id: "12345678" # Required: GitLab Project ID (found in project settings)
    tag: v0.0.1 # Optional: Release tag (default: v0.0.1)
    ref: main # Optional: Branch or commit SHA from which to create the tag (default: main)
    host: https://gitlab.com # Optional: GitLab host URL (default: https://gitlab.com, use for self-hosted instances)

  play_store:
    enabled: false
    service_account_json_path: ./path/to/service-account.json # Required: Path to Google Play Service Account JSON file
    package_name: com.example.app # Required: Android app package name
    track: internal # Optional: Release track - internal, alpha, beta, or production (default: internal)
    release_name: "Release v1.0.0" # Optional: Custom release name

  app_store:
    enabled: false
    api_key_path: ./path/to/AuthKey_XXXXXXXXXX.p8 # Required: Path to App Store Connect API Key (.p8 file)
    api_issuer: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx # Required: App Store Connect API Key Issuer ID (UUID format)
    app_id: "1234567890" # Required: App Store Connect App ID
    bundle_id: com.example.app # Optional: iOS app bundle identifier

  slack:
    enabled: true
    bot_user_oauth_token: YOUR_BOT_TOKEN # Required: Slack Bot OAuth Token, e.g., xoxb-XXXXXXXXX-XXXXXXXXX-XXXXXXXXXXXXX
    default_channel_id: CHANNEL_ID # Required: Slack channel ID, e.g., CXXXXXXXXX
    share_QR: true # Optional: Share QR code in Slack (default: true)
    share_link: true # Optional: Share build download link in Slack (default: true)
    custom_message: "🚀 Check out the latest build! Download your app now!" # Custom message to accompany the link
    mention_users: ["U0XXXXXXX", "U08XXXXXXXX"] # List of Slack user/member IDs to mention. Note: not username or display name.

  teams:
    enabled: false
    webhook_url: YOUR_WEBHOOK_URL # Required: Microsoft Teams Incoming Webhook URL
    share_QR: true # Optional: Share QR code in Teams (default: true)
    share_link: true # Optional: Share build download link in Teams (default: true)
    custom_message: "🚀 Check out the latest build! Download your app now!" # Custom message to accompany the link
    mention_users: ["John Doe", "Jane Smith"] # List of Teams user names to mention

# QR Code generation settings
qr_code:
  enabled: true # Whether to generate QR codes (true/false)
  save_file: true # Save the QR code image to the file system (true/false)
  show_in_command: true # Display QR code in the command line output (true/false)
  size: 256 # Size of the generated QR code (pixels)
  error_correction_level: low # Error correction level: low, medium, quartile, high
  save_path: "./release-qr-code.png" # File path to save the QR code image

# Advanced Pipeline Configuration [OPTIONAL]
# This section allows you to define multiple pipeline steps that can be executed in sequence. Each step can have its own commands, dependencies, and upload options.

# If a custom pipeline is provided, it will override the default flow and behavior.
# Ensure that the pipeline steps are properly defined to reflect the intended execution order.

# e.g.,
pipeline_steps:
  - name: "Build APK"
    command: "flutter build apk --release"
    customExitCondition: "error: some specific error message" # Stop if this error appears in the output
    upload_output: true # Enable upload for this step
    output_path: "./build/app/outputs/flutter-apk/app-release.apk" # APK path
    notify_slack: false # Do not notify Slack after this step

  - name: "Run Tests"
    command: "flutter test"
    customExitCondition: "Test failed" # Stop if tests fail
    upload_output: false # No upload for this step
    notify_slack: true # Notify Slack after tests complete

  - name: "Lint"
    command: "flutter analyze"
    customExitCondition: "issues found" # Stop if issues found

  - name: "Package Release"
    command: "node --version"
    customExitCondition: "version mismatch" # Stop if version mismatch is found
    upload_output: true # Upload to cloud on success
    output_path: "./release-package.zip" # Path to release package
    notify_slack: true # Notify on Slack on success

  - name: "Deploy to Cloud"
    command: "./deploy_to_cloud.sh"
    customExitCondition: "deployment failed" # Stop if deployment fails
    upload_output: false # No upload as deployment is handled separately
    notify_slack: true # Notify on Slack on success

# Note: The order of steps in the pipeline is crucial!
# Each step depends on the successful completion of the previous step.
# If a step fails due to a custom exit condition, the pipeline will halt immediately,
# and subsequent steps will not be executed. Ensure that custom exit conditions are properly defined
# to avoid unwanted interruptions in the pipeline flow.
```

## Flutter Path

| Key            | Description                | Example                                                                                                |
| -------------- | -------------------------- | ------------------------------------------------------------------------------------------------------ |
| `flutter_path` | Path to the Flutter binary | `C:/dev/flutter/bin/flutter.bat` (Windows), `/Users/USER_NAME/development/flutter/bin/flutter` (macOS) |

---

## Upload Options

### GitHub

| Key       | Description                        | Required | Example                         |
| --------- | ---------------------------------- | -------- | ------------------------------- |
| `enabled` | Enable GitHub upload               | Yes      | `true`                          |
| `token`   | Personal Access Token for GitHub   | Yes      | `YOUR_GITHUB_TOKEN`             |
| `repo`    | GitHub repository path             | Yes      | `RittikSoni/Flutter-Release-X`  |
| `tag`     | Release tag (e.g., version number) | No       | `v0.0.1` (Defaults to `v0.0.1`) |

### Google Drive

| Key             | Description                | Required | Example              |
| --------------- | -------------------------- | -------- | -------------------- |
| `enabled`       | Enable Google Drive upload | Yes      | `true`               |
| `client_id`     | Google API Client ID       | Yes      | `YOUR_CLIENT_ID`     |
| `client_secret` | Google API Client Secret   | Yes      | `YOUR_CLIENT_SECRET` |

### Diawi

| Key                          | Description                               | Required | Example                                                           |
| ---------------------------- | ----------------------------------------- | -------- | ----------------------------------------------------------------- |
| `enabled`                    | Enable Diawi upload                       | Yes      | `true`                                                            |
| `token`                      | Diawi API Token                           | Yes      | Get from [Diawi Profile](https://dashboard.diawi.com/profile/api) |
| `wall_of_apps`               | Display on Diawi wall of apps             | No       | `false` (default)                                                 |
| `find_by_udid`               | Allow finding by UDID                     | No       | `false` (default)                                                 |
| `callback_url`               | URL to notify when upload completes       | No       | `""`                                                              |
| `installation_notifications` | Enable installation notifications         | No       | `false` (default)                                                 |
| `password`                   | Password protection for the download link | No       | `""`                                                              |
| `comment`                    | Comment/description for the upload        | No       | `""`                                                              |

### AWS S3

| Key                 | Description                                 | Required | Example                      |
| ------------------- | ------------------------------------------- | -------- | ---------------------------- |
| `enabled`           | Enable AWS S3 upload                        | Yes      | `true`                       |
| `access_key_id`     | AWS Access Key ID                           | Yes      | `YOUR_AWS_ACCESS_KEY_ID`     |
| `secret_access_key` | AWS Secret Access Key                       | Yes      | `YOUR_AWS_SECRET_ACCESS_KEY` |
| `region`            | AWS region                                  | No       | `us-east-1` (default)        |
| `bucket_name`       | S3 bucket name                              | Yes      | `your-bucket-name`           |
| `key_prefix`        | Prefix for uploaded files (organizes files) | No       | `flutter-release-x`          |

> **Note:** The S3 bucket must have public read permissions for direct URL access, or you'll need to use presigned URLs. Check your bucket's public access settings in the AWS Console.

### GitLab

| Key          | Description                                       | Required | Example                          |
| ------------ | ------------------------------------------------- | -------- | -------------------------------- |
| `enabled`    | Enable GitLab upload                              | Yes      | `true`                           |
| `token`      | GitLab Personal Access Token                      | Yes      | Get from GitLab profile settings |
| `project_id` | GitLab Project ID (found in project settings)     | Yes      | `"12345678"`                     |
| `tag`        | Release tag (e.g., version number)                | No       | `v0.0.1` (default)               |
| `ref`        | Branch or commit SHA from which to create the tag | No       | `main` (default)                 |
| `host`       | GitLab host URL (for self-hosted instances)       | No       | `https://gitlab.com` (default)   |

### Google Play Store

| Key                         | Description                                   | Required | Example                                                 |
| --------------------------- | --------------------------------------------- | -------- | ------------------------------------------------------- |
| `enabled`                   | Enable Google Play Store upload               | Yes      | `true`                                                  |
| `service_account_json_path` | Path to Google Play Service Account JSON file | Yes      | `./path/to/service-account.json`                        |
| `package_name`              | Android app package name                      | Yes      | `com.example.app`                                       |
| `track`                     | Release track                                 | No       | `internal` (Options: internal, alpha, beta, production) |
| `release_name`              | Custom release name                           | No       | `"Release v1.0.0"`                                      |

> **Note:** Requires a Google Play Service Account with appropriate permissions. The service account must have access to your app in the Play Console.

### Apple App Store

| Key            | Description                                  | Required | Example                                |
| -------------- | -------------------------------------------- | -------- | -------------------------------------- |
| `enabled`      | Enable App Store upload                      | Yes      | `true`                                 |
| `api_key_path` | Path to App Store Connect API Key (.p8 file) | Yes      | `./path/to/AuthKey_XXXXXXXXXX.p8`      |
| `api_issuer`   | App Store Connect API Key Issuer ID (UUID)   | Yes      | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `app_id`       | App Store Connect App ID                     | Yes      | `"1234567890"`                         |
| `bundle_id`    | iOS app bundle identifier                    | No       | `com.example.app`                      |

> **Note:** Full IPA upload via API requires proper JWT signing. For production uploads, consider using Transporter, Fastlane, or Xcode Organizer for more reliable uploads.

### Slack

| Key                    | Description                                   | Required | Example                                                   |
| ---------------------- | --------------------------------------------- | -------- | --------------------------------------------------------- |
| `enabled`              | Enable Slack upload                           | Yes      | `true`                                                    |
| `bot_user_oauth_token` | Slack Bot OAuth Token                         | Yes      | `YOUR_BOT_TOKEN`                                          |
| `default_channel_id`   | Slack channel ID                              | Yes      | `CXXXXXXXXX`                                              |
| `share_QR`             | Whether to share QR code on Slack             | No       | `true` (default)                                          |
| `share_link`           | Whether to share build download link on Slack | No       | `true` (default)                                          |
| `custom_message`       | Custom message to share with the build link   | No       | `"🚀 Check out the latest build! Download your app now!"` |
| `mention_users`        | List of Slack user/member IDs to mention      | No       | `["U0XXXXXXX", "U08XXXXXXXX"]`                            |

### Microsoft Teams

| Key              | Description                                    | Required | Example                                                                                                  |
| ---------------- | ---------------------------------------------- | -------- | -------------------------------------------------------------------------------------------------------- |
| `enabled`        | Enable Microsoft Teams notifications           | Yes      | `true`                                                                                                   |
| `webhook_url`    | Microsoft Teams Incoming Webhook URL           | Yes      | Get from Teams channel connectors                                                                        |
| `share_QR`       | Whether to share QR code in Teams              | No       | `true` (default)                                                                                         |
| `share_link`     | Whether to share build download link in Teams  | No       | `true` (default)                                                                                         |
| `custom_message` | Custom message to share with the build link    | No       | `"🚀 Check out the latest build! Download your app now!"`                                                |
| `mention_users`  | List of Teams user names to include in message | No       | `["John Doe", "Jane Smith"]` (Note: Webhooks don't support @mentions, names will be shown as plain text) |

---

## QR Code Generation Settings

| Key                      | Description                                          | Default                 | Example                                      |
| ------------------------ | ---------------------------------------------------- | ----------------------- | -------------------------------------------- |
| `enabled`                | Whether to generate QR codes                         | `true`                  | `true`                                       |
| `save_file`              | Whether to save the QR code image to the file system | `true`                  | `true`                                       |
| `show_in_command`        | Whether to display the QR code in the command line   | `true`                  | `true`                                       |
| `size`                   | Size of the generated QR code (in pixels)            | `256`                   | `256`                                        |
| `error_correction_level` | Error correction level for the QR code               | `low`                   | `low` (Options: low, medium, quartile, high) |
| `save_path`              | File path to save the QR code image                  | `./release-qr-code.png` | `./release-qr-code.png`                      |

## Advance Pipeline

| Field                     | Description                                                                                                                                                                                  | Example Value                                                                          | Required | Default Value |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | -------- | ------------- |
| **name**                  | The name of the pipeline step.                                                                                                                                                               | "Build APK"                                                                            | Yes      | N/A           |
| **command**               | The command to run for this pipeline step.                                                                                                                                                   | `flutter build apk --release`                                                          | Yes      | N/A           |
| **upload_output**         | Whether to upload the output from this step.                                                                                                                                                 | `true` or `false`                                                                      | No       | `false`       |
| **output_path**           | The file path where the output is stored (if applicable).                                                                                                                                    | `./build/app/outputs/flutter-apk/app-release.apk`                                      | No       | N/A           |
| **notify_slack**          | Whether to notify Slack after this step completes.                                                                                                                                           | `true` or `false`                                                                      | No       | `false`       |
| **custom_exit_condition** | Custom condition for when to **stop** the pipeline step. It checks for a specific match in the `stdout` or `stderr`. If matched, the pipeline stops. If not matched, the pipeline continues. | `"error: some specific error message"` (Stop if a specific error occurs in the output) | No       | N/A           |

## Steps for Setup

1. **Configure config.yaml**
   Create a config.yaml file with the settings shown above. If you have a custom file path, you can specify it with the -c flag.
2. **Generate Cloud Credentials**
   For cloud uploads (GitHub or Google Drive), follow these steps:

   - GitHub Configuration

     - Generate a Personal Access Token (PAT) in GitHub and add it to your config.yaml.

   - Google Drive Configuration
     - Create a Google Cloud Project and enable the Google Drive API.
     - Generate OAuth 2.0 credentials for your app and add the client_id and client_secret to your config.yaml.

3. **Generate Slack Credentials** (Optional)

4. **Run the Tool**
   After setting up the configuration, run:

   ```bash
   frx build
   ```

   This command will build your Flutter project, upload it, and generate a QR code & shareable link.

## Cloud Integration

### Github Configuration

### Generating a GitHub Personal Access Token

To enable your Flutter CLI tool to upload and delete releases on GitHub, you'll need to generate a **Personal Access Token (PAT)** with the appropriate permissions. Follow the steps below to create and configure your token.

#### Steps to Generate a GitHub Token

1. **Open the GitHub Token Generation Page**:

   - [Generate GitHub Token](https://github.com/settings/tokens/new).

2. **Set the Token Name**:

   - In the **Note** field, enter a descriptive name for your token, such as `Flutter Release X Token`.

3. **Select Scopes**:

   - Under **Select scopes**, check the following permissions:
     - `repo` (Full control of private repositories)
       - This includes access to public and private repositories, which is required for uploading and deleting releases.

4. **Generate the Token**:

   - Click the **Generate token** button at the bottom of the page.
   - Copy the token immediately, as you won’t be able to see it again.

5. **Set Up Your Project**:

   ```yaml
   github:
     enabled: true
     token: YOUR_GITHUB_TOKEN
   ```

### Google Drive Configuration

To upload files to Google Drive, follow these steps to set up your credentials:

1. **Create a Google Cloud Project**:

   - Go to the [Google Cloud Console](https://console.cloud.google.com/).
   - Create a new project or select an existing one.

2. **Enable the Drive API**:

   - In the Google Cloud Console, navigate to **APIs & Services > Library**.
   - Search for "Google Drive API" and enable it.

3. **Create OAuth 2.0 Credentials**:

   - Go to **APIs & Services > Credentials**.
   - Click on **Create Credentials** and select **OAuth Client ID**.
   - Configure the consent screen if prompted.
   - Set the application type to **Desktop App**.
   - Note down the generated **Client ID** and **Client Secret**.

4. **Set Up Your Project**:

   ```yaml
   google_drive:
     enabled: true
     client_id: YOUR_CLIENT_ID
     client_secret: YOUR_CLIENT_SECRET
   ```

   By following these steps, your application will be able to authenticate with Google Drive using the client ID and secret to upload files.

### Diawi Configuration

Diawi is a service for distributing iOS and Android apps via direct download links. To configure Diawi:

1. **Create a Diawi Account**:

   - Go to [Diawi](https://www.diawi.com/) and create an account.

2. **Get Your API Token**:

   - Log in to your Diawi account.
   - Go to [Profile > API](https://dashboard.diawi.com/profile/api).
   - Copy your API token.

3. **Set Up Your Project**:
   ```yaml
   diawi:
     enabled: true
     token: YOUR_DIAWI_TOKEN
     wall_of_apps: false
     find_by_udid: false
   ```

### AWS S3 Configuration

To upload files to AWS S3, you'll need AWS credentials with S3 upload permissions:

1. **Create AWS Credentials**:

   - Go to the [AWS IAM Console](https://console.aws.amazon.com/iam/).
   - Create a new user or use an existing one.
   - Attach a policy with S3 upload permissions (e.g., `AmazonS3FullAccess` or a custom policy).
   - Create an Access Key ID and Secret Access Key.

2. **Create an S3 Bucket**:

   - Go to the [S3 Console](https://console.aws.amazon.com/s3/).
   - Create a new bucket or use an existing one.
   - Note: For public access, configure bucket permissions appropriately.

3. **Set Up Your Project**:
   ```yaml
   aws:
     enabled: true
     access_key_id: YOUR_AWS_ACCESS_KEY_ID
     secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY
     region: us-east-1
     bucket_name: your-bucket-name
     key_prefix: flutter-release-x
   ```

> **Important:** Ensure your S3 bucket has the appropriate permissions. For public downloads, enable public read access. For private files, consider using presigned URLs.

### GitLab Configuration

To upload releases to GitLab:

1. **Generate a Personal Access Token**:

   - Go to [GitLab Profile > Personal Access Tokens](https://gitlab.com/-/user_settings/personal_access_tokens?page=1&state=active&sort=expires_asc).
   - Create a token with `api` scope.
   - Copy the token.

2. **Find Your Project ID**:

   - Go to your GitLab project.
   - The Project ID is shown on the project's main page under the project name, or in Settings > General.

3. **Set Up Your Project**:
   ```yaml
   gitlab:
     enabled: true
     token: YOUR_GITLAB_TOKEN
     project_id: "12345678"
     tag: v0.0.1
     ref: main
     host: https://gitlab.com
   ```

> **Note:** For self-hosted GitLab instances, update the `host` field with your GitLab URL.

### Google Play Store Configuration

To upload apps to Google Play Store:

1. **Create a Service Account**:

   - Go to [Google Cloud Console](https://console.cloud.google.com/).
   - Create a new project or select an existing one.
   - Enable the Google Play Android Developer API.
   - Create a Service Account and download the JSON key file.

2. **Grant Access in Play Console**:

   - Go to [Google Play Console](https://play.google.com/console/).
   - Navigate to Setup > API access.
   - Link your service account and grant appropriate permissions.

3. **Set Up Your Project**:
   ```yaml
   play_store:
     enabled: true
     service_account_json_path: ./path/to/service-account.json
     package_name: com.example.app
     track: internal
     release_name: "Release v1.0.0"
   ```

### Apple App Store Configuration

To upload apps to App Store Connect:

1. **Generate an API Key**:

   - Go to [App Store Connect](https://appstoreconnect.apple.com/).
   - Navigate to Users and Access > Keys.
   - Create a new API key with App Manager or Admin role.
   - Download the `.p8` key file and note the Key ID and Issuer ID.

2. **Find Your App ID**:

   - In App Store Connect, go to My Apps.
   - Select your app and find the App ID in the App Information section.

3. **Set Up Your Project**:
   ```yaml
   app_store:
     enabled: true
     api_key_path: ./path/to/AuthKey_XXXXXXXXXX.p8
     api_issuer: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
     app_id: "1234567890"
     bundle_id: com.example.app
   ```

> **Note:** Full IPA upload via App Store Connect API requires proper JWT signing with ES256. For production use, consider using Transporter, Fastlane, or Xcode Organizer for more reliable uploads.

## Slack Configuration Setup Guide

To configure Slack, follow these simple steps:

### 1. **Create a Slack App**

- Go to the [Slack API: Your Apps](https://api.slack.com/apps) page.
- Click on **Create New App**.
- Choose **From Scratch** and give your app a name (e.g., "Build Notifier Bot") and select your workspace.
- Click **Create App**.

### 2. **Add Scopes for the App**

Scopes define the permissions your app will have. To upload QR code and Share Flutter build Download link, you'll need to add the following scopes:

#### **For Uploading Files**

- Go to the **OAuth & Permissions** page in your Slack App's settings.
- Under **Scopes**, find the section called **Bot Token Scopes**.
- Add the following scope:
  - `files:write` — Allows your app to upload files.

#### **For Sending Chat Messages**

- Under the same **Bot Token Scopes** section, add:
  - `chat:write` — Allows your app to send messages to channels.

### 3. **Install the App to Your Workspace**

- Once you've added the required scopes, scroll to the **OAuth & Permissions** page.
- Click the **Install App to Workspace** button.
- You'll be prompted to authorize the app with the selected permissions. Click **Allow** to proceed.

### 4. **Get the Bot User OAuth Token**

After installing the app, you will receive a **Bot User OAuth Token**. This token is required for your Slack configuration to upload files and send messages.

- In the **OAuth & Permissions** page, under **OAuth Tokens & Redirect URLs**, copy the **Bot User OAuth Token** (it should look like `xoxb-XXXXXXXXX-XXXXXXXXX-XXXXXXXXXXXXX`).
- This is your `YOUR_BOT_TOKEN` in the configuration.

### 5. **Find Your Channel ID**

The `CHANNEL_ID` is the unique identifier for the Slack channel where the bot will send messages and share files.

#### **To Find the Channel ID**

- Go to the desired channel in your Slack workspace.
- Click on the **channel name** at the top to open the channel details.
- In the URL of the channel, you will see something like `https://app.slack.com/client/TXXXXXXXX/CXXXXXXXXX`.
- The part after the last `/` (e.g., `CXXXXXXXXX`) is your `CHANNEL_ID`.

### 6. **Get Member/User IDs to Mention**

If you want to mention specific users in the Slack message, you will need their **Slack User IDs**.

#### **To Find a User's ID**

- Open the user's profile by clicking on their name in Slack.
- Click on three dots and Copy Member Id (e.g., `UXXXXXXXX`) is the user's **User ID**.
- Repeat this for each user you want to mention and collect their **User IDs**.

---

Now, you can use the `YOUR_BOT_TOKEN`, `CHANNEL_ID`, and `member_ids` in your configuration to automate Slack file uploads and download link sending.

### Microsoft Teams Configuration Setup Guide

To configure Microsoft Teams notifications, follow these simple steps:

#### 1. **Create an Incoming Webhook**

- Go to your Microsoft Teams channel where you want to receive notifications.
- Click on the **three dots (⋯)** next to the channel name.
- Select **Connectors** from the menu.
- Search for **Incoming Webhook** and click **Configure**.
- Give your webhook a name (e.g., "Build Notifier") and optionally upload an image.
- Click **Create**.
- **Copy the webhook URL** that is generated (you won't be able to see it again).

> **Note:** Checkout [official microsoft teams](https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook?tabs=newteams%2Cdotnet#create-an-incoming-webhook) docs for detailed walkthrough.

#### 2. **Set Up Your Project**

```yaml
teams:
  enabled: true
  webhook_url: YOUR_WEBHOOK_URL
  share_QR: true
  share_link: true
  custom_message: "🚀 Check out the latest build! Download your app now!"
  mention_users: ["John Doe", "Jane Smith"]
```

#### 3. **Get User Names for Mentions** (Optional)

- In Microsoft Teams, you can include user names in the message.
- **Important:** Teams webhooks don't support actual @mentions. User names will be included as plain text in the message.
- Add user display names to the `mention_users` list in your configuration.
- They will appear as "Mentioning: John Doe, Jane Smith" in the message.

> **Note:** Microsoft Teams webhooks use Adaptive Cards for rich message formatting. The QR code will be embedded as a base64 image in the card. For actual @mentions, you would need to use the Microsoft Graph API or Bot Framework, which is beyond the scope of simple webhook integration.

## QR Code Configuration

Flutter Release X can generate QR codes for quick sharing. The QR codes can be customized with various settings.

| Setting                  | Description                                                  |
| ------------------------ | ------------------------------------------------------------ |
| `enabled`                | Enable or disable QR code generation. (true/false)           |
| `save_file`              | Flag to save the QR code image. (true/false)                 |
| `show_in_command`        | Display the QR code in the command line output. (true/false) |
| `size`                   | QR code image size (e.g., 256).                              |
| `error_correction_level` | Error correction level (low, medium, quartile, high).        |
| `save_path`              | File path to save the QR code image.                         |

## Recommended .gitignore Configuration

To prevent exposing sensitive information or to safeguard your project from unintentionally committing sensitive information or unnecessary files, we strongly recommend adding the following entries to your .gitignore file to excluded from version control:

- `gdcredentials.json`: Contains credentials such as API keys and authentication tokens.
- `config.yaml`: Includes custom configuration or environment-specific data, which may contain sensitive information (e.g., database credentials).

If you're using a custom configuration file, replace `config.yaml` with the actual filename (e.g., `custom_config.yaml`).

## License

This project is licensed under the MIT License - see the [MIT LICENSE](LICENSE) file for details.

## Want to Connect?

💡 **Have suggestions or ideas?** I’d love to hear them!
🐞 **Found a bug?** Don’t worry, I’ll squash it in no time!

Feel free to reach out to me:

📧 **Email:** [contact.kingrittik@gmail.com](mailto:contact.kingrittik@gmail.com)  
📖 **Documentation:** [frx docs](https://frx.elpisverse.com)  
💬 **Discord:** [Join Discord Community](https://discord.gg/Tmn6BKwSnr)  
🌐 **GitHub:** [Flutter Release X Repository](https://github.com/RittikSoni/Flutter-Release-X)  
📺 **YouTube:** [Learn Flutter & More with Rittik](https://www.youtube.com/@king_rittik)  
📸 **Instagram:** [@kingrittikofficial](https://www.instagram.com/kingrittikofficial)  
📖 **Medium:** [@kingrittik](https://medium.com/@kingrittik)  
☕️ **Buy me a coffee:** [@kingrittik](https://buymeacoffee.com/kingrittik)

---

## Contributors

### Get Involved

❤️💙 Love using Flutter Release X? We're expanding its capabilities and would love your input! If you have ideas or want to contribute, check out our GitHub repository and star the project to show your support.

```bash
https://github.com/RittikSoni/Flutter-Release-X
```

Let's make Flutter Release X even more awesome together! 🌟

Looking to contribute? Join me on this journey!  
Check out the [Contributing Guidelines](CONTRIBUTING.md) and submit your pull requests.

Together, let’s make Flutter development faster, easier, and more fun! 🎉

## Support the package (optional)

If Flutter Release X has made your development process smoother, please consider supporting our work. Your support is entirely optional but truly appreciated!

- **Give a Thumbs Up:** Click the star/thumbs-up at the top of this page to show your appreciation.
- **Become a Sponsor:** [Sponsor this project on GitHub](https://github.com/sponsors/RittikSoni)
- **Buy Me A Coffee:**  
  <a href="https://www.buymeacoffee.com/kingrittik" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 30px; width: 100px;"></a>

Thank you for helping us keep Flutter Release X thriving!
