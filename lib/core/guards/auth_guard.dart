// FILE: lib/core/guards/auth_guard.dart
//
// PURPOSE:
//   Defines route guard logic for the SGuard app.
//   A "guard" decides whether navigation to a route is permitted.
//   Used in the go_router redirect function.
//
// GUARDS IN SGUARD:
//   1. AuthGuard — redirects to role selection if not logged in
//   2. RoleGuard — redirects to correct dashboard if wrong role tries
//      to access a role-specific route (e.g. student trying to access
//      the admin dashboard)
//
// HOW IT WORKS WITH GO_ROUTER:
//   go_router's redirect callback calls these guards on every navigation.
//   If a guard returns a path, the user is redirected there.
//   If null is returned, navigation proceeds normally.

import '../../models/user_role.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../routes/route_names.dart';

class AuthGuard {
  /// Returns a redirect path if the user should be redirected, or null to
  /// allow navigation to proceed.
  static String? redirect({
    required String location,
    required AuthViewModel authViewModel,
  }) {
    final isLoggedIn = authViewModel.isLoggedIn;
    final role = authViewModel.currentRole;

    final isOnAuthPage =
        location.startsWith('/auth') || location == RouteNames.roleSelection;

    // ── Not logged in ──────────────────────────────────────────────────────
    if (!isLoggedIn) {
      // Allow access to role selection and auth pages
      if (isOnAuthPage) return null;
      // Redirect everything else to role selection
      return RouteNames.roleSelection;
    }

    // ── Logged in but on auth page ─────────────────────────────────────────
    if (isLoggedIn && isOnAuthPage) {
      return _dashboardForRole(role);
    }

    // ── Role-based route protection ────────────────────────────────────────
    if (role != null) {
      final isOnStudentRoute = location.startsWith('/student');
      final isOnWardenRoute = location.startsWith('/warden');
      final isOnAdminRoute = location.startsWith('/admin');

      // Student trying to access warden/admin routes
      if (role == UserRole.student && (isOnWardenRoute || isOnAdminRoute)) {
        return RouteNames.studentDashboard;
      }

      // Warden trying to access student/admin routes
      if (role == UserRole.warden && (isOnStudentRoute || isOnAdminRoute)) {
        return RouteNames.wardenDashboard;
      }

      // Admin trying to access student/warden routes
      if (role == UserRole.admin && (isOnStudentRoute || isOnWardenRoute)) {
        return RouteNames.adminDashboard;
      }
    }

    // No redirect needed
    return null;
  }

  static String? _dashboardForRole(UserRole? role) {
    switch (role) {
      case UserRole.student:
        return RouteNames.studentDashboard;
      case UserRole.warden:
        return RouteNames.wardenDashboard;
      case UserRole.admin:
        return RouteNames.adminDashboard;
      case null:
        return RouteNames.roleSelection;
    }
  }
}
