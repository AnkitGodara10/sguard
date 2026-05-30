// FILE: lib/viewmodels/admin/admin_reports_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../core/repositories/admin_repository.dart';
import '../../models/leave_record_model.dart';

class AdminReportsViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;

  bool _isLoading = false;
  List<ShortLeaveRecord> _slRecords = [];
  List<LeaveRecord> _leaveRecords = [];
  String? _errorMessage;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _hostelFilter;
  int _currentTabIndex = 0; // 0=SL, 1=Leave

  AdminReportsViewModel({required AdminRepository adminRepository})
    : _adminRepository = adminRepository;

  bool get isLoading => _isLoading;
  List<ShortLeaveRecord> get slRecords => List.unmodifiable(_slRecords);
  List<LeaveRecord> get leaveRecords => List.unmodifiable(_leaveRecords);
  String? get errorMessage => _errorMessage;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String? get hostelFilter => _hostelFilter;
  int get currentTabIndex => _currentTabIndex;

  void setTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    notifyListeners();
  }

  void setHostelFilter(String? hostel) {
    _hostelFilter = hostel;
    notifyListeners();
  }

  Future<void> loadReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final results = await Future.wait([
      _adminRepository.fetchAllSlRecords(
        from: _fromDate,
        to: _toDate,
        hostelNumber: _hostelFilter,
      ),
      _adminRepository.fetchAllLeaveRecords(
        from: _fromDate,
        to: _toDate,
        hostelNumber: _hostelFilter,
      ),
    ]);

    if ((results[0] as dynamic).isSuccess) {
      _slRecords = (results[0] as dynamic).data as List<ShortLeaveRecord>;
    } else {
      _errorMessage = (results[0] as dynamic).error as String;
    }

    if ((results[1] as dynamic).isSuccess) {
      _leaveRecords = (results[1] as dynamic).data as List<LeaveRecord>;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> applyFiltersAndReload() => loadReports();
}
