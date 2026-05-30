// FILE: lib/core/utils/result.dart
//
// PURPOSE:
//   Implements a Result<T> type for safe error handling without exceptions.
//   This is a core part of Clean Architecture — instead of throwing exceptions
//   in repositories and services, every operation returns a Result that is
//   either a Success or a Failure.
//
// WHY THIS MATTERS:
//   - Repositories return Result<T> instead of throwing
//   - ViewModels check result.isSuccess / result.isFailure
//   - No try-catch scattered through the ViewModel layer
//   - Errors are data, not control flow
//
// USAGE:
//   // In repository:
//   return Result.success(studentProfile);
//   return Result.failure('Network error occurred');
//
//   // In viewmodel:
//   final result = await _repo.fetchProfile();
//   if (result.isSuccess) {
//     _student = result.data;
//   } else {
//     _error = result.error;
//   }

class Result<T> {
  final T? _data;
  final String? _error;
  final bool _isSuccess;

  const Result._({T? data, String? error, required bool isSuccess})
    : _data = data,
      _error = error,
      _isSuccess = isSuccess;

  // ── Factories ─────────────────────────────────────────────────────────────

  /// Creates a successful result with data
  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  /// Creates a failed result with an error message
  factory Result.failure(String error) {
    return Result._(error: error, isSuccess: false);
  }

  /// Creates a successful result with no data (for void operations)
  static Result<void> voidSuccess() {
    return const Result._(isSuccess: true);
  }

  // ── Accessors ─────────────────────────────────────────────────────────────

  bool get isSuccess => _isSuccess;
  bool get isFailure => !_isSuccess;

  /// Returns data. Only call this after checking isSuccess.
  T get data {
    if (!_isSuccess) {
      throw StateError('Attempted to access data on a failed Result');
    }
    return _data as T;
  }

  /// Returns error message. Only call this after checking isFailure.
  String get error {
    if (_isSuccess) {
      throw StateError('Attempted to access error on a successful Result');
    }
    return _error!;
  }

  // ── Functional Helpers ────────────────────────────────────────────────────

  /// Transforms successful data. Passes failures through unchanged.
  Result<U> map<U>(U Function(T data) transform) {
    if (isSuccess) {
      return Result.success(transform(_data as T));
    }
    return Result.failure(_error!);
  }

  /// Executes a callback based on success/failure
  void fold({
    required void Function(T data) onSuccess,
    required void Function(String error) onFailure,
  }) {
    if (_isSuccess) {
      onSuccess(_data as T);
    } else {
      onFailure(_error!);
    }
  }

  @override
  String toString() {
    if (_isSuccess) {
      return 'Result.success($_data)';
    }
    return 'Result.failure($_error)';
  }
}
