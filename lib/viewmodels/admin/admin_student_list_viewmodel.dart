// FILE: lib/viewmodels/admin/admin_student_list_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../core/repositories/admin_repository.dart';
import '../../models/student_model.dart';

class AdminStudentListViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;

  bool _isLoading = false;
  bool _isAdding = false;
  List<StudentMasterRecord> _students = [];
  String? _errorMessage;
  String? _successMessage;
  String _searchQuery = '';

  AdminStudentListViewModel({required AdminRepository adminRepository})
    : _adminRepository = adminRepository;

  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<StudentMasterRecord> get filteredStudents {
    if (_searchQuery.isEmpty) return List.unmodifiable(_students);
    final q = _searchQuery.toLowerCase();
    return _students
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.rollNumber.toLowerCase().contains(q),
        )
        .toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();

    final result = await _adminRepository.fetchStudentMasterList();
    if (result.isSuccess) {
      _students = result.data;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addStudent({
    required String rollNumber,
    required String name,
    required String year,
    required String fathersName,
    required String fathersPhone,
  }) async {
    _isAdding = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _adminRepository.addStudentToMasterList(
      rollNumber: rollNumber,
      name: name,
      year: year,
      fathersName: fathersName,
      fathersPhone: fathersPhone,
    );

    if (result.isSuccess) {
      _students.add(result.data);
      _successMessage = 'Student added successfully';
      _isAdding = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      _isAdding = false;
      notifyListeners();
      return false;
    }
  }
}
