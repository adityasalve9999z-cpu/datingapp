import 'package:flutter/foundation.dart';

/// Configuration for backend REST API and WebSocket services.
class ApiConfig {
  // Override at runtime if using a remote staging/production backend
  static String? _customBaseUrl;
  static String? _customWsUrl;

  /// Default API base URL detection based on platform
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    // Android emulator alias for host machine is 10.0.2.2
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    // Windows, macOS, Linux, iOS Simulator
    return 'http://127.0.0.1:8000/api/v1';
  }

  /// Default WebSocket URL
  static String get defaultWsUrl {
    if (kIsWeb) {
      return 'ws://127.0.0.1:8000/api/v1/ws/chat';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ws://10.0.2.2:8000/api/v1/ws/chat';
    }
    return 'ws://127.0.0.1:8000/api/v1/ws/chat';
  }

  /// Returns the active API Base URL
  static String get baseUrl => _customBaseUrl ?? defaultBaseUrl;

  /// Returns the active WebSocket endpoint
  static String get wsUrl => _customWsUrl ?? defaultWsUrl;

  /// Allows setting a custom backend URL at runtime (e.g. from developer settings)
  static void setBaseUrl(String url) {
    _customBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final wsScheme = _customBaseUrl!.startsWith('https') ? 'wss' : 'ws';
    final hostPort = _customBaseUrl!.replaceFirst(RegExp(r'https?:\/\/'), '');
    _customWsUrl = '$wsScheme://$hostPort/ws/chat';
  }

  /// Request timeout in seconds
  static const Duration timeout = Duration(seconds: 15);

  /// Helper to build headers with optional JWT authentication
  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
