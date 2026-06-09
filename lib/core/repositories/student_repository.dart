// FILE: lib/core/repositories/student_repository.dart
//
// PURPOSE:
//   Handles all student-related data operations.
//   Supports both real API calls and mock mode via fromMock() constructor.
//
// SWITCHING:
//   StudentRepository({required ApiClient})   → real backend
//   StudentRepository.fromMock(MockRepo)       → mock data

import '../constants/app_constants.dart';
import '../services/api_client.dart';
import '../utils/result.dart';
import '../../models/student_model.dart';
import '../../models/qr_model.dart';
import '../../models/leave_record_model.dart';
import 'mock_student_repository.dart';

class StudentRepository {
  final ApiClient? _apiClient;
  final MockStudentRepository? _mock;

  StudentRepository({required ApiClient apiClient})
    : _apiClient = apiClient,
      _mock = null;

  StudentRepository.fromMock(MockStudentRepository mock)
    : _apiClient = null,
      _mock = mock;

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<Result<StudentModel>> fetchProfile(String studentId) async {
    if (_mock != null) return _mock.fetchProfile(studentId);
    try {
      final r = await _apiClient!.get(
        '${AppConstants.endpointStudentProfile}/$studentId',
      );
      return Result.success(
        StudentModel.fromJson(r.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<StudentModel>> updateProfile(
    String studentId, {
    String? phone,
    String? email,
    String? fathersPhone,
  }) async {
    if (_mock != null) {
      return _mock.updateProfile(
        studentId,
        phone: phone,
        email: email,
        fathersPhone: fathersPhone,
      );
    }
    try {
      final data = <String, dynamic>{};
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (fathersPhone != null) data['fathers_phone'] = fathersPhone;
      final r = await _apiClient!.patch(
        '${AppConstants.endpointStudentProfile}/$studentId',
        data: data,
      );
      return Result.success(
        StudentModel.fromJson(r.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Short Leave QR ─────────────────────────────────────────────────────────

  Future<Result<QrModel>> generateSlQr(String studentId, String reason) async {
    if (_mock != null) return _mock.generateSlQr(studentId, reason);
    try {
      final r = await _apiClient!.post(
        AppConstants.endpointGenerateSlQr,
        data: {'student_id': studentId, 'reason': reason},
      );
      return Result.success(QrModel.fromJson(r.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<QrModel?>> getActiveSlQr(String studentId) async {
    if (_mock != null) return _mock.getActiveSlQr(studentId);
    try {
      final r = await _apiClient!.get(
        '${AppConstants.endpointGenerateSlQr}/active',
        queryParameters: {'student_id': studentId},
      );
      if (r.data == null) return Result.success(null);
      return Result.success(QrModel.fromJson(r.data as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Leave ──────────────────────────────────────────────────────────────────

  Future<Result<LeaveRecord>> requestLeave({
    required String studentId,
    required String reason,
    required String fathersName,
    required String fathersPhone,
  }) async {
    if (_mock != null) {
      return _mock.requestLeave(
        studentId: studentId,
        reason: reason,
        fathersName: fathersName,
        fathersPhone: fathersPhone,
      );
    }
    try {
      final r = await _apiClient!.post(
        AppConstants.endpointRequestLeave,
        data: {
          'student_id': studentId,
          'reason': reason,
          'fathers_name': fathersName,
          'fathers_phone': fathersPhone,
        },
      );
      return Result.success(
        LeaveRecord.fromJson(r.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<LeaveRecord?>> getActiveLeave(String studentId) async {
    if (_mock != null) return _mock.getActiveLeave(studentId);
    try {
      final r = await _apiClient!.get(
        '${AppConstants.endpointRequestLeave}/active',
        queryParameters: {'student_id': studentId},
      );
      if (r.data == null) return Result.success(null);
      return Result.success(
        LeaveRecord.fromJson(r.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── History ────────────────────────────────────────────────────────────────

  Future<Result<List<ShortLeaveRecord>>> fetchSlHistory(
    String studentId,
  ) async {
    if (_mock != null) return _mock.fetchSlHistory(studentId);
    try {
      final cutoff = DateTime.now().subtract(
        Duration(days: AppConstants.studentSlHistoryDays),
      );
      final r = await _apiClient!.get(
        AppConstants.endpointStudentSlHistory,
        queryParameters: {
          'student_id': studentId,
          'from': cutoff.toIso8601String(),
        },
      );
      final list = (r.data as List)
          .map((e) => ShortLeaveRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<List<LeaveRecord>>> fetchLeaveHistory(String studentId) async {
    if (_mock != null) return _mock.fetchLeaveHistory(studentId);
    try {
      final cutoff = DateTime.now().subtract(
        Duration(days: AppConstants.studentLeaveHistoryMonths * 30),
      );
      final r = await _apiClient!.get(
        AppConstants.endpointStudentLeaveHistory,
        queryParameters: {
          'student_id': studentId,
          'from': cutoff.toIso8601String(),
        },
      );
      final list = (r.data as List)
          .map((e) => LeaveRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }
}
