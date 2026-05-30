// FILE: lib/viewmodels/auth/auth_viewmodel.dart
//
// PURPOSE:
//   The central authentication ViewModel for SGuard.
//   Because authentication state must be accessible app-wide (route guards,
//   profile screens, logout buttons), this ViewModel lives at the root
//   MultiProvider and is a singleton.
//
// RESPONSIBILITIES:
//   - Track login/logout state
//   - Track current user role
//   - Track current user ID and name
//   - Execute login for all three roles
//   - Execute signup for all three roles
//   - Restore session on app startup
//   - Notify listeners (and therefore the router) when state changes
//
// STATE MACHINE:
//   AuthState.initial → checking stored session
//   AuthState.authenticated → user is logged in
//   AuthState.unauthenticated → user is not logged in
//   AuthState.loading → login/signup in progress
//   AuthState.error → login/signup failed
//
// HOW THE ROUTER USES THIS:
//   GoRouter has `refreshListenable: authViewModel` — so whenever
//   authViewModel calls notifyListeners(), the router re-evaluates
//   its redirect, and the guard either allows navigation or redirects.

import 'package:flutter/foundation.dart';

import '../../core/repositories/auth_repository.dart';
import '../../models/auth_model.dart';
import '../../models/user_role.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthState _state = AuthState.initial;
  UserRole? _currentRole;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserEmail;
  String? _errorMessage;

  AuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // On creation, check if there's an existing session
    _restoreSession();
  }

  // ── Getters ───────────────────────────────────────────────────────────────

  AuthState get state => _state;
  UserRole? get currentRole => _currentRole;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get hasError => _state == AuthState.error;

  // ── Session Restoration ───────────────────────────────────────────────────

  /// Called once on app startup. Checks secure storage for an existing token.
  /// If found, restores the session without requiring re-login.
  Future<void> _restoreSession() async {
    _state = AuthState.initial;
    notifyListeners();

    final loggedIn = await _authRepository.isLoggedIn();

    if (loggedIn) {
      final role = await _authRepository.getStoredRole();
      final userId = await _authRepository.getStoredUserId();

      _currentRole = role;
      _currentUserId = userId;
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }

    notifyListeners(); // This triggers the router's redirect evaluation
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final request = LoginRequest(email: email, password: password, role: role);
    final result = await _authRepository.login(request);

    if (result.isSuccess) {
      final response = result.data;
      _currentRole = response.role;
      _currentUserId = response.userId;
      _currentUserName = response.name;
      _currentUserEmail = response.email;
      _state = AuthState.authenticated;
      notifyListeners(); // Router will redirect to the correct dashboard
      return true;
    } else {
      _errorMessage = result.error;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // ── Signup ────────────────────────────────────────────────────────────────

  Future<bool> signupStudent(StudentSignupRequest request) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.signupStudent(request);

    if (result.isSuccess) {
      // After successful signup, log the user in automatically
      return login(
        email: request.email,
        password: request.password,
        role: UserRole.student,
      );
    } else {
      _errorMessage = result.error;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signupWarden(WardenSignupRequest request) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.signupWarden(request);

    if (result.isSuccess) {
      return login(
        email: request.email,
        password: request.password,
        role: UserRole.warden,
      );
    } else {
      _errorMessage = result.error;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signupAdmin(AdminSignupRequest request) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.signupAdmin(request);

    if (result.isSuccess) {
      return login(
        email: request.email,
        password: request.password,
        role: UserRole.admin,
      );
    } else {
      _errorMessage = result.error;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authRepository.logout();

    _state = AuthState.unauthenticated;
    _currentRole = null;
    _currentUserId = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _errorMessage = null;

    notifyListeners(); // Router will redirect to role selection
  }

  // ── Error Handling ────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
