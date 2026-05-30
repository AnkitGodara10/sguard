// FILE: lib/core/repositories/auth_repository.dart
//
// PURPOSE:
//   Handles all authentication-related data operations.
//   The repository is the bridge between the ViewModel and the API.
//   It takes request models, calls the API, parses responses,
//   and returns Result<T> objects.
//
// WHAT THIS REPOSITORY DOES:
//   - Login (all roles)
//   - Signup (all roles)
//   - Logout (clears stored tokens)
//   - Session restoration (check if user is already logged in)
//
// DATA FLOW:
//   AuthViewModel → AuthRepository → ApiClient → Backend
//   AuthViewModel ← AuthRepository ← ApiClient ← Backend
//
// WHY NOT PUT THIS IN THE VIEWMODEL:
//   ViewModels should not know about HTTP, API paths, or JSON.
//   If we ever change the API or add offline support, we only change
//   the repository — the ViewModel stays untouched.

import '../services/api_client.dart';
import '../services/secure_storage_service.dart';
import '../utils/result.dart';
import '../../models/auth_model.dart';
import '../../models/user_role.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  }) : _apiClient = apiClient,
       _secureStorage = secureStorage;

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<Result<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Persist tokens and user info to secure storage
      await Future.wait([
        _secureStorage.saveAuthToken(loginResponse.accessToken),
        _secureStorage.saveRefreshToken(loginResponse.refreshToken),
        _secureStorage.saveUserId(loginResponse.userId),
        _secureStorage.saveUserRole(loginResponse.role.toApiString()),
        _secureStorage.saveUserEmail(loginResponse.email),
      ]);

      return Result.success(loginResponse);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Signup ────────────────────────────────────────────────────────────────

  Future<Result<SignupResponse>> signupStudent(
    StudentSignupRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/auth/signup',
        data: request.toJson(),
      );
      return Result.success(
        SignupResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<SignupResponse>> signupWarden(
    WardenSignupRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/auth/signup',
        data: request.toJson(),
      );
      return Result.success(
        SignupResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<SignupResponse>> signupAdmin(AdminSignupRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/signup',
        data: request.toJson(),
      );
      return Result.success(
        SignupResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<Result<void>> logout() async {
    try {
      // Notify backend to invalidate the token (fire and forget — even if
      // this fails we still clear local storage)
      try {
        await _apiClient.post('/auth/logout');
      } catch (_) {
        // Intentionally swallowed — local logout always succeeds
      }

      await _secureStorage.clearAll();
      return Result.voidSuccess();
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Session Restoration ───────────────────────────────────────────────────

  /// Returns the role of the currently logged-in user, or null if not logged in
  Future<UserRole?> getStoredRole() async {
    final roleString = await _secureStorage.getUserRole();
    return UserRole.fromString(roleString);
  }

  /// Returns true if a session exists (user is logged in)
  Future<bool> isLoggedIn() async {
    return await _secureStorage.hasValidSession();
  }

  Future<String?> getStoredUserId() async {
    return await _secureStorage.getUserId();
  }
}
