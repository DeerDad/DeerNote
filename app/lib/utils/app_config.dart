import 'dart:convert';

import 'package:app/utils/sp_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:yaml/yaml.dart';
import './log.dart';
import '../style/layout.dart';
import '../providers/appearance_provider.dart';
import '../providers/locale_provider.dart';

extension YamlMapConverter on YamlMap {
  dynamic convertNode(dynamic v) {
    if (v is YamlMap) {
      return (v as YamlMap).toMap();
    } else if (v is YamlList) {
      var list = <dynamic>[];
      v.forEach((e) {
        list.add(convertNode(e));
      });
      return list;
    } else {
      return (v as YamlScalar).value;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    this.nodes.forEach((key, value) {
      map[(key as YamlScalar).value.toString()] = convertNode(value);
    });

    return map;
  }
}

extension MapMerge on Map<String, dynamic> {
  MergeOtherMap(Map<String, dynamic> other) {
    other.forEach((key, value) {
      if (this.containsKey(key) == false) {
        this[key] = value;
      } else {
        if (value is Map<String, dynamic> == false ||
            this[key] is Map<String, dynamic> == false) {
          this[key] = value;
        } else {
          (this[key] as Map<String, dynamic>)
              .MergeOtherMap(value as Map<String, dynamic>);
        }
      }
    });
  }
}

class AppConfig {
  static final _instance = AppConfig._internal();
  Map<String, dynamic> configMap = {};
  Map<String, dynamic> localConfigMap = {};

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  Future<void> initConfig() async {
    final defaultConfigString =
        await rootBundle.loadString('assets/configs/default.yaml');
    var default_config = loadYaml(defaultConfigString);
    configMap = (default_config as YamlMap).toMap();

    if (kDebugMode) {
      final debugConfigString =
          await rootBundle.loadString('assets/configs/debug.yaml');
      var debug_config = loadYaml(debugConfigString);
      var debug_configMap = (debug_config as YamlMap).toMap();
      configMap.MergeOtherMap(debug_configMap);
    }

    if (kProfileMode) {
      final profileConfigString =
          await rootBundle.loadString('assets/configs/profile.yaml');
      var profile_config = loadYaml(profileConfigString);
      var profile_configMap = (profile_config as YamlMap).toMap();
      configMap.MergeOtherMap(profile_configMap);
    }

    if (kReleaseMode) {
      final releaseConfigString =
          await rootBundle.loadString('assets/configs/release.yaml');
      var release_config = loadYaml(releaseConfigString);
      var release_configMap = (release_config as YamlMap).toMap();
      configMap.MergeOtherMap(release_configMap);
    }

    // load user config
    String? localConfigStr = SpUtil.getUserLocalConfig();
    Log.trace('local config: ${localConfigStr}');
    if (localConfigStr != null) {
      localConfigMap = jsonDecode(localConfigStr, reviver: configJsonDecode)
          as Map<String, dynamic>;

      GetIt.I.get<AppearanceProvider>().color =
          localConfigMap.containsKey('color')
              ? localConfigMap['color'] as Color
              : AppLayout.defaultColor;

      GetIt.I.get<LocaleProvider>().locale =
          localConfigMap.containsKey('locale')
              ? localConfigMap['locale'] as Locale
              : AppLayout.defaultLocale;
    }
  }

  String serverAddress() {
    return "${localConfigMap['host'] ?? configMap['server']['host']}:${localConfigMap['port'] ?? configMap['server']['port']}";
  }

  String host() {
    return localConfigMap.containsKey('host')
        ? localConfigMap['host'] as String
        : configMap['server']['host'] as String;
  }

  setHost(String host) {
    localConfigMap['host'] = host;
    saveUserLocalConfig();
  }

  int port() {
    return localConfigMap.containsKey('port')
        ? localConfigMap['port'] as int
        : configMap['server']['port'] as int;
  }

  setPort(int port) {
    localConfigMap['port'] = port;
    saveUserLocalConfig();
  }

  clearLocalConfig() {
    localConfigMap = {};
    saveUserLocalConfig();
  }

  saveUserLocalConfig() {
    SpUtil.saveUserLocalConfig(
        jsonEncode(localConfigMap, toEncodable: configJsonEncode));
  }

  Object configJsonEncode(Object? value) {
    if (value is Color) {
      return (value as Color).value;
    }

    if (value is Locale) {
      return (value as Locale).toString();
    }

    throw UnsupportedError('Cannot convert to JSON: $value');
  }

  Object configJsonDecode(Object? key, Object? value) {
    if (key is String && key == 'color') {
      return Color(value as int);
    }

    if (key is String && key == 'locale') {
      return Locale(value as String);
    }

    return value!;
  }

  setColor(Color color) {
    localConfigMap['color'] = color;
    GetIt.I.get<AppearanceProvider>().color = color;
    saveUserLocalConfig();
  }

  Color getColor() {
    return localConfigMap.containsKey('color')
        ? localConfigMap['color'] as Color
        : AppLayout.defaultColor;
  }

  setLocale(Locale locale) {
    localConfigMap['locale'] = locale;
    GetIt.I.get<LocaleProvider>().locale = locale;
    saveUserLocalConfig();
  }

  Locale getLocale() {
    return localConfigMap.containsKey('locale')
        ? localConfigMap['locale'] as Locale
        : AppLayout.defaultLocale;
  }
}
