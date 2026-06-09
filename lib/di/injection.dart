// FILE: lib/di/injection.dart
//
// PURPOSE:
//   Single-file DI configuration for SGuard.
//   Supports mock mode (no backend) and production mode (real API).
//
// ══════════════════════════════════════════════════════════
//   🔧 SET THIS FLAG TO SWITCH BETWEEN MOCK AND REAL DATA
const bool _useMockData = true;
//   true  → Mock repos, no network needed, use passwords:
//           student123 / warden123 / admin123
//   false → Real API at AppConstants.apiBaseUrl
// ══════════════════════════════════════════════════════════

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../core/services/api_client.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/secure_storage_service.dart';
import '../core/repositories/auth_repository.dart';
import '../core/repositories/mock_auth_repository.dart';
import '../core/repositories/student_repository.dart';
import '../core/repositories/mock_student_repository.dart';
import '../core/repositories/warden_repository.dart';
import '../core/repositories/mock_warden_repository.dart';
import '../core/repositories/admin_repository.dart';
import '../core/repositories/mock_admin_repository.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import '../viewmodels/student/student_dashboard_viewmodel.dart';
import '../viewmodels/student/generate_sl_qr_viewmodel.dart';
import '../viewmodels/student/request_leave_viewmodel.dart';
import '../viewmodels/student/student_history_viewmodel.dart';
import '../viewmodels/student/student_profile_viewmodel.dart';
import '../viewmodels/warden/warden_dashboard_viewmodel.dart';
import '../viewmodels/warden/leave_requests_viewmodel.dart';
import '../viewmodels/warden/student_management_viewmodel.dart';
import '../viewmodels/warden/warden_own_leave_viewmodel.dart';
import '../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../viewmodels/admin/admin_student_list_viewmodel.dart';
import '../viewmodels/admin/admin_warden_list_viewmodel.dart';
import '../viewmodels/admin/scanner_management_viewmodel.dart';
import '../viewmodels/admin/admin_reports_viewmodel.dart';
import '../models/auth_model.dart';
import '../models/user_role.dart';

final GetIt getIt = GetIt.instance;

Future<void> initializeDependencies() async {

  // ── 1. Core Services (always registered) ─────────────────────────────────

  getIt.registerSingleton<SecureStorageService>(
    SecureStorageService(
      storage: const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ),
    ),
  );

  final notificationService = NotificationService();
  await notificationService.initialize();
  getIt.registerSingleton<NotificationService>(notificationService);

  final connectivityService = ConnectivityService();
  await connectivityService.initialize();
  getIt.registerSingleton<ConnectivityService>(connectivityService);

  // ── 2. Conditional Repository + ViewModel Setup ───────────────────────────

  if (_useMockData) {
    _registerMock();
  } else {
    _registerReal();
  }
}

// ── MOCK SETUP ────────────────────────────────────────────────────────────────

