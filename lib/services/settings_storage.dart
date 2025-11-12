import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage with ChangeNotifier {
  static const String _settingsKey = 'app_settings';

  Map<String, dynamic> _settings = {
    "theme": "light",
    "notifications": true,
    "language": "Русский",
    "geolocation_url": "",
    "geolocation_interval": 60,
    "geolocation_enabled": false,
    "url_base": "",
  };

  Map<String, dynamic> get settings => _settings;

  SettingsStorage() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        _settings = Map<String, dynamic>.from(json.decode(settingsJson));
      } else {
        _settings = getDefaultSettings();
      }
      notifyListeners();
    } catch (e) {
      // Ошибка загрузки настроек: $e
      _settings = getDefaultSettings();
      notifyListeners();
    }
  }

  Future<bool> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(_settings);
      await prefs.setString(_settingsKey, settingsJson);

      // Также сохраняем отдельные ключи для фонового сервиса
      await prefs.setBool('geolocation_enabled', _settings['geolocation_enabled'] ?? false);
      await prefs.setString('geolocation_url', _settings['geolocation_url'] ?? '');
      await prefs.setInt('geolocation_interval', _settings['geolocation_interval'] ?? 60);

      notifyListeners();
      return true;
    } catch (e) {
      // Ошибка сохранения настроек: $e
      return false;
    }
  }

  Map<String, dynamic> getDefaultSettings() {
    return {
      "theme": "light",
      "notifications": true,
      "language": "Русский",
      "geolocation_url": "https://api.telegram.org/bot",
      "geolocation_interval": 60,
      "geolocation_enabled": false,
      "url_base": "https://serpan.site/",
    };
  }

  dynamic get(String key) {
    return _settings[key];
  }

  void set(String key, dynamic value) {
    _settings[key] = value;
    notifyListeners();
  }

  void updateSettings(Map<String, dynamic> newSettings) {
    _settings.addAll(newSettings);
    notifyListeners();
  }
}