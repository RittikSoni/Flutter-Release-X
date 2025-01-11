import 'dart:io';
import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:flutter_release_x/models/app_config_model.dart';
import 'package:yaml/yaml.dart';

// Model classes for each configuration section
class Config {
  static final Config _instance = Config._internal();

  late String _configPath;
  late AppConfigModel _appConfig;

  // Singleton constructor
  Config._internal();

  // Factory constructor to provide a global access point to the configuration
  factory Config() {
    return _instance;
  }

  // Load configuration with optional path
  void loadConfig([String? path]) {
    try {
      if (path != null && path != Kstrings.demoConfigPath) {
        persistConfigPath(path);
      }

      if (path == Kstrings.demoConfigPath) {
        _configPath = _getPersistedConfigPath() ?? 'config.yaml';
      } else {
        _configPath = path ?? _getPersistedConfigPath() ?? 'config.yaml';
      }

      final configFile = File(_configPath);

      if (configFile.existsSync()) {
        final yamlString = configFile.readAsStringSync();
        final yamlData = loadYaml(yamlString);
        _appConfig = AppConfigModel.fromYaml(yamlData);
      } else {
        print('⚠️ Config file not found.');
        return;
      }
    } catch (e) {
      print('⚠️ Config file not found. $e');
      return;
    }
  }

  // Persist the config path for future commands
  void persistConfigPath(String path) {
    _configPath = path;
    File('.config_path').writeAsStringSync(path);
  }

  // Get the persisted config path
  String? _getPersistedConfigPath() {
    final file = File('.config_path');
    return file.existsSync() ? file.readAsStringSync().trim() : null;
  }

  // Accessors for config data (now returning model objects)
  String get configPath => _configPath;
  AppConfigModel get config => _appConfig;
}
