// FILE: lib/core/services/secure_storage_service.dart
//
// PURPOSE:
//   Provides an abstraction over flutter_secure_storage for storing
//   sensitive data like auth tokens, user IDs, and roles.
//
// WHY A WRAPPER:
//   Wrapping flutter_secure_storage in a service class means:
//     1. If we ever change the storage library, we change it here only
//     2. Easy to mock in tests
//     3. Centralizes all key names (from AppConstants)
//     4. Other parts of the app never import flutter_secure_storage directly
//
// WHAT IS STORED HERE:
//   - Auth token (JWT)
//   - Refresh token
//   - User ID
//   - User role (student/warden/admin)
//   - User email
//
// WHAT IS NOT STORED HERE:
//   - Profile data (use SharedPreferences or fetch from API)
//   - App settings (use SharedPreferences)
//   - Any non-sensitive data

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  // FlutterSecureStorage instance is injected so it can be mocked in tests
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  // ── Auth Token ────────────────────────────────────────────────────────────

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: AppConstants.keyAuthToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: AppConstants.keyAuthToken);
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
  }

  // ── Refresh Token ─────────────────────────────────────────────────────────

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.keyRefreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.keyRefreshToken);
  }

  // ── User Data ─────────────────────────────────────────────────────────────

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConstants.keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.keyUserId);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: AppConstants.keyUserRole, value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: AppConstants.keyUserRole);
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: AppConstants.keyUserEmail, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: AppConstants.keyUserEmail);
  }

  // ── Session Check ─────────────────────────────────────────────────────────

  /// Returns true if a valid session exists (token stored)
  Future<bool> hasValidSession() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ── Clear All ─────────────────────────────────────────────────────────────

  /// Clears ALL secure storage — called on logout
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
