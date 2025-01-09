import 'dart:io';

import 'package:flutter_release_x/constants/kstrings.dart';
import 'package:yaml/yaml.dart';

class Config {
  static Map<String, dynamic>? _config;

  static void loadConfig() {
    final configFile = File(Kstrings.demoConfigPath);
    if (configFile.existsSync()) {
      final yamlString = configFile.readAsStringSync();
      final yamlMap = loadYaml(yamlString);
      _config = Map<String, dynamic>.from(yamlMap);
    } else {
      print('⚠️ Config file not found.');
    }
  }

  static Map<String, dynamic>? get config => _config;
}
