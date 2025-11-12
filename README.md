# Flutter App - Конвертация из Flet

Это Flutter приложение, конвертированное из проекта на Flet.

## Функциональность

- Главная страница с WebView
- Настройки приложения с сохранением в SharedPreferences
- Геолокация с периодической отправкой координат
- Темная и светлая тема
- Навигация между страницами

## Запуск

### Требования

- Flutter SDK (версии 3.0.0 или выше)
- Android Studio или Visual Studio Code с плагинами Flutter
- Android SDK (для сборки под Android)
- Для WSL2: Windows Subsystem for Linux 2 с установленным Ubuntu

### Установка Flutter SDK

#### Для Windows:

1. Скачайте Flutter SDK с официального сайта: https://flutter.dev/docs/get-started/install/windows
2. Распакуйте архив в желаемую директорию (например, `C:\flutter`)
3. Добавьте путь к `flutter\bin` в переменную среды `PATH`
4. Добавьте путь к `flutter\bin\cache\dart-sdk\bin` в `PATH`
5. Откройте командную строку и выполните:
   ```cmd
   flutter doctor
   ```
6. Установите недостающие компоненты согласно выводимой информации

#### Для WSL2:

1. Откройте PowerShell от имени администратора и выполните:
   ```powershell
   wsl --install
   ```
2. Перезагрузите систему и настройте Ubuntu
3. В WSL2 терминале выполните:
   ```bash
   sudo apt update
   sudo apt install curl git unzip xz-utils zip libglu1-mesa
   ```
4. Скачайте и распакуйте Flutter:
   ```bash
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   ```
5. Добавьте в `~/.bashrc`:
   ```bash
   export PATH="$PATH:$HOME/flutter/bin"
   ```
6. Выполните:
   ```bash
   flutter doctor
   ```
7. Установите Android SDK через Android Studio в Windows или настройте его в WSL2

### Запуск приложения

1. Перейдите в директорию проекта:
   ```bash
   cd flutter_app
   ```

2. Установите зависимости:
   ```bash
   flutter pub get
   ```

3. Подключите устройство Android или запустите эмулятор

4. Запустите приложение:
   ```bash
   flutter run
   ```

### Запуск в VS Code

1. Откройте папку `flutter_app` в VS Code
2. Установите расширения Flutter и Dart
3. Нажмите F5 или используйте команду "Flutter: Launch Emulator" из палитры команд (Ctrl+Shift+P)
4. Выберите устройство и запустите приложение

## Сборка APK

```bash
flutter build apk --release
```

APK файл будет создан в `build/app/outputs/flutter-apk/app-release.apk`

## Структура проекта

```
flutter_app/
├── lib/
│   ├── main.dart                 # Точка входа приложения
│   ├── pages/
│   │   ├── main_page.dart        # Главная страница
│   │   └── settings_page.dart    # Страница настроек
│   └── services/
│       ├── geolocation_service.dart  # Сервис геолокации
│       └── settings_storage.dart     # Сервис хранения настроек
├── assets/
│   └── images/                   # Изображения приложения
├── android/                      # Конфигурация Android
└── pubspec.yaml                  # Зависимости Flutter
```

## Руководство по работе с Android инструментами для Flutter
1. Установка Platform-Tools и Cmdline-Tools на Windows
Скачивание и установка
    1. Скачайте Android Command Line Tools с официального сайта
    2. Распакуйте архив в папку, например: C:\Android\cmdline-tools
    3. Создайте структуру папок: cmdline-tools\latest\
    4. Переместите все файлы из распакованной папки в latest\
Настройка переменных окружения

# Добавьте в системную переменную PATH
C:\Android\cmdline-tools\latest\bin
C:\Android\platform-tools

# Создайте переменную ANDROID_HOME
ANDROID_HOME = C:\Android
Установка необходимых компонентов
```bash
# Принять лицензии
sdkmanager --licenses

# Установить platform-tools
sdkmanager "platform-tools"

# Установить эмулятор
sdkmanager "emulator"

# Установить системные образы
sdkmanager "system-images;android-33;google_apis;x86_64"
sdkmanager "system-images;android-33;google_apis_playstore;x86_64"

# Установить build-tools
sdkmanager "build-tools;33.0.0"

# Установить платформы
sdkmanager "platforms;android-33"
```
2. Создание эмуляторов для Android

