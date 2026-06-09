import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sguard/core/services/secure_storage_service.dart';
import 'package:sguard/viewmodels/auth/auth_viewmodel.dart';

/// Checks JWT token expiry on app start and auto-logs out when expired.
///
/// Usage in main.dart (after DI init):
/// ```dart
/// final sessionManager = getIt<SessionManager>();
/// await sessionManager.checkOnStartup(getIt<AuthViewModel>());
/// ```
class SessionManager {
  final SecureStorageService _storage;

  SessionManager({required SecureStorageService storage}) : _storage = storage;

  /// Reads the stored auth token, decodes the `exp` claim, and calls
  /// [authVM.logout()] automatically when the token has expired.
  ///
  /// Silently swallows any parse errors — a corrupt token is treated as
  /// non-expired so the server can reject it authoritatively on the next call.
  Future<void> checkOnStartup(AuthViewModel authVM) async {
    try {
      final token = await _storage.getAuthToken();
      if (token == null || token.isEmpty) return;

      final exp = _extractExp(token);
      if (exp == null) return;

      final expiry = DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
        isUtc: true,
      );
      if (DateTime.now().toUtc().isAfter(expiry)) {
        debugPrint('[SessionManager] Token expired at $expiry — logging out.');
        await authVM.logout();
      }
    } catch (e) {
      debugPrint('[SessionManager] checkOnStartup error: $e');
    }
  }

  /// Decodes the JWT payload (middle segment) and returns the `exp` field,
  /// or null if unavailable / unparseable.
  int? _extractExp(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final padded = _padBase64(parts[1]);
      final decoded = utf8.decode(base64Url.decode(padded));
      final Map<String, dynamic> claims =
          json.decode(decoded) as Map<String, dynamic>;

      final exp = claims['exp'];
      if (exp == null) return null;
      return exp is int ? exp : int.tryParse(exp.toString());
    } catch (_) {
      return null;
    }
  }

  static String _padBase64(String s) {
    final mod = s.length % 4;
    if (mod == 0) return s;
    return s + '=' * (4 - mod);
  }
}
