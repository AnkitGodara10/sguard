// FILE: lib/routes/route_names.dart
//
// PURPOSE:
//   Centralizes every route path string in the app.
//   Just like AppColors prevents raw color values in widgets,
//   RouteNames prevents raw path strings like '/student/qr'
//   from being scattered across the codebase.
//
// RULES:
//   - Never use raw path strings in Navigator.pushNamed() or context.go()
//   - Always use RouteNames.something
//   - Nested routes use parent prefix for clarity

class RouteNames {
  RouteNames._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String roleSelection = '/';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';

  // ── Student ───────────────────────────────────────────────────────────────
  static const String studentDashboard = '/student/dashboard';
  static const String studentGenerateSlQr = '/student/sl/qr';
  static const String studentRequestLeave = '/student/leave/request';
  static const String studentHistory = '/student/history';
  static const String studentProfile = '/student/profile';

  // ── Warden ────────────────────────────────────────────────────────────────
  static const String wardenDashboard = '/warden/dashboard';
  static const String wardenLeaveRequests = '/warden/leave-requests';
  static const String wardenStudentManagement = '/warden/students';
  static const String wardenStudentDetail = '/warden/students/:studentId';
  static const String wardenOwnLeave = '/warden/my-leave';
  static const String wardenProfile = '/warden/profile';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStudentList = '/admin/students';
  static const String adminWardenList = '/admin/wardens';
  static const String adminScannerManagement = '/admin/scanners';
  static const String adminReports = '/admin/reports';
  static const String adminProfile = '/admin/profile';

  // ── Helper: build parameterized paths ────────────────────────────────────
  static String wardenStudentDetailPath(String studentId) =>
      '/warden/students/$studentId';
}
