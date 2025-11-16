import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../services/settings_storage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  WebViewController? _controller;
  bool _isWebViewVisible = false;
  String _urlBase = '';

  @override
  void initState() {
    super.initState();
    // WebView будет инициализирован только при необходимости
  }

  void _initializeWebView() {
    if (_controller == null) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent("Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36")
        ..enableZoom(true)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              debugPrint('Page started loading: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Page finished loading: $url');
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('Web resource error: ${error.description}');
              debugPrint('Error type: ${error.errorType}');
            },
            onNavigationRequest: (NavigationRequest request) {
              debugPrint('Navigation request: ${request.url}');
              
              // Проверяем, требуется ли аутентификация
              if (_isAuthenticationRequired(request.url)) {
                // Добавляем базовую HTTP аутентификацию
                _addAuthenticationHeader(request.url);
                return NavigationDecision.prevent;
              }
              
              return NavigationDecision.navigate;
            },
          ),
        );
    }
  }

  bool _isAuthenticationRequired(String url) {
    // Проверяем, является ли URL защищенным ресурсом
    return url.contains('/rest/') ||
           url.contains('/apptoolsrest/') ||
           url.contains('app.serpan.site');
  }

  void _addAuthenticationHeader(String url) async {
    // Получаем аутентификационные данные из настроек
    final settingsStorage = Provider.of<SettingsStorage>(context, listen: false);
    final username = settingsStorage.get('username') ?? '';
    final password = settingsStorage.get('password') ?? '';
    
    if (username.isNotEmpty && password.isNotEmpty) {
      // Создаем строку Basic Auth
      final credentials = base64Encode(utf8.encode('$username:$password'));
      final authHeader = 'Basic $credentials';
      
      debugPrint('Adding authentication header for: $url');
      debugPrint('Credentials: $username:***');
      
      // Загружаем URL с заголовком авторизации
      await _controller!.loadRequest(
        Uri.parse(url),
        headers: {
          'Authorization': authHeader,
          'User-Agent': 'SerpanSite/1.0',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );
    } else {
      // Если нет авторизационных данных, показываем диалог
      _showAuthenticationDialog(url);
    }
  }

  void _showAuthenticationDialog(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String username = '';
        String password = '';
        
        return AlertDialog(
          title: const Text('Авторизация'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Введите данные для входа:'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Логин',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  username = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                if (username.isNotEmpty && password.isNotEmpty) {
                  // Сохраняем в настройки
                  final settingsStorage = Provider.of<SettingsStorage>(context, listen: false);
                  settingsStorage.set('username', username);
                  settingsStorage.set('password', password);
                  
                  // Добавляем заголовок авторизации
                  final credentials = base64Encode(utf8.encode('$username:$password'));
                  final authHeader = 'Basic $credentials';
                  
                  await _controller!.loadRequest(
                    Uri.parse(url),
                    headers: {
                      'Authorization': authHeader,
                      'User-Agent': 'SerpanSite/1.0',
                      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                      'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
                    },
                  );
                  
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Войти'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final settingsStorage = Provider.of<SettingsStorage>(context);
    _urlBase = settingsStorage.get('url_base') ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          itemBuilder: (BuildContext context) => [
            //const PopupMenuItem<String>(
            //  value: 'show_window',
            //  child: Text('Показать в окне'),
            //),
            const PopupMenuItem<String>(
              value: 'show_webview',
              child: Text('Показать сайт'),
            ),
            const PopupMenuItem<String>(
              value: 'settings',
              child: Text('Настройки'),
            ),
            //const PopupMenuItem<String>(
            //  value: 'exit',
            //  child: Text('Выход'),
            //),
          ],
        ),
        title: const Text('Серпантин студия'),
      ),
      body: Stack(
        children: [
          // Сплеш изображение
          Image.asset(
            'assets/images/main.png',
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
          // Контейнер для WebView
          if (_isWebViewVisible && _urlBase.isNotEmpty && _controller != null)
            Container(
              color: Colors.white,
              child: WebViewWidget(controller: _controller!),
            ),
          // Сообщение когда WebView не виден
          if (!_isWebViewVisible)
            Center(
              child: Text(
                ' ',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'show_window':
        _showInWindow();
        break;
      case 'show_webview':
        _showInWebView();
        break;
      case 'settings':
        _goToSettings();
        break;
      case 'exit':
        _exitApp();
        break;
    }
  }

  void _showInWindow() {
    if (_urlBase.isNotEmpty) {
      launchUrl(Uri.parse(_urlBase));
    }
  }

  void _showInWebView() async {
    if (_urlBase.isNotEmpty) {
      _initializeWebView(); // Убедимся, что WebView инициализирован
      
      final Uri targetUri = Uri.parse(_urlBase);
      debugPrint('Loading URL: $targetUri');
      
      // Добавим обработку HTTPS/HTTP
      if (targetUri.scheme == 'https' || targetUri.scheme == 'http') {
        // Проверяем нужна ли авторизация
        if (_isAuthenticationRequired(targetUri.toString())) {
          final settingsStorage = Provider.of<SettingsStorage>(context, listen: false);
          final username = settingsStorage.get('username') ?? '';
          final password = settingsStorage.get('password') ?? '';
          
          if (username.isNotEmpty && password.isNotEmpty) {
            // Есть данные авторизации, загружаем с заголовком
            final credentials = base64Encode(utf8.encode('$username:$password'));
            final authHeader = 'Basic $credentials';
            
            await _controller!.loadRequest(
              targetUri,
              headers: {
                'Authorization': authHeader,
                'User-Agent': 'SerpanSite/1.0',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
              },
            );
          } else {
            // Нет данных авторизации, показываем диалог
            _showAuthenticationDialog(targetUri.toString());
          }
        } else {
          // Простая загрузка без авторизации
          _controller!.loadRequest(targetUri);
        }
        
        setState(() {
          _isWebViewVisible = true;
        });
      } else {
        // Показываем ошибку для неподдерживаемых схем
        _showErrorDialog('Неподдерживаемый протокол',
            'URL должен использовать HTTP или HTTPS протокол');
      }
    } else {
      _showErrorDialog('Ошибка загрузки',
          'Базовый URL не настроен в настройках приложения');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
  }

  void _goToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _exitApp() {
    // В Flutter для мобильных приложений выход обычно не требуется
    // Просто закрываем текущий экран
    Navigator.of(context).pop();
  }
}