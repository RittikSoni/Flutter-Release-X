import 'dart:io';

class FlutterReleaseXKstrings {
  static const String releaseApkPath =
      './build/app/outputs/flutter-apk/app-release.apk';

  // ✅ Android App Bundle (.aab) release path
  static const String releaseAabPath =
      './build/app/outputs/bundle/release/app-release.aab';

  // ✅ iOS release path (.ipa file for distribution)
  static const String iosReleasePath = './build/ios/ipa/Runner.ipa';

  // ✅ Web release path (compressed .zip for hosting)
  static const String webReleasePath = './build/web/';

  // ✅ macOS release path (.app or .dmg file)
  static const String macosReleasePath =
      './build/macos/Build/Products/Release/Runner.app';

  // ✅ Windows release path (.exe or .msix package)
  static const String windowsReleasePath =
      './build/windows/runner/Release/Runner.exe';

  // ✅ Linux release path (binary executable file)
  static const String linuxReleasePath =
      './build/linux/x64/release/bundle/runner';

  static const String packageName = 'Flutter Release X';
  static const String googleDriveCredentialsSavePath = 'gdcredentials.json';
  static const String qrCodeSavePath = './release-qr-code.png';
  static const String gitRepoLink =
      'https://github.com/RittikSoni/Flutter-Release-X';
  static const String packageLink =
      'https://pub.dev/packages/flutter_release_x';

  /// Replace this with the real project config path
  static const String demoConfigPath = 'config.yaml';

  static const String documentaion = 'https://frx.elpisverse.com';

  static final String defaultFlutterBinPath =
      Platform.isWindows ? 'flutter.bat' : 'flutter';

  static const String commingSoonTip =
      'Tip: You can achieve this using Advance pipeline feature (https://frx.elpisverse.com/docs/configuration#2-advanced-pipeline-full-customization-).';

  static const String version = '0.3.2';
}
