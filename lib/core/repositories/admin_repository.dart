// FILE: lib/core/repositories/admin_repository.dart
//
// PURPOSE:
//   Handles all admin-level data operations.
//   Admins have the broadest access scope in SGuard.
//
// ADMIN CAPABILITIES:
//   - Add students and wardens to master lists
//   - Register scanner devices
//   - View ALL leave records (students + wardens)
//   - View reports and summaries
//   - Approve warden Leave (L) requests

import '../services/api_client.dart';
import '../utils/result.dart';
import '../../models/student_model.dart';
import '../../models/warden_model.dart';
import '../../models/leave_record_model.dart';
import '../../models/scanner_model.dart';

class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // ── Student Master List ───────────────────────────────────────────────────

  Future<Result<List<StudentMasterRecord>>> fetchStudentMasterList() async {
    try {
      final response = await _apiClient.get('/admin/students/master');
      final list = (response.data as List)
          .map((e) => StudentMasterRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<StudentMasterRecord>> addStudentToMasterList({
    required String rollNumber,
    required String name,
    required String year,
    required String fathersName,
    required String fathersPhone,
  }) async {
    try {
      final response = await _apiClient.post(
        '/admin/students/master',
        data: {
          'roll_number': rollNumber,
          'name': name,
          'year': year,
          'fathers_name': fathersName,
          'fathers_phone': fathersPhone,
        },
      );
      return Result.success(
        StudentMasterRecord.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Warden Master List ────────────────────────────────────────────────────

  Future<Result<List<WardenMasterRecord>>> fetchWardenMasterList() async {
    try {
      final response = await _apiClient.get('/admin/wardens/master');
      final list = (response.data as List)
          .map((e) => WardenMasterRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<WardenMasterRecord>> addWardenToMasterList({
    required String wardenId,
    required String name,
    required String hostel,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.post(
        '/admin/wardens/master',
        data: {
          'warden_id': wardenId,
          'name': name,
          'hostel': hostel,
          'phone': phone,
        },
      );
      return Result.success(
        WardenMasterRecord.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Scanner Management ────────────────────────────────────────────────────

  Future<Result<List<ScannerModel>>> fetchScanners() async {
    try {
      final response = await _apiClient.get('/admin/scanners');
      final list = (response.data as List)
          .map((e) => ScannerModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<ScannerModel>> registerScanner({
    required String name,
    required String location,
    required String deviceId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/admin/scanners/register',
        data: {'name': name, 'location': location, 'device_id': deviceId},
      );
      return Result.success(
        ScannerModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<void>> deactivateScanner(String scannerId) async {
    try {
      await _apiClient.patch(
        '/admin/scanners/$scannerId',
        data: {'status': 'inactive'},
      );
      return Result.voidSuccess();
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  // ── Reports / Records ─────────────────────────────────────────────────────

  Future<Result<List<ShortLeaveRecord>>> fetchAllSlRecords({
    DateTime? from,
    DateTime? to,
    String? hostelNumber,
  }) async {
    try {
      final response = await _apiClient.get(
        '/admin/records/sl',
        queryParameters: {
          if (from != null) 'from': from.toIso8601String(),
          if (to != null) 'to': to.toIso8601String(),
          'hostel_number': ?hostelNumber,
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

  Future<Result<List<LeaveRecord>>> fetchAllLeaveRecords({
    DateTime? from,
    DateTime? to,
    String? hostelNumber,
  }) async {
    try {
      final response = await _apiClient.get(
        '/admin/records/leave',
        queryParameters: {
          if (from != null) 'from': from.toIso8601String(),
          if (to != null) 'to': to.toIso8601String(),
          'hostel_number': ?hostelNumber,
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

  // ── Warden Leave Approvals ────────────────────────────────────────────────

  Future<Result<List<LeaveRequest>>> fetchWardenLeaveRequests() async {
    try {
      final response = await _apiClient.get('/admin/warden-leave/requests');
      final list = (response.data as List)
          .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<void>> approveWardenLeave(String leaveRequestId) async {
    try {
      await _apiClient.post('/admin/warden-leave/approve/$leaveRequestId');
      return Result.voidSuccess();
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }

  Future<Result<void>> rejectWardenLeave(
    String leaveRequestId,
    String reason,
  ) async {
    try {
      await _apiClient.post(
        '/admin/warden-leave/reject/$leaveRequestId',
        data: {'rejection_reason': reason},
      );
      return Result.voidSuccess();
    } catch (e) {
      return Result.failure(ApiClient.parseError(e));
    }
  }
}
