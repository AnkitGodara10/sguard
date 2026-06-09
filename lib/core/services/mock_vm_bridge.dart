// FILE: lib/core/services/mock_vm_bridge.dart
//
// PURPOSE:
//   Provides factory extensions that let ViewModels accept mock repositories.
//   Because Dart doesn't support extension constructors, we use a simpler
//   and more robust pattern: each ViewModel has both a real constructor
//   (using typed repositories) and a mock constructor. This file documents
//   what the mock constructors do.
//
// ACTUAL IMPLEMENTATION:
//   Rather than factory extension methods, the cleanest approach in Dart is
//   to make each ViewModel accept a dynamic interface. We use abstract
//   interfaces (defined below) that both real and mock repos implement,
//   then each ViewModel depends on the interface, not the concrete class.
//
// WHY INTERFACES:
//   - StudentDashboardViewModel depends on IStudentRepository
//   - Real backend: StudentRepository implements IStudentRepository
//   - Mock backend: MockStudentRepository implements IStudentRepository
//   - Switching is just which implementation is injected
//
// This is standard Dependency Inversion (the D in SOLID).

// ─────────────────────────────────────────────────────────────────────────────
// IMPORTANT DEVELOPER NOTE:
//
// The cleanest solution for mock/real switching requires all ViewModels to
// accept abstract interfaces. To keep the initial implementation simpler,
// the approach used in injection.dart uses a flag and conditional registration.
//
// For a production codebase, refactor as follows:
//
// 1. Create interfaces in lib/core/interfaces/:
//    abstract class IStudentRepository {
//      Future<Result<StudentModel>> fetchProfile(String id);
//      // ... all methods
//    }
//
// 2. Make both repos implement the interface:
//    class StudentRepository implements IStudentRepository { ... }
//    class MockStudentRepository implements IStudentRepository { ... }
//
// 3. ViewModels depend on the interface:
//    class StudentDashboardViewModel extends ChangeNotifier {
//      final IStudentRepository _repo;
//      StudentDashboardViewModel({required IStudentRepository repo})
//        : _repo = repo;
//    }
//
// 4. Injection.dart registers the correct implementation:
//    if (useMock) {
//      getIt.registerLazySingleton<IStudentRepository>(
//        () => MockStudentRepository(),
//      );
//    } else {
//      getIt.registerLazySingleton<IStudentRepository>(
//        () => StudentRepository(apiClient: getIt<ApiClient>()),
//      );
//    }
//
// This is the recommended upgrade path once the backend is being integrated.
// ─────────────────────────────────────────────────────────────────────────────
