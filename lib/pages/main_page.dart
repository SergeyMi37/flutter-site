import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              // Page started loading: $url
            },
            onPageFinished: (String url) {
              // Page finished loading: $url
            },
            onWebResourceError: (WebResourceError error) {
              // Web resource error: ${error.description}
            },
          ),
        );
    }
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

  void _showInWebView() {
    if (_urlBase.isNotEmpty) {
      _initializeWebView(); // Убедимся, что WebView инициализирован
      _controller!.loadRequest(Uri.parse(_urlBase));
      setState(() {
        _isWebViewVisible = true;
      });
    }
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