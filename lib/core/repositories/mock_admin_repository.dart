// FILE: lib/core/repositories/mock_admin_repository.dart
//
// PURPOSE:
//   Mock implementation of AdminRepository for development.

import '../services/mock_data_service.dart';
import '../utils/result.dart';
import '../../models/student_model.dart';
import '../../models/warden_model.dart';
import '../../models/leave_record_model.dart';
import '../../models/scanner_model.dart';

class MockAdminRepository {
  final List<StudentMasterRecord> _students = List.from(
    MockDataService.mockStudentMasterList,
  );
  final List<WardenMasterRecord> _wardens = List.from(
    MockDataService.mockWardenMasterList,
  );
  final List<ScannerModel> _scanners = List.from(MockDataService.mockScanners);

  Future<Result<List<StudentMasterRecord>>> fetchStudentMasterList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.success(List.from(_students));
  }

  Future<Result<StudentMasterRecord>> addStudentToMasterList({
    required String rollNumber,
    required String name,
    required String year,
    required String fathersName,
    required String fathersPhone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final record = StudentMasterRecord(
      id: 'smaster_${DateTime.now().millisecondsSinceEpoch}',
      serialNumber: _students.length + 1,
      rollNumber: rollNumber,
      name: name,
      year: year,
      fathersName: fathersName,
      fathersPhone: fathersPhone,
    );
    _students.add(record);
    return Result.success(record);
  }

  Future<Result<List<WardenMasterRecord>>> fetchWardenMasterList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.success(List.from(_wardens));
  }

  Future<Result<WardenMasterRecord>> addWardenToMasterList({
    required String wardenId,
    required String name,
    required String hostel,
    required String phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final record = WardenMasterRecord(
      id: 'wmaster_${DateTime.now().millisecondsSinceEpoch}',
      serialNumber: _wardens.length + 1,
      wardenId: wardenId,
      name: name,
      hostel: hostel,
      phone: phone,
    );
    _wardens.add(record);
    return Result.success(record);
  }

  Future<Result<List<ScannerModel>>> fetchScanners() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Result.success(List.from(_scanners));
  }

  Future<Result<ScannerModel>> registerScanner({
    required String name,
    required String location,
    required String deviceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final scanner = ScannerModel(
      id: 'scanner_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      location: location,
      deviceId: deviceId,
      status: 'active',
      registeredAt: DateTime.now(),
    );
    _scanners.add(scanner);
    return Result.success(scanner);
  }

  Future<Result<void>> deactivateScanner(String scannerId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _scanners.indexWhere((s) => s.id == scannerId);
    if (idx != -1) {
      final s = _scanners[idx];
      _scanners[idx] = ScannerModel(
        id: s.id,
        name: s.name,
        location: s.location,
        deviceId: s.deviceId,
        status: 'inactive',
        registeredAt: s.registeredAt,
      );
    }
    return Result.voidSuccess();
  }

  Future<Result<List<ShortLeaveRecord>>> fetchAllSlRecords({
    DateTime? from,
    DateTime? to,
    String? hostelNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Result.success(MockDataService.mockSlHistory);
  }

  Future<Result<List<LeaveRecord>>> fetchAllLeaveRecords({
    DateTime? from,
    DateTime? to,
    String? hostelNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Result.success(MockDataService.mockLeaveHistory);
  }

  Future<Result<List<LeaveRequest>>> fetchWardenLeaveRequests() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Result.success([]);
  }

  Future<Result<void>> approveWardenLeave(String leaveRequestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.voidSuccess();
  }

  Future<Result<void>> rejectWardenLeave(
    String leaveRequestId,
    String reason,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.voidSuccess();
  }
}
