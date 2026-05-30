// FILE: lib/viewmodels/warden/warden_own_leave_viewmodel.dart
//
// PURPOSE:
//   Drives the Warden's own leave management screen.
//   Wardens have the same SL flow as students, and their Leave (L) request
//   goes to the Admin (not another warden).

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/repositories/warden_repository.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/qr_model.dart';
import '../../models/leave_record_model.dart';

enum WardenLeaveScreenState { initial, loading, loaded, error }

class WardenOwnLeaveViewModel extends ChangeNotifier {
  final WardenRepository _wardenRepository;

  WardenLeaveScreenState _state = WardenLeaveScreenState.initial;
  QrModel? _activeSlQr;
  LeaveRecord? _activeLeave;
  String? _errorMessage;
  String? _successMessage;
  Duration _slRemainingTime = Duration.zero;
  Timer? _slTimer;

  WardenOwnLeaveViewModel({required WardenRepository wardenRepository})
    : _wardenRepository = wardenRepository;

  WardenLeaveScreenState get state => _state;
  QrModel? get activeSlQr => _activeSlQr;
  LeaveRecord? get activeLeave => _activeLeave;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Duration get slRemainingTime => _slRemainingTime;
  String get formattedSlCountdown =>
      DateFormatter.countdownTimer(_slRemainingTime);

  bool get hasActiveSl =>
      _activeSlQr != null && _activeSlQr!.status == AppConstants.qrStatusActive;
  bool get hasActiveLeave =>
      _activeLeave != null &&
      (_activeLeave!.isPending ||
          _activeLeave!.isApproved ||
          _activeLeave!.isActive);

  Future<void> generateSlQr(String wardenId, String reason) async {
    _state = WardenLeaveScreenState.loading;
    notifyListeners();

    final result = await _wardenRepository.generateWardenSlQr(wardenId, reason);

    if (result.isSuccess) {
      _activeSlQr = result.data;
      _startSlTimer(_activeSlQr!);
      _state = WardenLeaveScreenState.loaded;
    } else {
      _errorMessage = result.error;
      _state = WardenLeaveScreenState.error;
    }

    notifyListeners();
  }

  Future<bool> requestLeave(String wardenId, String reason) async {
    _state = WardenLeaveScreenState.loading;
    notifyListeners();

    final result = await _wardenRepository.requestWardenLeave(
      wardenId: wardenId,
      reason: reason,
    );

    if (result.isSuccess) {
      _activeLeave = result.data;
      _successMessage = 'Leave request sent to Admin';
      _state = WardenLeaveScreenState.loaded;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      _state = WardenLeaveScreenState.error;
      notifyListeners();
      return false;
    }
  }

  void _startSlTimer(QrModel qr) {
    _slTimer?.cancel();
    final validity = Duration(minutes: AppConstants.slQrValidityMinutes);

    _slTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _slRemainingTime = DateFormatter.qrRemainingTime(qr.createdAt, validity);
      if (_slRemainingTime == Duration.zero) {
        _slTimer?.cancel();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _slTimer?.cancel();
    super.dispose();
  }
}
