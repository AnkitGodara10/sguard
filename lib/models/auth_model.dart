// FILE: lib/models/auth_model.dart
//
// PURPOSE:
//   Contains request and response models for the authentication flow.
//   These are "DTO" (Data Transfer Object) models — they represent exactly
//   what the API sends/receives, not the app's internal representation.
//
// WHY SEPARATE FROM USER MODELS:
//   - Login response includes tokens (not part of StudentModel)
//   - Signup requests need different fields per role
//   - Keeping auth models separate prevents user profile models from
//     being polluted with auth concerns

import 'user_role.dart';

// ── Login ─────────────────────────────────────────────────────────────────────

class LoginRequest {
  final String email;
  final String password;
  final UserRole role;

  const LoginRequest({
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'role': role.toApiString(),
  };
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final UserRole role;
  final String name;
  final String email;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
    required this.name,
    required this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      userId: json['user_id'] as String,
      role: UserRole.fromString(json['role'] as String?) ?? UserRole.student,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

// ── Student Signup ────────────────────────────────────────────────────────────

class StudentSignupRequest {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String hostelNumber;
  final String roomNumber;

  const StudentSignupRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.hostelNumber,
    required this.roomNumber,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'password': password,
    'hostel_number': hostelNumber,
    'room_number': roomNumber,
    'role': UserRole.student.toApiString(),
  };
}

// ── Warden Signup ─────────────────────────────────────────────────────────────

class WardenSignupRequest {
  final String wardenId;
  final String name;
  final String phone;
  final String email;
  final String password;
  final String hostel;

  const WardenSignupRequest({
    required this.wardenId,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.hostel,
  });

  Map<String, dynamic> toJson() => {
    'warden_id': wardenId,
    'name': name,
    'phone': phone,
    'email': email,
    'password': password,
    'hostel': hostel,
    'role': UserRole.warden.toApiString(),
  };
}

// ── Admin Signup ──────────────────────────────────────────────────────────────

class AdminSignupRequest {
  final String name;
  final String phone;
  final String email;
  final String password;

  const AdminSignupRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'password': password,
    'role': UserRole.admin.toApiString(),
  };
}

// ── Generic Signup Response ───────────────────────────────────────────────────

class SignupResponse {
  final String userId;
  final String message;

  const SignupResponse({required this.userId, required this.message});

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      userId: json['user_id'] as String,
      message: json['message'] as String? ?? 'Account created successfully',
    );
  }
}
