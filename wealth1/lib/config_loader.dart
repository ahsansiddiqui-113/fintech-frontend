import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Map<String, dynamic>> loadConfig() async {
  try {
    final configString = await rootBundle.loadString('assets/config.json');
    final config = jsonDecode(configString);
    if (config is! Map<String, dynamic>) {
      debugPrint('Invalid config format');

      // throw Exception('Invalid config format');
    }
    return config;
  } catch (e) {
    debugPrint('Error loading config: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>> envConfig() async {
  try {
    final envString = await rootBundle.loadString('assets/env.json');
    final env = jsonDecode(envString);
    if (env is! Map<String, dynamic>) {
      debugPrint('Invalid format');
      // throw Exception('Invalid format');
    }
    return env;
  } catch (e) {
    debugPrint('error loading env: $e');
    rethrow;
  }
}
