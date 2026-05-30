// FILE: lib/viewmodels/admin/admin_warden_list_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../core/repositories/admin_repository.dart';
import '../../models/warden_model.dart';

class AdminWardenListViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;
  bool _isLoading = false;
  bool _isAdding = false;
  List<WardenMasterRecord> _wardens = [];
  String? _errorMessage;
  String? _successMessage;
  String _searchQuery = '';

  AdminWardenListViewModel({required AdminRepository adminRepository})
    : _adminRepository = adminRepository;

  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<WardenMasterRecord> get filteredWardens {
    if (_searchQuery.isEmpty) return List.unmodifiable(_wardens);
    final q = _searchQuery.toLowerCase();
    return _wardens
        .where(
          (w) =>
              w.name.toLowerCase().contains(q) ||
              w.wardenId.toLowerCase().contains(q) ||
              w.hostel.toLowerCase().contains(q),
        )
        .toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadWardens() async {
    _isLoading = true;
    notifyListeners();

    final result = await _adminRepository.fetchWardenMasterList();
    if (result.isSuccess) {
      _wardens = result.data;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addWarden({
    required String wardenId,
    required String name,
    required String hostel,
    required String phone,
  }) async {
    _isAdding = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _adminRepository.addWardenToMasterList(
      wardenId: wardenId,
      name: name,
      hostel: hostel,
      phone: phone,
    );

    if (result.isSuccess) {
      _wardens.add(result.data);
      _successMessage = 'Warden added successfully';
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
