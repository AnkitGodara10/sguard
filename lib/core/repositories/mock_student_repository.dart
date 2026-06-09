// FILE: lib/core/repositories/mock_student_repository.dart
//
// PURPOSE:
//   Mock implementation of StudentRepository for development.
//   Returns MockDataService data with simulated network delays.
//   Switch it in injection.dart the same way as MockAuthRepository.

import '../services/mock_data_service.dart';
import '../utils/result.dart';
import '../../models/student_model.dart';
import '../../models/qr_model.dart';
import '../../models/leave_record_model.dart';
import '../constants/app_constants.dart';

class MockStudentRepository {
  // Simulates QR state in memory (resets each app run)
  QrModel? _activeSlQr;
  LeaveRecord? _activeLeave;

  Future<Result<StudentModel>> fetchProfile(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Result.success(MockDataService.mockStudent);
  }

  Future<Result<StudentModel>> updateProfile(
    String studentId, {
    String? phone,
    String? email,
    String? fathersPhone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final updated = MockDataService.mockStudent.copyWith(
      phone: phone,
      email: email,
      fathersPhone: fathersPhone,
    );
    return Result.success(updated);
  }

  Future<Result<QrModel>> generateSlQr(String studentId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate "already active" error
    if (_activeSlQr != null && _activeSlQr!.isActive) {
      return Result.failure('You already have an active Short Leave QR');
    }

    _activeSlQr = QrModel(
      id: 'qr_sl_${DateTime.now().millisecondsSinceEpoch}',
      userId: studentId,
      leaveType: AppConstants.leaveTypeSl,
      leaveId: 'sl_${DateTime.now().millisecondsSinceEpoch}',
      payload:
          'SGUARD.SL.${studentId.hashCode}.'
          '${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(
        const Duration(minutes: AppConstants.slQrValidityMinutes),
      ),
      scanCount: 0,
      status: AppConstants.qrStatusActive,
    );

    return Result.success(_activeSlQr!);
  }

  Future<Result<QrModel?>> getActiveSlQr(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_activeSlQr != null && !_activeSlQr!.isFullyUsed) {
      return Result.success(_activeSlQr);
    }
    return Result.success(null);
  }

  Future<Result<LeaveRecord>> requestLeave({
    required String studentId,
    required String reason,
    required String fathersName,
    required String fathersPhone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (_activeLeave != null && !_activeLeave!.isCompleted) {
      return Result.failure('You already have an active leave of this type');
    }

    _activeLeave = LeaveRecord(
      id: 'leave_${DateTime.now().millisecondsSinceEpoch}',
      serialNumber: 1,
      studentId: studentId,
      studentName: MockDataService.mockStudent.name,
      hostelNumber: MockDataService.mockStudent.hostelNumber,
      roomNumber: MockDataService.mockStudent.roomNumber,
      phone: MockDataService.mockStudent.phone,
      reason: reason,
      status: 'pending_approval',
      createdAt: DateTime.now(),
    );

    return Result.success(_activeLeave!);
  }

  Future<Result<LeaveRecord?>> getActiveLeave(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.success(_activeLeave);
  }

  Future<Result<List<ShortLeaveRecord>>> fetchSlHistory(
    String studentId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.success(MockDataService.mockSlHistory);
  }

  Future<Result<List<LeaveRecord>>> fetchLeaveHistory(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.success(MockDataService.mockLeaveHistory);
  }
}
