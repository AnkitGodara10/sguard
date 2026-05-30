// FILE: lib/viewmodels/admin/admin_dashboard_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../core/repositories/admin_repository.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;

  bool _isLoading = false;
  int _totalStudents = 0;
  int _totalWardens = 0;
  int _totalScanners = 0;
  int _pendingWardenLeaves = 0;
  String? _errorMessage;

  AdminDashboardViewModel({required AdminRepository adminRepository})
    : _adminRepository = adminRepository;

  bool get isLoading => _isLoading;
  int get totalStudents => _totalStudents;
  int get totalWardens => _totalWardens;
  int get totalScanners => _totalScanners;
  int get pendingWardenLeaves => _pendingWardenLeaves;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _adminRepository.fetchStudentMasterList(),
      _adminRepository.fetchWardenMasterList(),
      _adminRepository.fetchScanners(),
      _adminRepository.fetchWardenLeaveRequests(),
    ]);

    if ((results[0] as dynamic).isSuccess) {
      _totalStudents = ((results[0] as dynamic).data as List).length;
    }
    if ((results[1] as dynamic).isSuccess) {
      _totalWardens = ((results[1] as dynamic).data as List).length;
    }
    if ((results[2] as dynamic).isSuccess) {
      _totalScanners = ((results[2] as dynamic).data as List).length;
    }
    if ((results[3] as dynamic).isSuccess) {
      _pendingWardenLeaves = ((results[3] as dynamic).data as List).length;
    }

    _isLoading = false;
    notifyListeners();
  }
}
