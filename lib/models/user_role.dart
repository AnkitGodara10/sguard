// FILE: lib/models/user_role.dart
//
// PURPOSE:
//   Defines the UserRole enum — the three roles in SGuard.
//   Using an enum instead of raw strings (e.g. 'student') prevents typos
//   and gives us type-safe role comparisons throughout the codebase.
//
// USAGE:
//   - Auth flow uses it to redirect to the correct dashboard
//   - Route guards use it to check if a user can access a screen
//   - ViewModels use it to determine what data to fetch
//   - Models use it when deserializing from API responses

enum UserRole {
  student,
  warden,
  admin;

  /// Converts a raw string from API/storage into a UserRole.
  /// Returns null if the string is unrecognized.
  static UserRole? fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'warden':
        return UserRole.warden;
      case 'admin':
        return UserRole.admin;
      default:
        return null;
    }
  }

  /// Converts UserRole to the string used in API requests
  String toApiString() {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.warden:
        return 'warden';
      case UserRole.admin:
        return 'admin';
    }
  }

  /// Human-readable display name
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.warden:
        return 'Warden';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
