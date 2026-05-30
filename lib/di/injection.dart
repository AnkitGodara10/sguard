// FILE: lib/di/injection.dart
//
// PURPOSE:
//   Configures the dependency injection (DI) container using GetIt.
//   GetIt is a service locator — it stores singleton or factory instances
//   of services, repositories, and viewmodels and provides them on demand.
//
// WHY DEPENDENCY INJECTION:
//   Without DI:
//     - Every class creates its own dependencies (tight coupling)
//     - Testing requires mocking internal classes
//     - Hard to swap implementations
//
//   With DI:
//     - Dependencies are injected from outside (loose coupling)
//     - Easy to swap real API client with a mock for testing
//     - All wiring is in one place
//
// REGISTRATION TYPES:
//   registerSingleton — One instance for the app lifetime (ApiClient, Storage)
//   registerFactory — New instance each time (ViewModels — because they hold
//     screen-specific state and must be fresh for each screen visit)
//   registerLazySingleton — Created only when first accessed (repositories)
//
// HOW IT WORKS:
//   main.dart calls initializeDependencies() before runApp().
//   Widgets access instances via getIt<T>() or context.read<T>() (for
//   Provider-wrapped ViewModels).

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../core/services/api_client.dart';
import '../core/services/notification_service.dart';
import '../core/services/secure_storage_service.dart';
import '../core/repositories/auth_repository.dart';
import '../core/repositories/student_repository.dart';
import '../core/repositories/warden_repository.dart';
import '../core/repositories/admin_repository.dart';
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

// Global service locator instance
final GetIt getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // ── 1. Core Services (Singletons) ─────────────────────────────────────────
  // These live for the entire app lifetime — only one instance ever exists.

  // Secure storage wraps flutter_secure_storage
  getIt.registerSingleton<SecureStorageService>(
    SecureStorageService(
      storage: const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ),
    ),
  );

  // API client depends on secure storage (for token injection)
  getIt.registerSingleton<ApiClient>(
    ApiClient(secureStorage: getIt<SecureStorageService>()),
  );

  // Notification service — initialized asynchronously
  final notificationService = NotificationService();
  await notificationService.initialize();
  getIt.registerSingleton<NotificationService>(notificationService);

  // ── 2. Repositories (Lazy Singletons) ─────────────────────────────────────
  // Created on first use. Singletons because they're stateless data providers.

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

  // ── 3. ViewModels (Factories or Singletons) ────────────────────────────────
  //
  // AuthViewModel is a SINGLETON because it's provided at the app root level
  // (in app.dart's MultiProvider) and must persist across navigation.
  //
  // All other ViewModels are FACTORIES — a new instance is created each time
  // the view is visited. This ensures state is clean on each navigation.
  // They are provided locally in each view using ChangeNotifierProvider.

  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(authRepository: getIt<AuthRepository>()),
  );

  // Student ViewModels
  getIt.registerFactory<StudentDashboardViewModel>(
    () => StudentDashboardViewModel(
      studentRepository: getIt<StudentRepository>(),
    ),
  );

  getIt.registerFactory<GenerateSlQrViewModel>(
    () => GenerateSlQrViewModel(studentRepository: getIt<StudentRepository>()),
  );

  getIt.registerFactory<RequestLeaveViewModel>(
    () => RequestLeaveViewModel(studentRepository: getIt<StudentRepository>()),
  );

  getIt.registerFactory<StudentHistoryViewModel>(
    () =>
        StudentHistoryViewModel(studentRepository: getIt<StudentRepository>()),
  );

  getIt.registerFactory<StudentProfileViewModel>(
    () =>
        StudentProfileViewModel(studentRepository: getIt<StudentRepository>()),
  );

  // Warden ViewModels
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
    () =>
        StudentManagementViewModel(wardenRepository: getIt<WardenRepository>()),
  );

  getIt.registerFactory<WardenOwnLeaveViewModel>(
    () => WardenOwnLeaveViewModel(wardenRepository: getIt<WardenRepository>()),
  );

  // Admin ViewModels
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