void _registerMock() {
  final mockStudentRepo = MockStudentRepository();
  final mockWardenRepo  = MockWardenRepository();
  final mockAdminRepo   = MockAdminRepository();
  final secStorage      = getIt<SecureStorageService>();
  final mockAuthRepo    = MockAuthRepository(secureStorage: secStorage);

  // Singletons so state (mock QRs, leaves) persists within a session
  getIt.registerSingleton<MockStudentRepository>(mockStudentRepo);
  getIt.registerSingleton<MockWardenRepository>(mockWardenRepo);
  getIt.registerSingleton<MockAdminRepository>(mockAdminRepo);

  // Auth ViewModel — uses a subclass that routes calls to MockAuthRepository
  getIt.registerSingleton<AuthViewModel>(
    MockAuthViewModel(mockAuthRepo: mockAuthRepo),
  );

  // ── Student ViewModels ───────────────────────────────────────────────────
  getIt.registerFactory<StudentDashboardViewModel>(
    () => StudentDashboardViewModel(
      studentRepository: StudentRepository.fromMock(
        getIt<MockStudentRepository>(),
      ),
    ),
  );
  getIt.registerFactory<GenerateSlQrViewModel>(
    () => GenerateSlQrViewModel(
      studentRepository: StudentRepository.fromMock(
        getIt<MockStudentRepository>(),
      ),
    ),
  );
  getIt.registerFactory<RequestLeaveViewModel>(
    () => RequestLeaveViewModel(
      studentRepository: StudentRepository.fromMock(
        getIt<MockStudentRepository>(),
      ),
    ),
  );
  getIt.registerFactory<StudentHistoryViewModel>(
    () => StudentHistoryViewModel(
      studentRepository: StudentRepository.fromMock(
        getIt<MockStudentRepository>(),
      ),
    ),
  );
  getIt.registerFactory<StudentProfileViewModel>(
    () => StudentProfileViewModel(
      studentRepository: StudentRepository.fromMock(
        getIt<MockStudentRepository>(),
      ),
    ),
  );

  // ── Warden ViewModels ────────────────────────────────────────────────────
  getIt.registerFactory<WardenDashboardViewModel>(
    () => WardenDashboardViewModel(
      wardenRepository: WardenRepository.fromMock(
        getIt<MockWardenRepository>(),
      ),
    ),
  );
  getIt.registerFactory<LeaveRequestsViewModel>(
    () => LeaveRequestsViewModel(
      wardenRepository: WardenRepository.fromMock(
        getIt<MockWardenRepository>(),
      ),
      notificationService: getIt<NotificationService>(),
    ),
  );
  getIt.registerFactory<StudentManagementViewModel>(
    () => StudentManagementViewModel(
      wardenRepository: WardenRepository.fromMock(
        getIt<MockWardenRepository>(),
      ),
    ),
  );
  getIt.registerFactory<WardenOwnLeaveViewModel>(
    () => WardenOwnLeaveViewModel(
      wardenRepository: WardenRepository.fromMock(
        getIt<MockWardenRepository>(),
      ),
    ),
  );

  // ── Admin ViewModels ─────────────────────────────────────────────────────
  getIt.registerFactory<AdminDashboardViewModel>(
    () => AdminDashboardViewModel(
      adminRepository: AdminRepository.fromMock(
        getIt<MockAdminRepository>(),
      ),
    ),
  );
  getIt.registerFactory<AdminStudentListViewModel>(
    () => AdminStudentListViewModel(
      adminRepository: AdminRepository.fromMock(
        getIt<MockAdminRepository>(),
      ),
    ),
  );
  getIt.registerFactory<AdminWardenListViewModel>(
    () => AdminWardenListViewModel(
      adminRepository: AdminRepository.fromMock(
        getIt<MockAdminRepository>(),
      ),
    ),
  );
  getIt.registerFactory<ScannerManagementViewModel>(
    () => ScannerManagementViewModel(
      adminRepository: AdminRepository.fromMock(
        getIt<MockAdminRepository>(),
      ),
    ),
  );
  getIt.registerFactory<AdminReportsViewModel>(
    () => AdminReportsViewModel(
      adminRepository: AdminRepository.fromMock(
        getIt<MockAdminRepository>(),
      ),
    ),
  );
}

// ── REAL SETUP ────────────────────────────────────────────────────────────────

