// FILE: lib/core/utils/validators.dart
//
// PURPOSE:
//   Centralizes all form field validation logic.
//   Flutter form validation functions take a String? and return String?
//   (null = valid, non-null = error message). By collecting all validators
//   here, every form across every screen uses consistent rules.
//
// HOW IT WORKS:
//   - Each method is a validator function compatible with TextFormField.validator
//   - Validators can be chained using the `combine` helper
//   - Views call Validators.required, Validators.email, etc. directly
//
// IMPORTANT:
//   Validators only validate FORMAT. Business rules (e.g. "is this email
//   already registered") belong in the ViewModel/Repository layer, not here.

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';

class Validators {
  Validators._();

  // ── Basic Validators ──────────────────────────────────────────────────────

  /// Fails if the field is null or empty
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  /// Validates email format using regex
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (!AppConstants.emailRegex.hasMatch(value.trim())) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  /// Validates Indian mobile number format
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (!AppConstants.phoneRegex.hasMatch(value.trim())) {
      return AppStrings.invalidPhone;
    }
    return null;
  }

  // ── Password Validators ───────────────────────────────────────────────────

  /// Validates minimum length
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < AppConstants.minPasswordLength) {
      return AppStrings.passwordTooShort;
    }
    if (!AppConstants.passwordRegex.hasMatch(value)) {
      return AppStrings.passwordWeak;
    }
    return null;
  }

  /// Returns a validator that checks if value matches another field's value.
  /// Used for "confirm password" fields.
  static String? Function(String?) confirmPassword(String? originalValue) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return AppStrings.fieldRequired;
      }
      if (value != originalValue) {
        return AppStrings.passwordsDoNotMatch;
      }
      return null;
    };
  }

  // ── Name Validator ────────────────────────────────────────────────────────

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > AppConstants.maxNameLength) {
      return 'Name must be under ${AppConstants.maxNameLength} characters';
    }
    return null;
  }

  // ── IDs & Codes ───────────────────────────────────────────────────────────

  static String? wardenId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.trim().length < 3) {
      return 'Warden ID must be at least 3 characters';
    }
    return null;
  }

  static String? hostelNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  static String? roomNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  static String? rollNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  // ── Reason Validator ──────────────────────────────────────────────────────

  static String? reason(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.trim().length < 5) {
      return 'Please provide a more descriptive reason';
    }
    if (value.trim().length > 200) {
      return 'Reason must be under 200 characters';
    }
    return null;
  }

  // ── Combinator ────────────────────────────────────────────────────────────

  /// Combines multiple validators and returns the first error found.
  /// Usage: validator: Validators.combine([Validators.required, Validators.email])
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
