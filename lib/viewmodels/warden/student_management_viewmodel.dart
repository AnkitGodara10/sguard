// FILE: lib/viewmodels/warden/student_management_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../core/repositories/warden_repository.dart';
import '../../models/student_model.dart';
import '../../models/leave_record_model.dart';

class StudentManagementViewModel extends ChangeNotifier {
  final WardenRepository _wardenRepository;

  bool _isLoading = false;
  List<StudentModel> _students = [];
  StudentModel? _selectedStudent;
  List<ShortLeaveRecord> _selectedStudentSlRecords = [];
  List<LeaveRecord> _selectedStudentLeaveRecords = [];
  String? _errorMessage;
  String? _successMessage;
  String _searchQuery = '';

  StudentManagementViewModel({required WardenRepository wardenRepository})
    : _wardenRepository = wardenRepository;

  bool get isLoading => _isLoading;
  StudentModel? get selectedStudent => _selectedStudent;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get searchQuery => _searchQuery;
  List<ShortLeaveRecord> get selectedStudentSlRecords =>
      _selectedStudentSlRecords;
  List<LeaveRecord> get selectedStudentLeaveRecords =>
      _selectedStudentLeaveRecords;

  List<StudentModel> get filteredStudents {
    if (_searchQuery.isEmpty) return List.unmodifiable(_students);
    final q = _searchQuery.toLowerCase();
    return _students
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.roomNumber.toLowerCase().contains(q) ||
              s.hostelNumber.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> loadStudents(String wardenId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _wardenRepository.fetchHostelStudents(wardenId);
    if (result.isSuccess) {
      _students = result.data;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectStudent(StudentModel student) {
    _selectedStudent = student;
    notifyListeners();
  }

  Future<void> loadStudentRecords(String studentId) async {
    final results = await Future.wait([
      _wardenRepository.fetchStudentSlRecords(studentId),
      _wardenRepository.fetchStudentLeaveRecords(studentId),
    ]);

    if ((results[0] as dynamic).isSuccess) {
      _selectedStudentSlRecords =
          (results[0] as dynamic).data as List<ShortLeaveRecord>;
    }
    if ((results[1] as dynamic).isSuccess) {
      _selectedStudentLeaveRecords =
          (results[1] as dynamic).data as List<LeaveRecord>;
    }
    notifyListeners();
  }

  Future<bool> updateStudentHostelRoom(
    String studentId, {
    String? hostelNumber,
    String? roomNumber,
  }) async {
    _errorMessage = null;
    _successMessage = null;

    final result = await _wardenRepository.updateStudentHostelRoom(
      studentId,
      hostelNumber: hostelNumber,
      roomNumber: roomNumber,
    );

    if (result.isSuccess) {
      final updated = result.data;
      final idx = _students.indexWhere((s) => s.id == studentId);
      if (idx != -1) _students[idx] = updated;
      if (_selectedStudent?.id == studentId) _selectedStudent = updated;
      _successMessage = 'Student details updated';
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
