# Flutter Release X Example

A powerful CLI tool to build and release Flutter apps effortlessly. Generate release builds, upload to the cloud, and share QR codes and download links for quick and easy distribution.

## Installation

You can install Flutter Release X globally using `dart`:

```bash
dart pub global activate flutter_release_x
```

Alternatively, add it as a dependency in your `pubspec.yaml`:

```bash
dart pub add flutter_release_x
```

## 🛠 Usage

Flutter Release X provides easy commands to build, upload, and manage your releases. Here are the main commands:

| Command                         | Description                                                                                      |
| ------------------------------- | ------------------------------------------------------------------------------------------------ |
| `frx build`                     | Builds the release APK, uploads to GitHub, and generates a QR code & link.                       |
| `frx build -s`                  | Displays the current configuration settings. This helps verify if your setup is correct.         |
| `frx build -c <path_to_config>` | Use this flag to specify a custom configuration file path, overriding the default `config.yaml`. |

### Example

- To build the release APK, upload it to Cloud, and generate a QR code & Downloadable link:

  ```bash
  frx build
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

## ⚙️ Configuration

Create a `config.yaml` file in the root directory of your project to specify your upload options and QR code generation settings:

```yaml
# e.g. Windows: C:/dev/flutter/bin/flutter.bat
# macOS: /Users/USER_NAME/development/flutter/bin/flutter
flutter_path: FLUTTER/BINARY/PATH

upload_options:
  github:
    enabled: true
    token: YOUR_GITHUB_TOKEN
    repo: REPO/PATH # e.g. RittikSoni/Flutter-Release-X
    tag: v0.0.1
  google_drive:
    enabled: true
    client_id: YOUR_CLIENT_ID
    client_secret: YOUR_CLIENT_SECRET

# QR Code generation settings
# Default settings:
qr_code:
  enabled: true # Whether or not to generate QR codes
  save_file: true # Flag to save the QR code image to the file system (true/false)
  show_in_command: true # Flag to show the QR code in the command line output (true/false)
  size: 256 # The size of the generated QR code Image 256 x 256
  error_correction_level: low # Error correction level for the QR code (low, medium, quartile, high)
  save_path: "./release-qr-code.png" # Path where the QR code will be saved.
```

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

3. **Run the Tool**
   After setting up the configuration, run:

   ```bash
   frx build
   ```

   This command will build your Flutter project, upload it, and generate a QR code & shareable link.

## 🌐 Cloud Integration

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

   - Go to the Google Cloud Console.
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

## 📱 QR Code Configuration

Flutter Release X can generate QR codes for quick sharing. The QR codes can be customized with various settings.

| Setting                  | Description                                                  |
| ------------------------ | ------------------------------------------------------------ |
| `enabled`                | Enable or disable QR code generation. (true/false)           |
| `save_file`              | Flag to save the QR code image. (true/false)                 |
| `show_in_command`        | Display the QR code in the command line output. (true/false) |
| `size`                   | QR code image size (e.g., 256).                              |
| `error_correction_level` | Error correction level (low, medium, quartile, high).        |
| `save_path`              | File path to save the QR code image.                         |
