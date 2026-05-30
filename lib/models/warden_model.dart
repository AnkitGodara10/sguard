// FILE: lib/models/warden_model.dart
//
// PURPOSE:
//   Represents a Warden user in SGuard.
//   Wardens are staff members assigned to specific hostels.
//   They can approve/reject student leave requests and view their hostel's
//   student records.
//
// NOTE:
//   Wardens also have their own leave flow. A warden's SL works exactly like
//   a student's SL. A warden's Leave (L) request goes to the Admin instead
//   of to another warden.

class WardenModel {
  final String id;
  final String wardenId; // Official institutional Warden ID
  final String name;
  final String email;
  final String phone;
  final String hostel; // The hostel this warden manages
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WardenModel({
    required this.id,
    required this.wardenId,
    required this.name,
    required this.email,
    required this.phone,
    required this.hostel,
    required this.createdAt,
    this.updatedAt,
  });

  factory WardenModel.fromJson(Map<String, dynamic> json) {
    return WardenModel(
      id: json['id'] as String,
      wardenId: json['warden_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      hostel: json['hostel'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warden_id': wardenId,
      'name': name,
      'email': email,
      'phone': phone,
      'hostel': hostel,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  WardenModel copyWith({
    String? id,
    String? wardenId,
    String? name,
    String? email,
    String? phone,
    String? hostel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WardenModel(
      id: id ?? this.id,
      wardenId: wardenId ?? this.wardenId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hostel: hostel ?? this.hostel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ── Warden Master Record (Admin Master List) ──────────────────────────────────

class WardenMasterRecord {
  final String id;
  final int serialNumber;
  final String wardenId;
  final String name;
  final String hostel;
  final String phone;

  const WardenMasterRecord({
    required this.id,
    required this.serialNumber,
    required this.wardenId,
    required this.name,
    required this.hostel,
    required this.phone,
  });

  factory WardenMasterRecord.fromJson(Map<String, dynamic> json) {
    return WardenMasterRecord(
      id: json['id'] as String,
      serialNumber: json['serial_number'] as int,
      wardenId: json['warden_id'] as String,
      name: json['name'] as String,
      hostel: json['hostel'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial_number': serialNumber,
      'warden_id': wardenId,
      'name': name,
      'hostel': hostel,
      'phone': phone,
    };
  }
}
