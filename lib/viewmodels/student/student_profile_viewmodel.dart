// FILE: lib/viewmodels/student/student_profile_viewmodel.dart
//
// PURPOSE:
//   Drives the Student Profile screen.
//   Students can edit: phone, email, father's phone.
//   All other fields are read-only from the student's perspective.

import 'package:flutter/foundation.dart';

import '../../core/repositories/student_repository.dart';
import '../../models/student_model.dart';

enum ProfileState { initial, loading, loaded, updating, updated, error }

class StudentProfileViewModel extends ChangeNotifier {
  final StudentRepository _studentRepository;

  ProfileState _state = ProfileState.initial;
  StudentModel? _student;
  String? _errorMessage;
  String? _successMessage;

  StudentProfileViewModel({required StudentRepository studentRepository})
    : _studentRepository = studentRepository;

  ProfileState get state => _state;
  StudentModel? get student => _student;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _state == ProfileState.loading;
  bool get isUpdating => _state == ProfileState.updating;

  Future<void> loadProfile(String studentId) async {
    _state = ProfileState.loading;
    notifyListeners();

    final result = await _studentRepository.fetchProfile(studentId);
    if (result.isSuccess) {
      _student = result.data;
      _state = ProfileState.loaded;
    } else {
      _errorMessage = result.error;
      _state = ProfileState.error;
    }
    notifyListeners();
  }

  Future<bool> updateProfile(
    String studentId, {
    String? phone,
    String? email,
    String? fathersPhone,
  }) async {
    _state = ProfileState.updating;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _studentRepository.updateProfile(
      studentId,
      phone: phone,
      email: email,
      fathersPhone: fathersPhone,
    );

    if (result.isSuccess) {
      _student = result.data;
      _successMessage = 'Profile updated successfully';
      _state = ProfileState.updated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      _state = ProfileState.error;
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
