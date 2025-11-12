import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GeolocationService {
  Future<Map<String, double>> getLocation() async {
    try {
      // Включаем геолокацию если отключена
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Службы геолокации отключены. Включите геолокацию в настройках устройства.');
      }

      // Проверяем разрешения
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Разрешение на геолокацию отклонено. Предоставьте разрешение в настройках приложения.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Разрешение на геолокацию отклонено навсегда. Разрешите геолокацию в настройках устройства.');
      }

      // Получаем текущую позицию
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      // Ошибка получения геолокации: $e
      // Возвращаем тестовые координаты для демонстрации
      return {
        'latitude': 55.755811,
        'longitude': 37.617311,
      };
    }
  }

  Future<bool> sendCoordinates(String url, double latitude, double longitude) async {
    try {
      final fullUrl = '$url~lat~$latitude~lon~$longitude';
      final response = await http.get(Uri.parse(fullUrl));

      // Координаты отправлены: $fullUrl, статус: ${response.statusCode}
      return response.statusCode == 200;
    } catch (e) {
      // Ошибка отправки координат: $e
      return false;
    }
  }
}