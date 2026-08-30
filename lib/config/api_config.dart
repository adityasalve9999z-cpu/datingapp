class ApiConfig {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const Duration timeout = Duration(seconds: 10);

  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
