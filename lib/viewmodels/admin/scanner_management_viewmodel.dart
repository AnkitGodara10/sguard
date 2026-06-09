// FILE: lib/viewmodels/admin/scanner_management_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../core/repositories/admin_repository.dart';
import '../../models/scanner_model.dart';

class ScannerManagementViewModel extends ChangeNotifier {
  final AdminRepository _adminRepository;
  bool _isLoading = false;
  bool _isRegistering = false;
  List<ScannerModel> _scanners = [];
  String? _errorMessage;
  String? _successMessage;

  ScannerManagementViewModel({required AdminRepository adminRepository})
    : _adminRepository = adminRepository;

  bool get isLoading => _isLoading;
  bool get isRegistering => _isRegistering;
  List<ScannerModel> get scanners => List.unmodifiable(_scanners);
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  int get activeScannerCount => _scanners.where((s) => s.isActive).length;

  Future<void> loadScanners() async {
    _isLoading = true;
    notifyListeners();

    final result = await _adminRepository.fetchScanners();
    if (result.isSuccess) {
      _scanners = result.data;
    } else {
      _errorMessage = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> registerScanner({
    required String name,
    required String location,
    required String deviceId,
  }) async {
    _isRegistering = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _adminRepository.registerScanner(
      name: name,
      location: location,
      deviceId: deviceId,
    );

    if (result.isSuccess) {
      _scanners.add(result.data);
      _successMessage = 'Scanner registered successfully';
      _isRegistering = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      _isRegistering = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deactivateScanner(String scannerId) async {
    final result = await _adminRepository.deactivateScanner(scannerId);
    if (result.isSuccess) {
      final idx = _scanners.indexWhere((s) => s.id == scannerId);
      if (idx != -1) {
        // Update in-memory model
        final s = _scanners[idx];
        _scanners[idx] = ScannerModel(
          id: s.id,
          name: s.name,
          location: s.location,
          deviceId: s.deviceId,
          status: 'inactive',
          registeredAt: s.registeredAt,
          lastActiveAt: s.lastActiveAt,
        );
        _successMessage = 'Scanner deactivated';
        notifyListeners();
      }
    } else {
      _errorMessage = result.error;
      notifyListeners();
    }
  }
}
