// FILE: lib/core/repositories/mock_warden_repository.dart
//
// PURPOSE:
//   Mock implementation of WardenRepository for development.

import '../services/mock_data_service.dart';
import '../utils/result.dart';
import '../../models/warden_model.dart';
import '../../models/student_model.dart';
import '../../models/leave_record_model.dart';
import '../../models/qr_model.dart';
import '../constants/app_constants.dart';

class MockWardenRepository {
  List<LeaveRequest> _pendingRequests = List.from(
    MockDataService.mockLeaveRequests,
  );
  final List<StudentModel> _students = _buildMockStudents();

  static List<StudentModel> _buildMockStudents() {
    return MockDataService.mockStudentMasterList
        .map(
          (r) => StudentModel(
            id: 'student_${r.serialNumber}',
            name: r.name,
            email: '${r.rollNumber.toLowerCase()}@college.edu',
            phone: r.fathersPhone,
            hostelNumber: 'H3',
            roomNumber: '${100 + r.serialNumber}',
            rollNumber: r.rollNumber,
            year: r.year,
            fathersName: r.fathersName,
            fathersPhone: r.fathersPhone,
            createdAt: DateTime.now().subtract(const Duration(days: 90)),
          ),
        )
        .toList();
  }

  Future<Result<WardenModel>> fetchProfile(String wardenId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Result.success(MockDataService.mockWarden);
  }

  Future<Result<List<LeaveRequest>>> fetchPendingRequests(
    String wardenId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.success(List.from(_pendingRequests));
  }

  Future<Result<void>> approveLeaveRequest(String leaveRequestId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _pendingRequests.removeWhere((r) => r.id == leaveRequestId);
    return Result.voidSuccess();
  }

  Future<Result<void>> rejectLeaveRequest(
    String leaveRequestId,
    String reason,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _pendingRequests.removeWhere((r) => r.id == leaveRequestId);
    return Result.voidSuccess();
  }

  Future<Result<List<StudentModel>>> fetchHostelStudents(
    String wardenId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.success(_students);
  }

  Future<Result<StudentModel>> updateStudentHostelRoom(
    String studentId, {
    String? hostelNumber,
    String? roomNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _students.indexWhere((s) => s.id == studentId);
    if (idx == -1) return Result.failure('Student not found');

    final updated = _students[idx].copyWith(
      hostelNumber: hostelNumber,
      roomNumber: roomNumber,
    );
    _students[idx] = updated;
    return Result.success(updated);
  }

  Future<Result<List<ShortLeaveRecord>>> fetchStudentSlRecords(
    String studentId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Result.success(MockDataService.mockSlHistory);
  }

  Future<Result<List<LeaveRecord>>> fetchStudentLeaveRecords(
    String studentId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Result.success(MockDataService.mockLeaveHistory);
  }

  Future<Result<QrModel>> generateWardenSlQr(
    String wardenId,
    String reason,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Result.success(MockDataService.mockSlQr());
  }

  Future<Result<LeaveRecord>> requestWardenLeave({
    required String wardenId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Result.success(
      LeaveRecord(
        id: 'wleave_${DateTime.now().millisecondsSinceEpoch}',
        serialNumber: 1,
        studentId: wardenId,
        studentName: MockDataService.mockWarden.name,
        hostelNumber: MockDataService.mockWarden.hostel,
        roomNumber: 'Warden Quarters',
        phone: MockDataService.mockWarden.phone,
        reason: reason,
        status: AppConstants.leaveStatusPending,
        createdAt: DateTime.now(),
      ),
    );
  }
}
