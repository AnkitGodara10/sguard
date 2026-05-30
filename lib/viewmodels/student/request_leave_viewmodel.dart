// FILE: lib/viewmodels/student/request_leave_viewmodel.dart
//
// PURPOSE:
//   Drives the Leave (L) request screen.
//   Handles form submission, validation feedback, and the state of the
//   leave request after submission (pending, approved, rejected).

import 'package:flutter/foundation.dart';

import '../../core/repositories/student_repository.dart';
import '../../models/leave_record_model.dart';

enum LeaveRequestState {
  initial,
  loading,
  submitted, // Request sent to warden
  approved,
  rejected,
  error,
  duplicateError, // Student already has an active leave
}

class RequestLeaveViewModel extends ChangeNotifier {
  final StudentRepository _studentRepository;

  LeaveRequestState _state = LeaveRequestState.initial;
  LeaveRecord? _leaveRecord;
  String? _errorMessage;

  RequestLeaveViewModel({required StudentRepository studentRepository})
    : _studentRepository = studentRepository;

  LeaveRequestState get state => _state;
  LeaveRecord? get leaveRecord => _leaveRecord;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LeaveRequestState.loading;

  Future<void> loadExistingLeave(String studentId) async {
    _state = LeaveRequestState.loading;
    notifyListeners();

    final result = await _studentRepository.getActiveLeave(studentId);

    if (result.isSuccess) {
      final leave = result.data;
      if (leave != null) {
        _leaveRecord = leave;
        if (leave.isPending) {
          _state = LeaveRequestState.submitted;
        } else if (leave.isApproved || leave.isActive)
          _state = LeaveRequestState.approved;
        else if (leave.isRejected)
          _state = LeaveRequestState.rejected;
        else
          _state = LeaveRequestState.initial;
      } else {
        _state = LeaveRequestState.initial;
      }
    } else {
      _state = LeaveRequestState.initial;
    }

    notifyListeners();
  }

  Future<bool> submitLeaveRequest({
    required String studentId,
    required String reason,
    required String fathersName,
    required String fathersPhone,
  }) async {
    _state = LeaveRequestState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _studentRepository.requestLeave(
      studentId: studentId,
      reason: reason,
      fathersName: fathersName,
      fathersPhone: fathersPhone,
    );

    if (result.isSuccess) {
      _leaveRecord = result.data;
      _state = LeaveRequestState.submitted;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      // Check if it's a duplicate leave error (HTTP 409)
      if (result.error.contains('active leave') ||
          result.error.contains('409') ||
          result.error.contains('already')) {
        _state = LeaveRequestState.duplicateError;
      } else {
        _state = LeaveRequestState.error;
      }
      notifyListeners();
      return false;
    }
  }
}