void _registerReal() {
  getIt.registerSingleton<ApiClient>(
    ApiClient(secureStorage: getIt<SecureStorageService>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiClient: getIt<ApiClient>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );
  getIt.registerLazySingleton<StudentRepository>(
    () => StudentRepository(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<WardenRepository>(
    () => WardenRepository(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepository(apiClient: getIt<ApiClient>()),
  );

  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<StudentDashboardViewModel>(
    () => StudentDashboardViewModel(studentRepository: getIt<StudentRepository>()),
  );
  getIt.registerFactory<GenerateSlQrViewModel>(
    () => GenerateSlQrViewModel(studentRepository: getIt<StudentRepository>()),
  );
  getIt.registerFactory<RequestLeaveViewModel>(
    () => RequestLeaveViewModel(studentRepository: getIt<StudentRepository>()),
  );
  getIt.registerFactory<StudentHistoryViewModel>(
    () => StudentHistoryViewModel(studentRepository: getIt<StudentRepository>()),
  );
  getIt.registerFactory<StudentProfileViewModel>(
    () => StudentProfileViewModel(studentRepository: getIt<StudentRepository>()),
  );
  getIt.registerFactory<WardenDashboardViewModel>(
    () => WardenDashboardViewModel(wardenRepository: getIt<WardenRepository>()),
  );
  getIt.registerFactory<LeaveRequestsViewModel>(
    () => LeaveRequestsViewModel(
      wardenRepository: getIt<WardenRepository>(),
      notificationService: getIt<NotificationService>(),
    ),
  );
  getIt.registerFactory<StudentManagementViewModel>(
    () => StudentManagementViewModel(wardenRepository: getIt<WardenRepository>()),
  );
  getIt.registerFactory<WardenOwnLeaveViewModel>(
    () => WardenOwnLeaveViewModel(wardenRepository: getIt<WardenRepository>()),
  );
  getIt.registerFactory<AdminDashboardViewModel>(
    () => AdminDashboardViewModel(adminRepository: getIt<AdminRepository>()),
  );
  getIt.registerFactory<AdminStudentListViewModel>(
    () => AdminStudentListViewModel(adminRepository: getIt<AdminRepository>()),
  );
  getIt.registerFactory<AdminWardenListViewModel>(
    () => AdminWardenListViewModel(adminRepository: getIt<AdminRepository>()),
  );
  getIt.registerFactory<ScannerManagementViewModel>(
    () => ScannerManagementViewModel(adminRepository: getIt<AdminRepository>()),
  );
  getIt.registerFactory<AdminReportsViewModel>(
    () => AdminReportsViewModel(adminRepository: getIt<AdminRepository>()),
  );
}

// ── MockAuthViewModel ─────────────────────────────────────────────────────────
// Subclass of AuthViewModel that uses MockAuthRepository.
// Overrides login() and logout() to call the mock instead of the real repo.

class MockAuthViewModel extends AuthViewModel {
  final MockAuthRepository _mockRepo;

  MockAuthViewModel({required MockAuthRepository mockAuthRepo})
      : _mockRepo = mockAuthRepo,
        super(authRepository: _NoOpAuthRepository()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final loggedIn = await _mockRepo.isLoggedIn();
    if (loggedIn) {
      final role   = await _mockRepo.getStoredRole();
      final userId = await _mockRepo.getStoredUserId();
      setMockAuth(role: role, userId: userId);
    } else {
      setUnauthenticated();
    }
  }

  @override
  Future<bool> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    setLoading();
    final result = await _mockRepo.login(
      LoginRequest(email: email, password: password, role: role),
    );
    if (result.isSuccess) {
      final resp = result.data;
      setMockAuth(
        role: resp.role,
        userId: resp.userId,
        name: resp.name,
        email: resp.email,
      );
      return true;
    }
    setError(result.error);
    return false;
  }

  @override
  Future<void> logout() async {
    await _mockRepo.logout();
    setUnauthenticated();
  }
}

// A no-op AuthRepository that satisfies the super() constructor.
// None of its methods are ever called when in mock mode.
// We pass the already-registered SecureStorageService from getIt.
class _NoOpAuthRepository extends AuthRepository {
  _NoOpAuthRepository()
      : super(
          // ApiClient won't be used — pass a stub storage just to compile
          apiClient: ApiClient(secureStorage: getIt<SecureStorageService>()),
          secureStorage: getIt<SecureStorageService>(),
        );
}