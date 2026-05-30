// FILE: lib/core/services/api_client.dart
//
// PURPOSE:
//   Centralizes all HTTP communication with the SGuard backend API.
//   Built on top of the Dio package, it handles:
//     1. Base URL configuration
//     2. Request/response interceptors (auth headers, logging)
//     3. Token refresh logic (when 401 is received)
//     4. Consistent error handling and transformation
//     5. Request timeout management
//
// DATA FLOW:
//   Repository → ApiClient → Dio → Backend API
//   Repository ← ApiClient ← Dio ← Backend API
//
// WHAT GOES HERE:
//   - HTTP client setup
//   - Auth interceptor (adds Bearer token to requests)
//   - Token refresh interceptor
//   - Error parsing (network errors, server errors, auth errors)
//
// WHAT DOES NOT GO HERE:
//   - Business logic
//   - Data parsing (that happens in repositories/models)
//   - UI state management
//
// BACKEND INTEGRATION:
//   When the backend is ready, update AppConstants.apiBaseUrl.
//   All repositories already route through this client, so no other
//   changes are needed for basic connectivity.

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'secure_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  ApiClient({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.apiConnectTimeout,
        receiveTimeout: AppConstants.apiReceiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _addInterceptors();
  }

  void _addInterceptors() {
    // ── Auth Interceptor ─────────────────────────────────────────────────
    // Automatically attaches the Bearer token to every request.
    // Also handles 401 responses by attempting token refresh.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If we get a 401, attempt token refresh
          if (error.response?.statusCode == 401) {
            final refreshed = await _attemptTokenRefresh();
            if (refreshed) {
              // Retry the original request with the new token
              final token = await _secureStorage.getAuthToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    // ── Logging Interceptor (development only) ────────────────────────────
    // In production, remove this or replace with proper logging service
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  // ── Token Refresh ─────────────────────────────────────────────────────────
  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        AppConstants.endpointRefreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': null},
        ), // No auth for refresh
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'] as String?;
        final newRefresh = response.data['refresh_token'] as String?;

        if (newToken != null) {
          await _secureStorage.saveAuthToken(newToken);
        }
        if (newRefresh != null) {
          await _secureStorage.saveRefreshToken(newRefresh);
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── HTTP Methods ──────────────────────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(String path, {dynamic data, Options? options}) async {
    return await _dio.put(path, data: data, options: options);
  }

  Future<Response> patch(String path, {dynamic data, Options? options}) async {
    return await _dio.patch(path, data: data, options: options);
  }

  Future<Response> delete(String path, {dynamic data, Options? options}) async {
    return await _dio.delete(path, data: data, options: options);
  }

  // ── Error Handling ────────────────────────────────────────────────────────

  /// Converts a DioException into a human-readable error message.
  /// Used in repositories to translate HTTP errors to Result.failure messages.
  static String parseError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return AppConstants.endpointRefreshToken; // use string constant
        case DioExceptionType.connectionError:
          return 'Network error. Please check your connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] as String?;

          if (statusCode == 400) return message ?? 'Invalid request.';
          if (statusCode == 401) return 'Session expired. Please log in again.';
          if (statusCode == 403) return 'You are not authorized.';
          if (statusCode == 404) return 'Resource not found.';
          if (statusCode == 409) return message ?? 'Conflict error.';
          if (statusCode != null && statusCode >= 500) {
            return 'Server error. Please try again later.';
          }
          return message ?? 'Something went wrong.';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
