// FILE: lib/core/repositories/warden_repository.dart
//
// PURPOSE:
//   Handles all warden-related data operations:
//     - Fetching warden profile
//     - Fetching pending leave requests from students
//     - Approving or rejecting leave requests
//     - Fetching student lists and individual student records
//     - Modifying student hostel/room numbers
//     - Warden's own leave operations (same as student leave flow)
//
// KEY WARDEN PERMISSIONS (enforced by backend too):
//   - Wardens can see ALL student records for their hostel
//   - Wardens can modify hostel number and room number of students
//   - Wardens' own Leave (L) requests go to Admin, not to another warden

import '../constants/app_constants.dart';
import '../services/api_client.dart';
import '../utils/result.dart';
import '../../models/warden_model.dart';
import '../../models/student_model.dart';
import '../../models/leave_record_model.dart';
import '../../models/qr_model.dart';

class WardenRepository {
  final ApiClient _apiClient;

  WardenRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Result<WardenModel>> fetchProfile(String wardenId) async {
    try {
      final response = await _apiClient.get(
        '${AppConstants.endpointWardenProfile}/$wardenId',
      );
      return Result.success(
        WardenModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Leave Requests from Students ──────────────────────────────────────────

  /// Fetches all pending leave requests for this warden's hostel
  Future<Result<List<LeaveRequest>>> fetchPendingRequests(
    String wardenId,
  ) async {
    try {
      final response = await _apiClient.get(
        AppConstants.endpointLeaveRequests,
        queryParameters: {
          'warden_id': wardenId,
          'status': AppConstants.leaveStatusPending,
        },
      );
      final list = (response.data as List)
          .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  /// Approves a student's Leave request.
  /// Backend will generate the QR code and notify the student.
  Future<Result<void>> approveLeaveRequest(String leaveRequestId) async {
    try {
      await _apiClient.post(
        '${AppConstants.endpointApproveLeave}/$leaveRequestId',
      );
      return Result.voidSuccess();
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  /// Rejects a student's Leave request
  Future<Result<void>> rejectLeaveRequest(
    String leaveRequestId,
    String reason,
  ) async {
    try {
      await _apiClient.post(
        '${AppConstants.endpointRejectLeave}/$leaveRequestId',
        data: {'rejection_reason': reason},
      );
      return Result.voidSuccess();
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Student Management ────────────────────────────────────────────────────

  /// Fetches all students in the warden's hostel
  Future<Result<List<StudentModel>>> fetchHostelStudents(
    String wardenId,
  ) async {
    try {
      final response = await _apiClient.get(
        AppConstants.endpointWardenStudents,
        queryParameters: {'warden_id': wardenId},
      );
      final list = (response.data as List)
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  /// Wardens can update hostel number and room number only
  Future<Result<StudentModel>> updateStudentHostelRoom(
    String studentId, {
    String? hostelNumber,
    String? roomNumber,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (hostelNumber != null) data['hostel_number'] = hostelNumber;
      if (roomNumber != null) data['room_number'] = roomNumber;

      final response = await _apiClient.patch(
        '${AppConstants.endpointWardenStudents}/$studentId',
        data: data,
      );
      return Result.success(
        StudentModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Student Leave Records (Warden View) ───────────────────────────────────

  Future<Result<List<ShortLeaveRecord>>> fetchStudentSlRecords(
    String studentId,
  ) async {
    try {
      final response = await _apiClient.get('/warden/students/$studentId/sl');
      final list = (response.data as List)
          .map((e) => ShortLeaveRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<List<LeaveRecord>>> fetchStudentLeaveRecords(
    String studentId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/warden/students/$studentId/leave',
      );
      final list = (response.data as List)
          .map((e) => LeaveRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Warden's Own QR / Leave ───────────────────────────────────────────────
  // Wardens use the same SL flow as students

  Future<Result<QrModel>> generateWardenSlQr(
    String wardenId,
    String reason,
  ) async {
    try {
      final response = await _apiClient.post(
        '/warden/sl/qr/generate',
        data: {'warden_id': wardenId, 'reason': reason},
      );
      return Result.success(
        QrModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  /// Warden's Leave request goes to Admin
  Future<Result<LeaveRecord>> requestWardenLeave({
    required String wardenId,
    required String reason,
  }) async {
    try {
      final response = await _apiClient.post(
        '/warden/leave/request',
        data: {'warden_id': wardenId, 'reason': reason},
      );
      return Result.success(
        LeaveRecord.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }
}
