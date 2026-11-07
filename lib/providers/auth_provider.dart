import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';
import '../services/jwt_service.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AuthProvider
/// ─────────────────────────────────────────────────────────────────────────────
/// Central authentication state manager.
///
/// Authentication strategy (in priority order):
///   1. FastAPI backend JWT  — stored in SharedPreferences
///   2. Supabase session     — fallback / legacy
///   3. Demo mode            — offline / unreachable backend
///
/// The provider also exposes:
///   • changePassword()  — delegates to /auth/change-password
///   • forgotPassword()  — delegates to /auth/forgot-password
///   • resetPassword()   — delegates to /auth/reset-password
///   • tokenStatus       — human-readable token expiry string
///   • isTokenExpired    — whether the stored access token is expired
/// ─────────────────────────────────────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  // ── State ───────────────────────────────────────────────────────────────────
  User? _supabaseUser;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _userName;
  String? _userEmail;
  String? _userId;
  String? _accessToken;

  // ── Getters ─────────────────────────────────────────────────────────────────
  User? get user => _supabaseUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated || _supabaseUser != null;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userId => _userId;
  String? get accessToken => _accessToken;

  /// Human-readable token expiry status ("Expires in 45m", "Expired", …)
  String get tokenStatus => JwtService.expiryDescription(_accessToken);

  /// True when the current access token is definitively expired.
  bool get isTokenExpired => JwtService.isExpired(_accessToken);

  // ── Construction ─────────────────────────────────────────────────────────────
  AuthProvider() {
    _initializeAuth();
  }

  // ── Initialization ────────────────────────────────────────────────────────────

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    // 1. Check stored backend JWT token
    _accessToken = await AppApiService.getStoredToken();
    _userName = await AppApiService.getSavedUserName();
    _userEmail = await AppApiService.getSavedUserEmail();
    _userId = await AppApiService.getSavedCurrentUserId();

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      // Token is present — accept as authenticated even if expired;
      // the auto-refresh interceptor will renew it on the next API call.
      _isAuthenticated = true;
    }

    // 2. Check Supabase session if available
    try {
      final session = Supabase.instance.client.auth.currentSession;
      _supabaseUser = session?.user;
      if (_supabaseUser != null) _isAuthenticated = true;

      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? s = data.session;

        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.tokenRefreshed) {
          _supabaseUser = s?.user;
          _isAuthenticated = true;
        } else if (event == AuthChangeEvent.signedOut) {
          _supabaseUser = null;
        }
        notifyListeners();
      });
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  // ── Login / Signup ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AppApiService.login(email: email, password: password);

    if (result['success'] == true) {
      _isAuthenticated = true;
      _userName = result['name']?.toString() ?? email.split('@').first;
      _userEmail = email;
      _accessToken = await AppApiService.getStoredToken();
      _userId = await AppApiService.getSavedCurrentUserId();
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
      _accessToken = await AppApiService.getStoredToken();
      _userId = await AppApiService.getSavedCurrentUserId();
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // ── Logout ────────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AppApiService.logout();

    _isAuthenticated = false;
    _supabaseUser = null;
    _userName = null;
    _userEmail = null;
    _userId = null;
    _accessToken = null;

    _isLoading = false;
    notifyListeners();
  }

  // ── Password Management ───────────────────────────────────────────────────────

  /// Change the authenticated user's password.
  /// Returns {'success': bool, 'message': String}.
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return AppApiService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Initiate a password reset flow for the given email.
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return AppApiService.forgotPassword(email: email);
  }

  /// Complete the password reset using the token received by email.
  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    return AppApiService.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
    );
  }

  // ── Token Utilities ───────────────────────────────────────────────────────────

  /// Force a token refresh immediately (e.g., called from settings or on app resume).
  Future<bool> refreshToken() async {
    final diagnostics = await AppApiService.getTokenDiagnostics();
    final newToken = await AppApiService.getStoredToken();
    if (newToken != _accessToken) {
      _accessToken = newToken;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Returns a full diagnostic map of both tokens (for developer settings screens).
  Future<Map<String, dynamic>> getTokenDiagnostics() {
    return AppApiService.getTokenDiagnostics();
  }
}
