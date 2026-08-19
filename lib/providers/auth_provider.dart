import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated || _user != null;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    // 1. Check stored backend JWT token
    final token = await AppApiService.getStoredToken();
    _userName = await AppApiService.getSavedUserName();
    _userEmail = await AppApiService.getSavedUserEmail();

    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
    }

    // 2. Check Supabase session if available
    try {
      final session = Supabase.instance.client.auth.currentSession;
      _user = session?.user;
      if (_user != null) {
        _isAuthenticated = true;
      }

      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? s = data.session;

        if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
          _user = s?.user;
          _isAuthenticated = true;
        } else if (event == AuthChangeEvent.signedOut) {
          _user = null;
        }
        notifyListeners();
      });
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AppApiService.login(email: email, password: password);

    if (result['success'] == true) {
      _isAuthenticated = true;
      _userName = result['name']?.toString() ?? email.split('@').first;
      _userEmail = email;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password, {
    String? gender,
    int? age,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await AppApiService.signup(
      name: name,
      email: email,
      password: password,
      gender: gender,
      age: age,
    );

    if (result['success'] == true) {
      _isAuthenticated = true;
      _userName = name.split(' ').first;
      _userEmail = email;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AppApiService.logout();
    _isAuthenticated = false;
    _user = null;
    _userName = null;
    _userEmail = null;

    _isLoading = false;
    notifyListeners();
  }
}