Просмотр доступных образов
```bash
avdmanager list avd
sdkmanager --list

# Создание эмулятора через командную строку

# Создать эмулятор с Google APIs
avdmanager create avd -n "Pixel_5_API_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel_5"

# Создать эмулятор с Play Store
avdmanager create avd -n "Pixel_6_API_33" -k "system-images;android-33;google_apis_playstore;x86_64" -d "pixel_6"
```
# Параметры:
# -n : имя эмулятора
# -k : системный образ
# -d : устройство (device)
Дополнительные параметры создания
```bash
# С указанием размера памяти
avdmanager create avd -n "MyDevice" -k "system-images;android-33;google_apis;x86_64" --device "pixel_5" -c 512M --force
```
3. Запуск эмуляторов из Flutter
Просмотр доступных эмуляторов
```bash
# Через Flutter
flutter emulators

# Через Android SDK
emulator -list-avds
```
Запуск эмулятора
```bash
# Через Flutter (рекомендуется)
flutter emulators --launch Pixel_5_API_33

# Через Android SDK
emulator -avd Pixel_5_API_33 -netdelay none -netspeed full

# С дополнительными параметрами
emulator -avd Pixel_5_API_33 -no-audio -no-snapshot -gpu host
```
Запуск с конкретным устройством
```bash
flutter run -d emulator-5554
```
4. Создание APK для Flutter
Сборка debug APK
```bash
flutter build apk --debug

# Или с конкретной flavor
flutter build apk --debug --flavor dev
```
Сборка release APK
```bash
flutter build apk --release

# С уменьшением размера
flutter build apk --release --split-per-abi

# С конкретной flavor
flutter build apk --release --flavor production
```
Сборка app bundle
```bash
flutter build appbundle --release
Проверка зависимостей перед сборкой
```bash
flutter pub get
flutter clean
flutter pub get
```
5. Инсталляция APK на эмуляторе и поиск ошибок
Установка APK на эмулятор
```bash
# Установка debug APK
adb install build\app\outputs\flutter-apk\app-debug.apk

# Установка release APK
adb install build\app\outputs\flutter-apk\app-release.apk

# Принудительная переустановка
adb install -r build\app\outputs\flutter-apk\app-debug.apk

# Установка с конкретным устройством (если несколько)
adb -s emulator-5554 install build\app\outputs\flutter-apk\app-debug.apk
```
Просмотр установленных приложений
```bash
adb shell pm list packages
adb shell pm list packages | grep your_app_name
```
Поиск ошибок через логи
Просмотр всех логов
```bash
adb logcat
```
Фильтрация логов по тегу
```bash
# Логи Flutter
adb logcat | grep -i flutter

# Логи конкретного приложения
adb logcat | grep -i "your_app_package"

# Логи ошибок
adb logcat *:E

# Логи с временной меткой
adb logcat -v time
```

Сохранение логов в файл
```bash
adb logcat -d > logcat_output.txt
adb logcat -d -v time > logcat_with_time.txt
```
Очистка логов
```bash
adb logcat -c
```
Дополнительные команды для отладки
Проверка подключенных устройств
```bash
adb devices
flutter devices
```

Перезапуск adb сервера
```bash
adb kill-server
adb start-server
```

Просмотр информации о пакете
```bash
adb shell dumpsys package your.package.name
```
6. Останов эмулятора
Graceful shutdown
```bash
# Через adb
adb -s emulator-5554 emu kill

# Через команду выключения
adb shell reboot -p
```
Принудительное завершение
```bash
# Поиск процесса эмулятора
tasklist | findstr "emulator"

# Завершение процесса (Windows)
taskkill /F /IM emulator.exe

# Через диспетчер задач
# Ctrl + Shift + Esc → Найти "emulator" → Завершить задачу
```
Автоматический скрипт остановки
```bat
@echo off
echo Stopping Android emulators...
adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
taskkill /F /IM emulator.exe 2>nul
echo All emulators stopped.
```
Полезные советы
Ускорение работы эмулятора
    • Включите Hardware Acceleration в BIOS (Intel VT-x или AMD-V)
    • Используйте x86_64 образы вместо arm
    • Выделите достаточно RAM (не менее 2GB)
    • Используйте Quick Boot (snapshots)
Решение
```bash
# Если эмулятор не запускается
emulator -avd Your_AVD -no-snapshot

# Если adb не видит устройство
adb kill-server
adb start-server
adb devices

# Если проблемы с лицензиями
sdkmanager --licenses
```
Оптимизация сборки
```bash
# Очистка кэша перед сборкой
flutter clean

# Анализ размера приложения
flutter build apk --analyze-size

# Проверка здоровья Flutter
flutter doctor -v
```