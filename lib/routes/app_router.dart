// FILE: lib/routes/app_router.dart
//
// PURPOSE:
//   Defines the entire navigation graph of SGuard using go_router.
//   This is the single place where:
//     1. All routes are declared with their paths and screen widgets
//     2. Route guards (redirect logic) are applied
//     3. Route transitions are configured
//     4. Deep link support is prepared
//
// WHY GO_ROUTER:
//   - Declarative routing (routes are data, not code)
//   - Built-in redirect / guard support
//   - Named routes with type-safe parameters
//   - Supports deep links out of the box
//   - Works with Flutter's Navigator 2.0
//
// HOW GUARDS WORK:
//   The `redirect` callback in GoRouter is called before every navigation.
//   It calls AuthGuard.redirect() which checks login state and role.
//   If the guard returns a path, the user is redirected there instead.
//   If null is returned, navigation proceeds normally.
//
// DATA FLOW:
//   User taps → context.go(RouteNames.x) → GoRouter checks redirect
//   → guard allows or redirects → screen widget is built → ViewModel provided

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/guards/auth_guard.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import '../views/auth/role_selection_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/signup_view.dart';
import '../views/student/student_dashboard_view.dart';
import '../views/student/generate_sl_qr_view.dart';
import '../views/student/request_leave_view.dart';
import '../views/student/student_history_view.dart';
import '../views/student/student_profile_view.dart';
import '../views/warden/warden_dashboard_view.dart';
import '../views/warden/leave_requests_view.dart';
import '../views/warden/student_management_view.dart';
import '../views/warden/warden_own_leave_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../views/admin/admin_student_list_view.dart';
import '../views/admin/admin_warden_list_view.dart';
import '../views/admin/scanner_management_view.dart';
import '../views/admin/admin_reports_view.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(BuildContext context) {
    // Access AuthViewModel so the router can react to auth state changes.
    // Using context.read here is safe because the router is rebuilt whenever
    // the auth state changes via the refreshListenable below.
    final authViewModel = context.read<AuthViewModel>();

    return GoRouter(
      initialLocation: RouteNames.roleSelection,
      debugLogDiagnostics: true,

      // refreshListenable tells go_router to re-evaluate the redirect
      // whenever AuthViewModel notifies listeners (login/logout events).
      refreshListenable: authViewModel,

      // ── Global redirect (guard) ──────────────────────────────────────────
      redirect: (context, state) {
        return AuthGuard.redirect(
          location: state.matchedLocation,
          authViewModel: authViewModel,
        );
      },

      // ── Route Definitions ────────────────────────────────────────────────
      routes: [
        // ── Auth Routes ───────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.roleSelection,
          name: 'roleSelection',
          builder: (context, state) => const RoleSelectionView(),
        ),
        GoRoute(
          path: RouteNames.login,
          name: 'login',
          builder: (context, state) {
            // Role is passed as a query parameter: /auth/login?role=student
            final roleString = state.uri.queryParameters['role'] ?? 'student';
            return LoginView(roleString: roleString);
          },
        ),
        GoRoute(
          path: RouteNames.signup,
          name: 'signup',
          builder: (context, state) {
            final roleString = state.uri.queryParameters['role'] ?? 'student';
            return SignupView(roleString: roleString);
          },
        ),

        // ── Student Routes ────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.studentDashboard,
          name: 'studentDashboard',
          pageBuilder: (context, state) =>
              _fadeTransition(state, const StudentDashboardView()),
        ),
        GoRoute(
          path: RouteNames.studentGenerateSlQr,
          name: 'studentGenerateSlQr',
          builder: (context, state) => const GenerateSlQrView(),
        ),
        GoRoute(
          path: RouteNames.studentRequestLeave,
          name: 'studentRequestLeave',
          builder: (context, state) => const RequestLeaveView(),
        ),
        GoRoute(
          path: RouteNames.studentHistory,
          name: 'studentHistory',
          builder: (context, state) => const StudentHistoryView(),
        ),
        GoRoute(
          path: RouteNames.studentProfile,
          name: 'studentProfile',
          builder: (context, state) => const StudentProfileView(),
        ),

        // ── Warden Routes ─────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.wardenDashboard,
          name: 'wardenDashboard',
          pageBuilder: (context, state) =>
              _fadeTransition(state, const WardenDashboardView()),
        ),
        GoRoute(
          path: RouteNames.wardenLeaveRequests,
          name: 'wardenLeaveRequests',
          builder: (context, state) => const LeaveRequestsView(),
        ),
        GoRoute(
          path: RouteNames.wardenStudentManagement,
          name: 'wardenStudentManagement',
          builder: (context, state) => const StudentManagementView(),
        ),
        GoRoute(
          path: '/warden/students/:studentId',
          name: 'wardenStudentDetail',
          builder: (context, state) {
            final studentId = state.pathParameters['studentId']!;
            return StudentManagementView(focusStudentId: studentId);
          },
        ),
        GoRoute(
          path: RouteNames.wardenOwnLeave,
          name: 'wardenOwnLeave',
          builder: (context, state) => const WardenOwnLeaveView(),
        ),

        // ── Admin Routes ──────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.adminDashboard,
          name: 'adminDashboard',
          pageBuilder: (context, state) =>
              _fadeTransition(state, const AdminDashboardView()),
        ),
        GoRoute(
          path: RouteNames.adminStudentList,
          name: 'adminStudentList',
          builder: (context, state) => const AdminStudentListView(),
        ),
        GoRoute(
          path: RouteNames.adminWardenList,
          name: 'adminWardenList',
          builder: (context, state) => const AdminWardenListView(),
        ),
        GoRoute(
          path: RouteNames.adminScannerManagement,
          name: 'adminScannerManagement',
          builder: (context, state) => const ScannerManagementView(),
        ),
        GoRoute(
          path: RouteNames.adminReports,
          name: 'adminReports',
          builder: (context, state) => const AdminReportsView(),
        ),
      ],

      // ── Error page ────────────────────────────────────────────────────────
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(state.error?.message ?? 'Unknown error'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.roleSelection),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Custom Page Transitions ───────────────────────────────────────────────

  /// Fade transition — used for dashboard root pages (not back-stackable)
  static CustomTransitionPage _fadeTransition(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
