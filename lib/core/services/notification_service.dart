// FILE: lib/core/services/notification_service.dart
//
// PURPOSE:
//   Manages local notifications for SGuard.
//   Used for:
//     - Notifying wardens when a student submits a leave request
//     - Notifying students when their leave is approved/rejected
//     - QR expiry warnings
//     - Warden notification when student returns from leave
//
// FUTURE:
//   When push notifications (FCM/APNS) are added for the backend,
//   this service will also handle push notification registration
//   and message handling. The interface stays the same.
//
// NOTE:
//   This is a service (not a repository) because it interacts with
//   device hardware/OS, not with a data source.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'sguard_channel',
    'SGuard Notifications',
    description: 'Leave requests, approvals, and alerts',
    importance: Importance.high,
  );

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // Create notification channel (Android 8.0+)
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  // ── Leave Request Notifications ───────────────────────────────────────────

  Future<void> notifyWardenNewRequest(String studentName, String reason) async {
    await _show(
      id: 1001,
      title: 'New Leave Request',
      body: '$studentName has requested leave: $reason',
      channel: _androidChannel.id,
    );
  }

  Future<void> notifyStudentLeaveApproved() async {
    await _show(
      id: 1002,
      title: 'Leave Approved ✓',
      body: 'Your leave request has been approved. QR code generated.',
      channel: _androidChannel.id,
    );
  }

  Future<void> notifyStudentLeaveRejected(String reason) async {
    await _show(
      id: 1003,
      title: 'Leave Rejected',
      body: 'Your leave request was rejected. Reason: $reason',
      channel: _androidChannel.id,
    );
  }

  Future<void> notifyWardenStudentReturned(String studentName) async {
    await _show(
      id: 1004,
      title: 'Student Returned',
      body: '$studentName has returned to campus.',
      channel: _androidChannel.id,
    );
  }

  Future<void> notifyQrExpiringSoon(int minutesLeft) async {
    await _show(
      id: 1005,
      title: 'QR Code Expiring',
      body: 'Your QR code expires in $minutesLeft minutes.',
      channel: _androidChannel.id,
    );
  }

  // ── Private Helper ────────────────────────────────────────────────────────

  Future<void> _show({
    required int id,
    required String title,
    required String body,
    required String channel,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channel,
      _androidChannel.name,
      importance: Importance.high,
      priority: Priority.high,
    );

    final notifDetails = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, notifDetails);
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
