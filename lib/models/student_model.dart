// FILE: lib/models/student_model.dart
//
// PURPOSE:
//   Represents a Student user in SGuard.
//   This model is used in:
//     - Authentication (after login, the student profile is loaded)
//     - Warden dashboard (wardens browse students)
//     - Admin management (admin sees full master list)
//     - QR generation (student's details are embedded in QR payload)
//
// TWO REPRESENTATIONS:
//   StudentModel — the full profile for a logged-in student
//   StudentMasterRecord — the admin master list record (serial, roll, year, etc.)
//
// DATA FLOW:
//   API JSON → fromJson() → StudentModel instance → ViewModel → View
//   User form inputs → ViewModel → StudentModel.toJson() → API

class StudentModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String hostelNumber;
  final String roomNumber;
  final String? rollNumber; // Present only after admin registers them
  final String? year;
  final String? fathersName;
  final String? fathersPhone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.hostelNumber,
    required this.roomNumber,
    this.rollNumber,
    this.year,
    this.fathersName,
    this.fathersPhone,
    required this.createdAt,
    this.updatedAt,
  });

  // ── Deserialization (API → Model) ─────────────────────────────────────────
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      hostelNumber: json['hostel_number'] as String,
      roomNumber: json['room_number'] as String,
      rollNumber: json['roll_number'] as String?,
      year: json['year'] as String?,
      fathersName: json['fathers_name'] as String?,
      fathersPhone: json['fathers_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // ── Serialization (Model → API) ───────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'hostel_number': hostelNumber,
      'room_number': roomNumber,
      if (rollNumber != null) 'roll_number': rollNumber,
      if (year != null) 'year': year,
      if (fathersName != null) 'fathers_name': fathersName,
      if (fathersPhone != null) 'fathers_phone': fathersPhone,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // ── CopyWith (immutable updates) ──────────────────────────────────────────
  // Used when warden updates hostel/room, or student updates phone/email
  StudentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? hostelNumber,
    String? roomNumber,
    String? rollNumber,
    String? year,
    String? fathersName,
    String? fathersPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hostelNumber: hostelNumber ?? this.hostelNumber,
      roomNumber: roomNumber ?? this.roomNumber,
      rollNumber: rollNumber ?? this.rollNumber,
      year: year ?? this.year,
      fathersName: fathersName ?? this.fathersName,
      fathersPhone: fathersPhone ?? this.fathersPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ── Student Master Record (Admin Master List) ─────────────────────────────────
// This is the record admins manage — it's different from the signup profile.
// It serves as the "approved students" list before a student can sign up.

class StudentMasterRecord {
  final String id;
  final int serialNumber;
  final String rollNumber;
  final String name;
  final String year;
  final String fathersName;
  final String fathersPhone;

  const StudentMasterRecord({
    required this.id,
    required this.serialNumber,
    required this.rollNumber,
    required this.name,
    required this.year,
    required this.fathersName,
    required this.fathersPhone,
  });

  factory StudentMasterRecord.fromJson(Map<String, dynamic> json) {
    return StudentMasterRecord(
      id: json['id'] as String,
      serialNumber: json['serial_number'] as int,
      rollNumber: json['roll_number'] as String,
      name: json['name'] as String,
      year: json['year'] as String,
      fathersName: json['fathers_name'] as String,
      fathersPhone: json['fathers_phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial_number': serialNumber,
      'roll_number': rollNumber,
      'name': name,
      'year': year,
      'fathers_name': fathersName,
      'fathers_phone': fathersPhone,
    };
  }
}
