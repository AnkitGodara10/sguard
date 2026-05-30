// FILE: lib/viewmodels/warden/leave_requests_viewmodel.dart
//
// PURPOSE:
//   Drives the Leave Requests screen for wardens.
//   Handles the list of pending student leave requests,
//   and the approve/reject actions with notification triggering.

import 'package:flutter/foundation.dart';
import '../../core/repositories/warden_repository.dart';
import '../../core/services/notification_service.dart';
import '../../models/leave_record_model.dart';

enum LeaveRequestsState { initial, loading, loaded, error }

class LeaveRequestsViewModel extends ChangeNotifier {
  final WardenRepository _wardenRepository;
  final NotificationService _notificationService;

  LeaveRequestsState _state = LeaveRequestsState.initial;
  List<LeaveRequest> _requests = [];
  String? _errorMessage;
  String? _actionSuccess;
  final Set<String> _processingIds = {};

  LeaveRequestsViewModel({
    required WardenRepository wardenRepository,
    required NotificationService notificationService,
  }) : _wardenRepository = wardenRepository,
       _notificationService = notificationService;

  LeaveRequestsState get state => _state;
  List<LeaveRequest> get requests => List.unmodifiable(_requests);
  String? get errorMessage => _errorMessage;
  String? get actionSuccess => _actionSuccess;
  bool get isLoading => _state == LeaveRequestsState.loading;

  bool isProcessing(String requestId) => _processingIds.contains(requestId);

  Future<void> loadRequests(String wardenId) async {
    _state = LeaveRequestsState.loading;
    notifyListeners();

    final result = await _wardenRepository.fetchPendingRequests(wardenId);

    if (result.isSuccess) {
      _requests = result.data;
      _state = LeaveRequestsState.loaded;
    } else {
      _errorMessage = result.error;
      _state = LeaveRequestsState.error;
    }

    notifyListeners();
  }

  Future<void> approveRequest(String requestId, String studentName) async {
    _processingIds.add(requestId);
    _actionSuccess = null;
    notifyListeners();

    final result = await _wardenRepository.approveLeaveRequest(requestId);

    _processingIds.remove(requestId);

    if (result.isSuccess) {
      _requests.removeWhere((r) => r.id == requestId);
      _actionSuccess = 'Leave approved for $studentName';
      // Notify student (in production this would go via push notification)
      await _notificationService.notifyStudentLeaveApproved();
    } else {
      _errorMessage = result.error;
    }

    notifyListeners();
  }

  Future<void> rejectRequest(
    String requestId,
    String studentName,
    String reason,
  ) async {
    _processingIds.add(requestId);
    _actionSuccess = null;
    notifyListeners();

    final result = await _wardenRepository.rejectLeaveRequest(
      requestId,
      reason,
    );

    _processingIds.remove(requestId);

    if (result.isSuccess) {
      _requests.removeWhere((r) => r.id == requestId);
      _actionSuccess = 'Leave rejected for $studentName';
      await _notificationService.notifyStudentLeaveRejected(reason);
    } else {
      _errorMessage = result.error;
    }

    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _actionSuccess = null;
    notifyListeners();
  }
}
