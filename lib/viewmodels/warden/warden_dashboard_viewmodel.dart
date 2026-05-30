// FILE: lib/viewmodels/warden/warden_dashboard_viewmodel.dart
//
// PURPOSE:
//   Drives the Warden Dashboard screen.
//   Shows summary stats: pending requests count, students currently out.

import 'package:flutter/foundation.dart';
import '../../core/repositories/warden_repository.dart';
import '../../models/warden_model.dart';
import '../../models/leave_record_model.dart';
import '../../models/student_model.dart';

class WardenDashboardViewModel extends ChangeNotifier {
  final WardenRepository _wardenRepository;

  bool _isLoading = false;
  WardenModel? _warden;
  int _pendingRequestsCount = 0;
  final int _studentsOutCount = 0;
  int _totalStudentsCount = 0;
  String? _errorMessage;

  WardenDashboardViewModel({required WardenRepository wardenRepository})
    : _wardenRepository = wardenRepository;

  bool get isLoading => _isLoading;
  WardenModel? get warden => _warden;
  int get pendingRequestsCount => _pendingRequestsCount;
  int get studentsOutCount => _studentsOutCount;
  int get totalStudentsCount => _totalStudentsCount;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard(String wardenId) async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _wardenRepository.fetchProfile(wardenId),
      _wardenRepository.fetchPendingRequests(wardenId),
      _wardenRepository.fetchHostelStudents(wardenId),
    ]);

    final profileResult = results[0] as dynamic;
    final requestsResult = results[1] as dynamic;
    final studentsResult = results[2] as dynamic;

    if (profileResult.isSuccess) _warden = profileResult.data as WardenModel;
    if (requestsResult.isSuccess) {
      _pendingRequestsCount =
          (requestsResult.data as List<LeaveRequest>).length;
    }
    if (studentsResult.isSuccess) {
      final students = studentsResult.data as List<StudentModel>;
      _totalStudentsCount = students.length;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh(String wardenId) => loadDashboard(wardenId);
}
