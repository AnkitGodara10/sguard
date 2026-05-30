// FILE: lib/models/leave_record_model.dart
//
// PURPOSE:
//   Represents the leave records created when QR codes are scanned at the gate.
//   There are two types of leave records: Short Leave (SL) and Leave (L).
//   They share similar fields but have different time semantics.
//
// RECORD CREATION:
//   - A leave record is created BEFORE the QR is generated (for Leave type)
//     or at generation time (for Short Leave)
//   - timeOut is populated on first scan
//   - timeIn is populated on second scan
//
// TWO CLASSES:
//   ShortLeaveRecord — SL, resets daily serial numbers, date-within-day
//   LeaveRecord — L, resets weekly serial numbers, cross-day timestamps

// ── Short Leave Record ────────────────────────────────────────────────────────

class ShortLeaveRecord {
  final String id;
  final int serialNumber; // Resets daily
  final DateTime date;
  final String studentId;
  final String studentName;
  final String hostelNumber;
  final String roomNumber;
  final String phone;
  final String reason;
  final DateTime? timeOut; // Populated on first gate scan
  final DateTime? timeIn; // Populated on second gate scan
  final String status; // pending_exit, out, completed, expired

  const ShortLeaveRecord({
    required this.id,
    required this.serialNumber,
    required this.date,
    required this.studentId,
    required this.studentName,
    required this.hostelNumber,
    required this.roomNumber,
    required this.phone,
    required this.reason,
    this.timeOut,
    this.timeIn,
    required this.status,
  });

  bool get hasExited => timeOut != null;
  bool get hasReturned => timeIn != null;

  factory ShortLeaveRecord.fromJson(Map<String, dynamic> json) {
    return ShortLeaveRecord(
      id: json['id'] as String,
      serialNumber: json['serial_number'] as int,
      date: DateTime.parse(json['date'] as String),
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String,
      hostelNumber: json['hostel_number'] as String,
      roomNumber: json['room_number'] as String,
      phone: json['phone'] as String,
      reason: json['reason'] as String,
      timeOut: json['time_out'] != null
          ? DateTime.parse(json['time_out'] as String)
          : null,
      timeIn: json['time_in'] != null
          ? DateTime.parse(json['time_in'] as String)
          : null,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial_number': serialNumber,
      'date': date.toIso8601String(),
      'student_id': studentId,
      'student_name': studentName,
      'hostel_number': hostelNumber,
      'room_number': roomNumber,
      'phone': phone,
      'reason': reason,
      if (timeOut != null) 'time_out': timeOut!.toIso8601String(),
      if (timeIn != null) 'time_in': timeIn!.toIso8601String(),
      'status': status,
    };
  }
}

// ── Leave Record (L) ──────────────────────────────────────────────────────────

class LeaveRecord {
  final String id;
  final int serialNumber; // Resets weekly
  final String studentId;
  final String studentName;
  final String hostelNumber;
  final String roomNumber;
  final String phone;
  final String reason;
  final DateTime? dateOut; // Populated on first gate scan
  final DateTime? timeOut; // Populated on first gate scan
  final DateTime? dateIn; // Populated on second gate scan
  final DateTime? timeIn; // Populated on second gate scan
  final String
  status; // pending_approval, approved, rejected, active, completed, expired
  final String? approvedByWardenId;
  final String? approvedByWardenName;
  final String? rejectionReason;
  final DateTime? approvalTime;
  final DateTime createdAt; // When student submitted the request

  const LeaveRecord({
    required this.id,
    required this.serialNumber,
    required this.studentId,
    required this.studentName,
    required this.hostelNumber,
    required this.roomNumber,
    required this.phone,
    required this.reason,
    this.dateOut,
    this.timeOut,
    this.dateIn,
    this.timeIn,
    required this.status,
    this.approvedByWardenId,
    this.approvedByWardenName,
    this.rejectionReason,
    this.approvalTime,
    required this.createdAt,
  });

  bool get isPending => status == 'pending_approval';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isActive => status == 'active'; // Student is out
  bool get isCompleted => status == 'completed'; // Student returned

  factory LeaveRecord.fromJson(Map<String, dynamic> json) {
    return LeaveRecord(
      id: json['id'] as String,
      serialNumber: json['serial_number'] as int,
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String,
      hostelNumber: json['hostel_number'] as String,
      roomNumber: json['room_number'] as String,
      phone: json['phone'] as String,
      reason: json['reason'] as String,
      dateOut: json['date_out'] != null
          ? DateTime.parse(json['date_out'] as String)
          : null,
      timeOut: json['time_out'] != null
          ? DateTime.parse(json['time_out'] as String)
          : null,
      dateIn: json['date_in'] != null
          ? DateTime.parse(json['date_in'] as String)
          : null,
      timeIn: json['time_in'] != null
          ? DateTime.parse(json['time_in'] as String)
          : null,
      status: json['status'] as String,
      approvedByWardenId: json['approved_by_warden_id'] as String?,
      approvedByWardenName: json['approved_by_warden_name'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      approvalTime: json['approval_time'] != null
          ? DateTime.parse(json['approval_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial_number': serialNumber,
      'student_id': studentId,
      'student_name': studentName,
      'hostel_number': hostelNumber,
      'room_number': roomNumber,
      'phone': phone,
      'reason': reason,
      if (dateOut != null) 'date_out': dateOut!.toIso8601String(),
      if (timeOut != null) 'time_out': timeOut!.toIso8601String(),
      if (dateIn != null) 'date_in': dateIn!.toIso8601String(),
      if (timeIn != null) 'time_in': timeIn!.toIso8601String(),
      'status': status,
      if (approvedByWardenId != null)
        'approved_by_warden_id': approvedByWardenId,
      if (approvedByWardenName != null)
        'approved_by_warden_name': approvedByWardenName,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (approvalTime != null)
        'approval_time': approvalTime!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ── Leave Request (used by warden to display incoming requests) ───────────────

class LeaveRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String hostelNumber;
  final String phone;
  final String reason;
  final String? fathersName;
  final String? fathersPhone;
  final DateTime requestedAt;
  final String status;

  const LeaveRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.hostelNumber,
    required this.phone,
    required this.reason,
    this.fathersName,
    this.fathersPhone,
    required this.requestedAt,
    required this.status,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String,
      roomNumber: json['room_number'] as String,
      hostelNumber: json['hostel_number'] as String,
      phone: json['phone'] as String,
      reason: json['reason'] as String,
      fathersName: json['fathers_name'] as String?,
      fathersPhone: json['fathers_phone'] as String?,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      status: json['status'] as String,
    );
  }
}
