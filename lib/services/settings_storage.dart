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
    "preset_sites": [],
    "username": "",
    "password": "",
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
      "url_base": "https://app.serpan.site/apptoolsrest/a/infochest",
      "preset_sites": [
        {
          "name": "Инструменты (infochest)",
          "url": "https://app.serpan.site/apptoolsrest/a/infochest"
        },
        {
          "name": "Главная страница серпан",
          "url": "https://serpan.site"
        },
        {
          "name": "CSP Portal Home",
          "url": "https://app.serpan.site/csp/sys/%25CSP.Portal.Home.zen"
        },
      ],
      "username": "",
      "password": "",
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

  // Методы для работы с предустановленными сайтами
  
  List<Map<String, String>> getPresetSites() {
    final sites = _settings['preset_sites'] as List?;
    if (sites == null || sites.isEmpty) {
      return _getDefaultPresetSites();
    }
    
    return sites.map((site) => {
      'name': site['name'] as String,
      'url': site['url'] as String,
    }).toList();
  }
  
  List<Map<String, String>> _getDefaultPresetSites() {
    return [
      {
        "name": "Инструменты (infochest)",
        "url": "https://app.serpan.site/apptoolsrest/a/infochest"
      },
      {
        "name": "Главная страница серпан", 
        "url": "https://serpan.site"
      },
      {
        "name": "CSP Portal Home",
        "url": "https://app.serpan.site/csp/sys/%25CSP.Portal.Home.zen"
      },
    ];
  }
  
  void setPresetSites(List<Map<String, String>> sites) {
    _settings['preset_sites'] = sites;
    notifyListeners();
  }
  
  void addPresetSite(String name, String url) {
    final sites = getPresetSites();
    sites.add({'name': name, 'url': url});
    setPresetSites(sites);
  }
  
  void removePresetSite(int index) {
    final sites = getPresetSites();
    if (index >= 0 && index < sites.length) {
      sites.removeAt(index);
      setPresetSites(sites);
    }
  }
}