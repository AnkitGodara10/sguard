// FILE: lib/core/repositories/mock_auth_repository.dart
//
// PURPOSE:
//   A mock implementation of AuthRepository that returns fake data
//   instead of calling the API. Used during development when no backend
//   is available.
//
// HOW TO SWITCH:
//   In lib/di/injection.dart, change:
//
//     // Real backend:
//     getIt.registerLazySingleton<AuthRepository>(
//       () => AuthRepository(apiClient: ..., secureStorage: ...),
//     );
//
//     // Mock (no backend):
//     getIt.registerLazySingleton<AuthRepository>(
//       () => MockAuthRepository(secureStorage: getIt<SecureStorageService>()),
//     );
//
// CREDENTIALS FOR TESTING:
//   Student login:  any email + password "student123" → role student
//   Warden login:   any email + password "warden123"  → role warden
//   Admin login:    any email + password "admin123"   → role admin
//   Any other password → returns error
//
// This lets you test the entire app without a running server.

import '../services/mock_data_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/result.dart';
import '../../models/auth_model.dart';
import '../../models/user_role.dart';

class MockAuthRepository {
  final SecureStorageService _secureStorage;

  MockAuthRepository({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage;

  Future<Result<LoginResponse>> login(LoginRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    LoginResponse response;

    switch (request.password) {
      case 'student123':
        response = MockDataService.mockStudentLogin(request.email);
        break;
      case 'warden123':
        response = MockDataService.mockWardenLogin(request.email);
        break;
      case 'admin123':
        response = MockDataService.mockAdminLogin(request.email);
        break;
      default:
        return Result.failure('Invalid email or password');
    }

    // Persist mock tokens
    await Future.wait([
      _secureStorage.saveAuthToken(response.accessToken),
      _secureStorage.saveRefreshToken(response.refreshToken),
      _secureStorage.saveUserId(response.userId),
      _secureStorage.saveUserRole(response.role.toApiString()),
      _secureStorage.saveUserEmail(response.email),
    ]);

    return Result.success(response);
  }

  Future<Result<SignupResponse>> signupStudent(
    StudentSignupRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Result.success(
      const SignupResponse(
        userId: 'student_new_001',
        message: 'Account created successfully',
      ),
    );
  }

  Future<Result<SignupResponse>> signupWarden(
    WardenSignupRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Result.success(
      const SignupResponse(
        userId: 'warden_new_001',
        message: 'Account created successfully',
      ),
    );
  }

  Future<Result<SignupResponse>> signupAdmin(AdminSignupRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Result.success(
      const SignupResponse(
        userId: 'admin_new_001',
        message: 'Account created successfully',
      ),
    );
  }

  Future<Result<void>> logout() async {
    await _secureStorage.clearAll();
    return Result.voidSuccess();
  }

  Future<UserRole?> getStoredRole() async {
    final roleString = await _secureStorage.getUserRole();
    return UserRole.fromString(roleString);
  }

  Future<bool> isLoggedIn() async {
    return await _secureStorage.hasValidSession();
  }

  Future<String?> getStoredUserId() async {
    return await _secureStorage.getUserId();
  }
}
