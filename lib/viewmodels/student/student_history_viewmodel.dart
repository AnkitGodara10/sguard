// FILE: lib/viewmodels/student/student_history_viewmodel.dart
//
// PURPOSE:
//   Drives the Student History screen.
//   Fetches SL and Leave records for the student and exposes them for display.
//   Supports tab switching between SL history and Leave history.

import 'package:flutter/foundation.dart';

import '../../core/repositories/student_repository.dart';
import '../../models/leave_record_model.dart';

class StudentHistoryViewModel extends ChangeNotifier {
  final StudentRepository _studentRepository;

  bool _isLoadingSl = false;
  bool _isLoadingLeave = false;
  List<ShortLeaveRecord> _slRecords = [];
  List<LeaveRecord> _leaveRecords = [];
  String? _slError;
  String? _leaveError;
  int _currentTabIndex = 0; // 0 = SL, 1 = Leave

  StudentHistoryViewModel({required StudentRepository studentRepository})
    : _studentRepository = studentRepository;

  bool get isLoadingSl => _isLoadingSl;
  bool get isLoadingLeave => _isLoadingLeave;
  List<ShortLeaveRecord> get slRecords => _slRecords;
  List<LeaveRecord> get leaveRecords => _leaveRecords;
  String? get slError => _slError;
  String? get leaveError => _leaveError;
  int get currentTabIndex => _currentTabIndex;

  void setTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Future<void> loadHistory(String studentId) async {
    await Future.wait([
      _loadSlHistory(studentId),
      _loadLeaveHistory(studentId),
    ]);
  }

  Future<void> _loadSlHistory(String studentId) async {
    _isLoadingSl = true;
    _slError = null;
    notifyListeners();

    final result = await _studentRepository.fetchSlHistory(studentId);
    if (result.isSuccess) {
      _slRecords = result.data;
    } else {
      _slError = result.error;
    }

    _isLoadingSl = false;
    notifyListeners();
  }

  Future<void> _loadLeaveHistory(String studentId) async {
    _isLoadingLeave = true;
    _leaveError = null;
    notifyListeners();

    final result = await _studentRepository.fetchLeaveHistory(studentId);
    if (result.isSuccess) {
      _leaveRecords = result.data;
    } else {
      _leaveError = result.error;
    }

    _isLoadingLeave = false;
    notifyListeners();
  }

  Future<void> refresh(String studentId) => loadHistory(studentId);
}
