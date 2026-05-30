// FILE: lib/viewmodels/student/generate_sl_qr_viewmodel.dart
//
// PURPOSE:
//   Drives the Short Leave QR generation screen.
//   This is one of the most complex ViewModels because it handles:
//     1. Generating the QR code via the repository
//     2. Running a countdown timer (30 minutes from generation)
//     3. Pausing/stopping the timer after first scan
//     4. Showing appropriate status messages based on scan count
//     5. Handling QR expiry and regeneration
//
// TIMER LOGIC (matches spec):
//   - QR generated → 30-minute countdown begins
//   - First scan (exit) → countdown STOPS (QR doesn't expire after exit)
//   - Minimum 5 minutes must pass before second scan is allowed
//   - After second scan → QR is fully used
//   - If timer reaches 0 before first scan → QR is expired, must regenerate
//
// WHY TIMER IS IN VIEWMODEL:
//   The countdown timer is pure business logic (not display logic).
//   The view only reads the remaining time and displays it.
//   All timer lifecycle (start, stop, dispose) is managed here.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/repositories/student_repository.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/qr_model.dart';

enum QrScreenState {
  initial,
  loading,
  readyToGenerate, // No active QR
  active, // QR generated, waiting for first scan
  scanning, // First scan done (student is out)
  used, // Second scan done (student returned)
  expired, // Time ran out before first scan
  error,
}

class GenerateSlQrViewModel extends ChangeNotifier {
  final StudentRepository _studentRepository;

  QrScreenState _state = QrScreenState.initial;
  QrModel? _qrCode;
  String? _errorMessage;
  Duration _remainingTime = Duration.zero;
  Timer? _countdownTimer;
  bool _canRegenerateAfterExpiry = false;

  GenerateSlQrViewModel({required StudentRepository studentRepository})
    : _studentRepository = studentRepository;

  // ── Getters ───────────────────────────────────────────────────────────────

  QrScreenState get state => _state;
  QrModel? get qrCode => _qrCode;
  String? get errorMessage => _errorMessage;
  Duration get remainingTime => _remainingTime;
  bool get canRegenerate => _canRegenerateAfterExpiry;

  bool get isLoading => _state == QrScreenState.loading;
  bool get isActive => _state == QrScreenState.active;
  bool get isScanning => _state == QrScreenState.scanning;
  bool get isUsed => _state == QrScreenState.used;
  bool get isExpired => _state == QrScreenState.expired;

  /// Formatted countdown for display: "27:43"
  String get formattedCountdown => DateFormatter.countdownTimer(_remainingTime);

  /// Message shown below the QR code
  String get statusMessage {
    switch (_state) {
      case QrScreenState.active:
        return AppStrings.qrSubtitle;
      case QrScreenState.scanning:
        return AppStrings.qrScannedOnce;
      case QrScreenState.used:
        return AppStrings.qrScannedTwice;
      case QrScreenState.expired:
        return AppStrings.qrExpiredMessage;
      default:
        return '';
    }
  }

  // ── Load (check for existing QR) ──────────────────────────────────────────

  Future<void> loadScreen(String studentId) async {
    _state = QrScreenState.loading;
    notifyListeners();

    final result = await _studentRepository.getActiveSlQr(studentId);

    if (result.isFailure) {
      _errorMessage = result.error;
      _state = QrScreenState.error;
      notifyListeners();
      return;
    }

    final qr = result.data;

    if (qr == null) {
      _state = QrScreenState.readyToGenerate;
    } else {
      _qrCode = qr;
      _applyQrState(qr);
    }

    notifyListeners();
  }

  // ── Generate QR ───────────────────────────────────────────────────────────

  Future<void> generateQr(String studentId, String reason) async {
    _state = QrScreenState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _studentRepository.generateSlQr(studentId, reason);

    if (result.isFailure) {
      _errorMessage = result.error;
      _state = QrScreenState.error;
      notifyListeners();
      return;
    }

    _qrCode = result.data;
    _applyQrState(_qrCode!);
    notifyListeners();
  }

  // ── Apply QR State & Start Timer ──────────────────────────────────────────

  void _applyQrState(QrModel qr) {
    _cancelTimer();

    if (qr.isFullyUsed) {
      _state = QrScreenState.used;
      return;
    }

    if (qr.isExpired) {
      _state = QrScreenState.expired;
      _canRegenerateAfterExpiry = true;
      return;
    }

    // After first scan, QR is in "scanning" state — no timer needed
    if (qr.status == AppConstants.qrStatusScanning) {
      _state = QrScreenState.scanning;
      // Show how long they've been out
      return;
    }

    // QR is active — start countdown
    _state = QrScreenState.active;
    _startCountdownTimer(qr);
  }

  void _startCountdownTimer(QrModel qr) {
    final validity = Duration(minutes: AppConstants.slQrValidityMinutes);
    _remainingTime = DateFormatter.qrRemainingTime(qr.createdAt, validity);

    if (_remainingTime == Duration.zero) {
      _state = QrScreenState.expired;
      _canRegenerateAfterExpiry = true;
      notifyListeners();
      return;
    }

    // Tick every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingTime = DateFormatter.qrRemainingTime(qr.createdAt, validity);

      if (_remainingTime == Duration.zero) {
        _state = QrScreenState.expired;
        _canRegenerateAfterExpiry = true;
        _cancelTimer();
      }

      notifyListeners();
    });
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}

// Moved constant here to avoid import cycle — matches AppStrings
class AppStrings {
  static const String qrSubtitle = 'Show this to the gate scanner';
  static const String qrScannedOnce = 'Exit recorded. Show this on return.';
  static const String qrScannedTwice =
      'Entry recorded. You are back on campus.';
  static const String qrExpiredMessage =
      'This QR code has expired. Please generate a new one.';
}
