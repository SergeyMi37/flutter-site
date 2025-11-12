import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/main_page.dart';
import 'pages/settings_page.dart';
import 'services/settings_storage.dart';
import 'services/geolocation_service.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


// Глобальный менеджер геолокации для основного приложения
class GeolocationManager {
  static final GeolocationManager _instance = GeolocationManager._internal();
  factory GeolocationManager() => _instance;
  GeolocationManager._internal();

  Timer? _sendingTimer;
  final GeolocationService _geolocationService = GeolocationService();

  void startSending(SettingsStorage settingsStorage) {
    // Останавливаем предыдущий таймер если есть
    stopSending();

    final interval = settingsStorage.get('geolocation_interval') ?? 60;
    final url = settingsStorage.get('geolocation_url') as String?;

    if (url != null && url.isNotEmpty) {
      _sendingTimer = Timer.periodic(Duration(seconds: interval), (timer) async {
        if (settingsStorage.get('geolocation_enabled') == true) {
          try {
            final location = await _geolocationService.getLocation();
            final latitude = location['latitude']!;
            final longitude = location['longitude']!;
            await _geolocationService.sendCoordinates(url, latitude, longitude);
          } catch (e) {
            // Обработка ошибки отправки
          }
        } else {
          stopSending();
        }
      });
    }
  }

  void stopSending() {
    _sendingTimer?.cancel();
    _sendingTimer = null;
  }

  bool get isSending => _sendingTimer != null && _sendingTimer!.isActive;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SettingsStorage _settingsStorage;
  final GeolocationManager _geolocationManager = GeolocationManager();

  @override
  void initState() {
    super.initState();
    _settingsStorage = SettingsStorage();
    _settingsStorage.addListener(_onSettingsChanged);
    _initializeGeolocation();
  }

  void _initializeGeolocation() async {
    await _settingsStorage.loadSettings();
    // Геолокация будет запускаться только через UI
  }

  void _onSettingsChanged() {
    final enabled = _settingsStorage.get('geolocation_enabled') == true;

    if (enabled) {
      _geolocationManager.startSending(_settingsStorage);
    } else {
      _geolocationManager.stopSending();
    }
  }

  @override
  void dispose() {
    _settingsStorage.removeListener(_onSettingsChanged);
    _geolocationManager.stopSending();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _settingsStorage,
      child: MaterialApp(
        title: 'Serpan Site',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(
          useMaterial3: true,
        ),
        home: const MainPage(),
        routes: {
          '/settings': (context) => const SettingsPage(),
        },
      ),
    );
  }
}