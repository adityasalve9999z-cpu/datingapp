import 'dart:convert';
import 'package:flutter/foundation.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// JwtService
/// ─────────────────────────────────────────────────────────────────────────────
/// Decodes JWT tokens client-side without any secret (we only verify the
/// structure and expiry — the server still performs full cryptographic
/// verification on every protected request).
///
/// Use this to:
///   • check whether the stored access token has expired before making a call
///   • extract claims (sub / user_id, exp, iat, type) for local display
///   • proactively refresh the token rather than waiting for a 401
/// ─────────────────────────────────────────────────────────────────────────────
class JwtService {
  JwtService._();

  // ── Token Decoding ──────────────────────────────────────────────────────────

  /// Decode a JWT and return its payload as a [Map].
  /// Returns `null` if the token is null, empty, or malformed.
  static Map<String, dynamic>? decode(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // JWT uses base64url encoding — pad to a multiple of 4
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[JwtService] Failed to decode token: $e');
      return null;
    }
  }

  // ── Expiry Helpers ──────────────────────────────────────────────────────────

  /// Returns the expiry [DateTime] embedded in the token, or `null` if missing.
  static DateTime? getExpiry(String? token) {
    final payload = decode(token);
    if (payload == null) return null;

    final exp = payload['exp'];
    if (exp == null) return null;

    // `exp` is seconds since Unix epoch
    return DateTime.fromMillisecondsSinceEpoch((exp as num).toInt() * 1000,
        isUtc: true);
  }

  /// Returns `true` if the token is expired (or missing).
  static bool isExpired(String? token) {
    if (token == null || token.isEmpty) return true;
    final expiry = getExpiry(token);
    if (expiry == null) return true;
    return DateTime.now().toUtc().isAfter(expiry);
  }

  /// Returns `true` if the token will expire within [thresholdSeconds] from now.
  /// Useful for proactive refresh before making API calls.
  static bool expiresWithin(String? token, {int thresholdSeconds = 300}) {
    if (token == null || token.isEmpty) return true;
    final expiry = getExpiry(token);
    if (expiry == null) return true;

    final threshold = Duration(seconds: thresholdSeconds);
    return DateTime.now().toUtc().add(threshold).isAfter(expiry);
  }

  /// Returns how many seconds remain until expiry. Negative if already expired.
  static int secondsUntilExpiry(String? token) {
    final expiry = getExpiry(token);
    if (expiry == null) return -1;
    return expiry.difference(DateTime.now().toUtc()).inSeconds;
  }

  // ── Claim Accessors ─────────────────────────────────────────────────────────

  /// Extract the `sub` (subject / user ID) claim.
  static String? getSubject(String? token) {
    return decode(token)?['sub']?.toString();
  }

  /// Extract the `type` claim ("access" | "refresh" | "password_reset").
  static String? getTokenType(String? token) {
    return decode(token)?['type']?.toString();
  }

  /// Extract the `jti` (JWT ID) claim.
  static String? getJti(String? token) {
    return decode(token)?['jti']?.toString();
  }

  /// Returns `true` if the token is syntactically valid (3 parts, decodable payload).
  static bool isWellFormed(String? token) => decode(token) != null;

  // ── Human-readable Helpers ──────────────────────────────────────────────────

  /// Returns a human-readable summary e.g. "Expires in 45 min" or "Expired".
  static String expiryDescription(String? token) {
    final secs = secondsUntilExpiry(token);
    if (secs < 0) return 'Expired';
    if (secs < 60) return 'Expires in ${secs}s';
    final mins = secs ~/ 60;
    if (mins < 60) return 'Expires in ${mins}m';
    final hours = mins ~/ 60;
    return 'Expires in ${hours}h ${mins % 60}m';
  }
}
