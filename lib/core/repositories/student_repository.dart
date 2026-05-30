// FILE: lib/core/repositories/student_repository.dart
//
// PURPOSE:
//   Handles all student-related data operations:
//     - Fetching student profile
//     - Generating QR codes (SL and L)
//     - Submitting leave requests
//     - Fetching SL and Leave history
//     - Updating student profile fields
//
// WHAT DOES NOT BELONG HERE:
//   - Timer logic for QR countdown (that belongs in the ViewModel)
//   - UI state (loading, error display)
//   - Form validation (that's in validators.dart)
//
// BACKEND READINESS:
//   Every method maps to a specific API endpoint defined in AppConstants.
//   When the backend is ready, the URLs and response shapes are all that
//   needs attention. The ViewModel and UI code require no changes.

import '../constants/app_constants.dart';
import '../services/api_client.dart';
import '../utils/result.dart';
import '../../models/student_model.dart';
import '../../models/qr_model.dart';
import '../../models/leave_record_model.dart';

class StudentRepository {
  final ApiClient _apiClient;

  StudentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Result<StudentModel>> fetchProfile(String studentId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.endpointStudentProfile}/$studentId',
      );
      return Result.success(
        StudentModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  /// Students can update their own phone, email, and father's phone
  Future<Result<StudentModel>> updateProfile(
    String studentId, {
    String? phone,
    String? email,
    String? fathersPhone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (fathersPhone != null) data['fathers_phone'] = fathersPhone;

      final response = await _apiClient.patch(
        '${AppConstants.endpointStudentProfile}/$studentId',
        data: data,
      );
      return Result.success(
        StudentModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Short Leave QR ────────────────────────────────────────────────────────

  /// Generates a new SL QR code for the student.
  /// Backend enforces: no active SL QR already exists.
  Future<Result<QrModel>> generateSlQr(String studentId, String reason) async {
    try {
      final response = await _apiClient.post(
        AppConstants.endpointGenerateSlQr,
        data: {'student_id': studentId, 'reason': reason},
      );
      return Result.success(
        QrModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  /// Fetches the current active SL QR for a student, if one exists
  Future<Result<QrModel?>> getActiveSlQr(String studentId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.endpointGenerateSlQr}/active',
        queryParameters: {'student_id': studentId},
      );
      if (response.data == null) return Result.success(null);
      return Result.success(
        QrModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Leave Request ─────────────────────────────────────────────────────────

  /// Submits a Leave (L) request to the warden.
  /// Backend enforces: no active Leave already exists.
  Future<Result<LeaveRecord>> requestLeave({
    required String studentId,
    required String reason,
    required String fathersName,
    required String fathersPhone,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConstants.endpointRequestLeave,
        data: {
          'student_id': studentId,
          'reason': reason,
          'fathers_name': fathersName,
          'fathers_phone': fathersPhone,
        },
      );
      return Result.success(
        LeaveRecord.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  /// Gets the current pending/active Leave record, if one exists
  Future<Result<LeaveRecord?>> getActiveLeave(String studentId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.endpointRequestLeave}/active',
        queryParameters: {'student_id': studentId},
      );
      if (response.data == null) return Result.success(null);
      return Result.success(
        LeaveRecord.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── History ───────────────────────────────────────────────────────────────

  /// Fetches SL history for the student.
  /// Student can only see last 30 days.
  Future<Result<List<ShortLeaveRecord>>> fetchSlHistory(
    String studentId,
  ) async {
    try {
      final cutoff = DateTime.now().subtract(
        Duration(days: AppConstants.studentSlHistoryDays),
      );

      final response = await _apiClient.get(
        AppConstants.endpointStudentSlHistory,
        queryParameters: {
          'student_id': studentId,
          'from': cutoff.toIso8601String(),
        },
      );

      final list = (response.data as List)
          .map((e) => ShortLeaveRecord.fromJson(e as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  /// Fetches Leave history for the student.
  /// Student can only see last 6 months.
  Future<Result<List<LeaveRecord>>> fetchLeaveHistory(String studentId) async {
    try {
      final cutoff = DateTime.now().subtract(
        Duration(days: AppConstants.studentLeaveHistoryMonths * 30),
      );

      final response = await _apiClient.get(
        AppConstants.endpointStudentLeaveHistory,
        queryParameters: {
          'student_id': studentId,
          'from': cutoff.toIso8601String(),
        },
      );

      final list = (response.data as List)
          .map((e) => LeaveRecord.fromJson(e as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }
}
