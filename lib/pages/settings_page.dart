import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_storage.dart';
import '../services/geolocation_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _geolocationService = GeolocationService();
  Timer? _testTimer;
  bool _isSending = false;

  late TextEditingController _geolocationUrlController;
  late TextEditingController _urlBaseController;
  late TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();
    final settingsStorage = Provider.of<SettingsStorage>(context, listen: false);
    _geolocationUrlController = TextEditingController(
      text: settingsStorage.get('geolocation_url') ?? '',
    );
    _urlBaseController = TextEditingController(
      text: settingsStorage.get('url_base') ?? '',
    );
    _intervalController = TextEditingController(
      text: (settingsStorage.get('geolocation_interval') ?? 60).toString(),
    );

    // Глобальная отправка управляется из MyApp, локальная не нужна
  }

  @override
  void dispose() {
    _geolocationUrlController.dispose();
    _urlBaseController.dispose();
    _intervalController.dispose();
    _testTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsStorage = Provider.of<SettingsStorage>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Настройки',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Темная тема
            SwitchListTile(
              title: const Text('Темная тема'),
              value: settingsStorage.get('theme') == 'dark',
              onChanged: (value) {
                // Здесь можно добавить логику изменения темы через ThemeProvider
                settingsStorage.set('theme', value ? 'dark' : 'light');
              },
            ),

            // Уведомления
            SwitchListTile(
              title: const Text('Уведомления'),
              value: settingsStorage.get('notifications') ?? true,
              onChanged: (value) {
                settingsStorage.set('notifications', value);
              },
            ),

            // Язык
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Язык',
              ),
              initialValue: settingsStorage.get('language') ?? 'Русский',
              items: const [
                DropdownMenuItem(value: 'Русский', child: Text('Русский')),
                DropdownMenuItem(value: 'English', child: Text('English')),
              ],
              onChanged: (value) {
                if (value != null) {
                  settingsStorage.set('language', value);
                }
              },
            ),

            const SizedBox(height: 24),
            const Text(
              'Отправка гео координат',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // URL для отправки координат
            TextFormField(
              controller: _geolocationUrlController,
              decoration: const InputDecoration(
                labelText: 'URL для отправки координат',
              ),
            ),

            // Периодичность отправки
            TextFormField(
              controller: _intervalController,
              decoration: const InputDecoration(
                labelText: 'Периодичность отправки (сек)',
              ),
              keyboardType: TextInputType.number,
            ),

            // Включить отправку координат
            SwitchListTile(
              title: const Text('Включить отправку координат'),
              subtitle: const Text('Работает пока приложение активно'),
              value: settingsStorage.get('geolocation_enabled') ?? false,
              onChanged: (value) {
                settingsStorage.set('geolocation_enabled', value);
                settingsStorage.saveSettings(); // Сохраняем сразу
                // Глобальная отправка управляется слушателем в MyApp
                if (value) {
                  // Показать сообщение о запросе разрешения
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Запрос разрешения на геолокацию...')),
                  );
                }
              },
            ),

            // Текущий статус геолокации
            Selector<SettingsStorage, bool>(
              selector: (_, settings) => settings.get('geolocation_enabled') ?? false,
              builder: (context, isEnabled, child) {
                return isEnabled
                    ? const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Отправка координат активна',
                          style: TextStyle(color: Colors.green),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Отправка координат отключена',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
              },
            ),

            const SizedBox(height: 24),
            const Text(
              'Основная страница',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // UrlBase
            TextFormField(
              controller: _urlBaseController,
              decoration: const InputDecoration(
                labelText: 'UrlBase',
              ),
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 24),
            const Text(
              'Тестирование геолокации',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Кнопка тестирования отправки
            Center(
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendCoordinates,
                child: Text(_isSending ? 'Отправка...' : 'Отправить координаты сейчас'),
              ),
            ),

            const SizedBox(height: 24),

            // Кнопки
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _goBack,
                  child: const Text('Назад'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    final settingsStorage = Provider.of<SettingsStorage>(context, listen: false);

    settingsStorage.updateSettings({
      'geolocation_url': _geolocationUrlController.text,
      'url_base': _urlBaseController.text,
      'geolocation_interval': int.tryParse(_intervalController.text) ?? 60,
    });

    settingsStorage.saveSettings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки сохранены!')),
    );
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  // Эти методы больше не нужны, так как отправка управляется глобально

  void _sendCoordinates() async {
    if (_isSending) return;

    final capturedContext = context;
    final capturedSettingsStorage = Provider.of<SettingsStorage>(
      capturedContext,
      listen: false,
    );

    setState(() {
      _isSending = true;
    });

    try {
      final location = await _geolocationService.getLocation();
      final latitude = location['latitude']!;
      final longitude = location['longitude']!;

      final url = capturedSettingsStorage.get('geolocation_url') as String?;

      if (url != null && url.isNotEmpty) {
        final success = await _geolocationService.sendCoordinates(url, latitude, longitude);
        if (success) {
          // Координаты отправлены: lat=$latitude, lon=$longitude
          if (mounted) {
            setState(() {
              _isSending = false;
            });
            ScaffoldMessenger.of(capturedContext).showSnackBar(
              SnackBar(content: Text('Координаты отправлены: $latitude, $longitude')),
            );
          }
        } else {
          // Ошибка отправки координат
          if (mounted) {
            setState(() {
              _isSending = false;
            });
            ScaffoldMessenger.of(capturedContext).showSnackBar(
              const SnackBar(content: Text('Ошибка отправки координат')),
            );
          }
        }
      }
    } catch (e) {
      // Ошибка отправки: $e
      if (mounted) {
        ScaffoldMessenger.of(capturedContext).showSnackBar(
          SnackBar(content: Text('Ошибка геолокации: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }
}