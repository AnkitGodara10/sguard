// FILE: lib/models/scanner_model.dart
//
// PURPOSE:
//   Represents a gate scanner device in SGuard.
//   Only admin-registered scanners can scan QR codes.
//   Unregistered devices are rejected by the backend.
//
// SCANNER IDENTITY:
//   Each scanner has a unique device ID issued when admin registers it.
//   When a scanner calls the backend's /scanner/scan endpoint, it must
//   include its device ID and a scanner token for authentication.

enum ScanResult {
  success, // Valid QR, exit or entry recorded
  failure, // QR exists but conditions not met (e.g. too soon for return)
  invalid, // QR not in database or signature invalid
  expired, // QR time limit exceeded
  unauthorized; // Scanner not registered

  bool get isSuccess => this == ScanResult.success;
  String get displayMessage {
    switch (this) {
      case ScanResult.success:
        return 'Scan Successful';
      case ScanResult.failure:
        return 'Scan Failed';
      case ScanResult.invalid:
        return 'Invalid QR Code';
      case ScanResult.expired:
        return 'QR Code Expired';
      case ScanResult.unauthorized:
        return 'Unauthorized Scanner';
    }
  }
}

class ScannerModel {
  final String id;
  final String name;
  final String location;
  final String deviceId; // Unique hardware ID
  final String status; // 'active' or 'inactive'
  final DateTime registeredAt;
  final DateTime? lastActiveAt;

  const ScannerModel({
    required this.id,
    required this.name,
    required this.location,
    required this.deviceId,
    required this.status,
    required this.registeredAt,
    this.lastActiveAt,
  });

  bool get isActive => status == 'active';

  factory ScannerModel.fromJson(Map<String, dynamic> json) {
    return ScannerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      deviceId: json['device_id'] as String,
      status: json['status'] as String,
      registeredAt: DateTime.parse(json['registered_at'] as String),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'device_id': deviceId,
      'status': status,
      'registered_at': registeredAt.toIso8601String(),
      if (lastActiveAt != null)
        'last_active_at': lastActiveAt!.toIso8601String(),
    };
  }
}

// ── Scan Event (what the backend returns after a scan) ────────────────────────

class ScanEvent {
  final String id;
  final String scannerId;
  final String qrId;
  final ScanResult result;
  final String? studentName;
  final String? hostelNumber;
  final String? roomNumber;
  final String leaveType;
  final bool isExit; // true = first scan (exit), false = second scan (entry)
  final DateTime scannedAt;

  const ScanEvent({
    required this.id,
    required this.scannerId,
    required this.qrId,
    required this.result,
    this.studentName,
    this.hostelNumber,
    this.roomNumber,
    required this.leaveType,
    required this.isExit,
    required this.scannedAt,
  });

  factory ScanEvent.fromJson(Map<String, dynamic> json) {
    return ScanEvent(
      id: json['id'] as String,
      scannerId: json['scanner_id'] as String,
      qrId: json['qr_id'] as String,
      result: ScanResult.values.firstWhere(
        (r) => r.name == json['result'],
        orElse: () => ScanResult.failure,
      ),
      studentName: json['student_name'] as String?,
      hostelNumber: json['hostel_number'] as String?,
      roomNumber: json['room_number'] as String?,
      leaveType: json['leave_type'] as String,
      isExit: json['is_exit'] as bool,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
    );
  }
}
