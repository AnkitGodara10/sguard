// FILE: lib/viewmodels/student/student_dashboard_viewmodel.dart
//
// PURPOSE:
//   Drives the Student Dashboard screen.
//   Fetches and holds the student's current status:
//     - Profile information
//     - Whether there's an active SL QR
//     - Whether there's an active/pending Leave
//     - Summary counts for quick stats
//
// HOW THE VIEW USES THIS:
//   The view reads properties from this ViewModel and calls its methods.
//   The ViewModel handles all data fetching, state transitions, and
//   business logic. The view only renders what the ViewModel exposes.

import 'package:flutter/foundation.dart';

import '../../core/repositories/student_repository.dart';
import '../../models/student_model.dart';
import '../../models/qr_model.dart';
import '../../models/leave_record_model.dart';

enum DashboardState { initial, loading, loaded, error }

class StudentDashboardViewModel extends ChangeNotifier {
  final StudentRepository _studentRepository;

  DashboardState _state = DashboardState.initial;
  StudentModel? _student;
  QrModel? _activeSlQr;
  LeaveRecord? _activeLeave;
  String? _errorMessage;

  StudentDashboardViewModel({required StudentRepository studentRepository})
    : _studentRepository = studentRepository;

  // ── Getters ───────────────────────────────────────────────────────────────

  DashboardState get state => _state;
  StudentModel? get student => _student;
  QrModel? get activeSlQr => _activeSlQr;
  LeaveRecord? get activeLeave => _activeLeave;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == DashboardState.loading;
  bool get hasError => _state == DashboardState.error;

  bool get hasActiveSlQr => _activeSlQr != null && _activeSlQr!.isActive;
  bool get isCurrentlyOut =>
      (_activeSlQr != null && _activeSlQr!.hasBeenScannedOnce) ||
      (_activeLeave != null && _activeLeave!.isActive);

  String get statusLabel {
    if (isCurrentlyOut) return 'Currently Out';
    if (activeLeave != null && activeLeave!.isPending) return 'Leave Pending';
    return 'On Campus';
  }

  // ── Load Dashboard ────────────────────────────────────────────────────────

  Future<void> loadDashboard(String studentId) async {
    _state = DashboardState.loading;
    notifyListeners();

    // Fetch profile, active SL QR, and active leave concurrently
    final results = await Future.wait([
      _studentRepository.fetchProfile(studentId),
      _studentRepository.getActiveSlQr(studentId),
      _studentRepository.getActiveLeave(studentId),
    ]);

    final profileResult = results[0] as dynamic;
    final slQrResult = results[1] as dynamic;
    final leaveResult = results[2] as dynamic;

    if (profileResult.isFailure) {
      _errorMessage = profileResult.error;
      _state = DashboardState.error;
      notifyListeners();
      return;
    }

    _student = profileResult.data as StudentModel;
    if (slQrResult.isSuccess) _activeSlQr = slQrResult.data as QrModel?;
    if (leaveResult.isSuccess) _activeLeave = leaveResult.data as LeaveRecord?;

    _state = DashboardState.loaded;
    notifyListeners();
  }

  Future<void> refresh(String studentId) => loadDashboard(studentId);
}
