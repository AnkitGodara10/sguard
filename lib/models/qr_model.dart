// FILE: lib/models/qr_model.dart
//
// PURPOSE:
//   Represents a QR code in SGuard.
//   QR codes are the central mechanism for gate entry/exit verification.
//   This model tracks:
//     - The QR payload (what the scanner reads)
//     - The leave type (SL or L)
//     - Creation time and expiry
//     - How many times it's been scanned
//     - Whether it's valid, expired, or fully used
//
// QR LIFECYCLE:
//   1. generated → scanCount = 0, status = active
//   2. first scan → scanCount = 1, status = scanning, exitTime recorded
//      (for SL: expiry countdown pauses here)
//   3. second scan → scanCount = 2, status = used, entryTime recorded
//
// PAYLOAD FORMAT:
//   The QR payload is a JWT-signed string from the backend.
//   It contains: userId, leaveType, leaveId, issuedAt, expiry.
//   The scanner validates the signature — fake QRs fail.

import '../core/constants/app_constants.dart';

class QrModel {
  final String id;
  final String userId;
  final String leaveType; // AppConstants.leaveTypeSl or leaveTypeL
  final String leaveId; // References the associated leave record
  final String payload; // The actual QR code string (signed JWT)
  final DateTime createdAt;
  final DateTime expiresAt; // Calculated at generation time
  final int scanCount; // 0, 1, or 2
  final String status; // active, scanning, used, expired
  final DateTime? firstScanAt; // Time of exit scan
  final DateTime? secondScanAt; // Time of return scan

  const QrModel({
    required this.id,
    required this.userId,
    required this.leaveType,
    required this.leaveId,
    required this.payload,
    required this.createdAt,
    required this.expiresAt,
    required this.scanCount,
    required this.status,
    this.firstScanAt,
    this.secondScanAt,
  });

  // ── Computed Properties ───────────────────────────────────────────────────

  bool get isExpired {
    if (status == AppConstants.qrStatusUsed) return false;
    // After first scan, expiry stops for the QR itself
    // (the leave record still has its own constraints)
    if (status == AppConstants.qrStatusScanning) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  bool get isActive => status == AppConstants.qrStatusActive && !isExpired;

  bool get hasBeenScannedOnce => scanCount >= 1;

  bool get isFullyUsed => scanCount >= AppConstants.qrMaxScans;

  /// Remaining time until QR expires (only relevant for status=active)
  Duration get remainingTime {
    if (isExpired || isFullyUsed) return Duration.zero;
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // ── Deserialization ───────────────────────────────────────────────────────

  factory QrModel.fromJson(Map<String, dynamic> json) {
    return QrModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      leaveType: json['leave_type'] as String,
      leaveId: json['leave_id'] as String,
      payload: json['payload'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      scanCount: json['scan_count'] as int,
      status: json['status'] as String,
      firstScanAt: json['first_scan_at'] != null
          ? DateTime.parse(json['first_scan_at'] as String)
          : null,
      secondScanAt: json['second_scan_at'] != null
          ? DateTime.parse(json['second_scan_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'leave_type': leaveType,
      'leave_id': leaveId,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'scan_count': scanCount,
      'status': status,
      if (firstScanAt != null) 'first_scan_at': firstScanAt!.toIso8601String(),
      if (secondScanAt != null)
        'second_scan_at': secondScanAt!.toIso8601String(),
    };
  }

  QrModel copyWith({
    String? id,
    String? userId,
    String? leaveType,
    String? leaveId,
    String? payload,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? scanCount,
    String? status,
    DateTime? firstScanAt,
    DateTime? secondScanAt,
  }) {
    return QrModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      leaveType: leaveType ?? this.leaveType,
      leaveId: leaveId ?? this.leaveId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      scanCount: scanCount ?? this.scanCount,
      status: status ?? this.status,
      firstScanAt: firstScanAt ?? this.firstScanAt,
      secondScanAt: secondScanAt ?? this.secondScanAt,
    );
  }
}
