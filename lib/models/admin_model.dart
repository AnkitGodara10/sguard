// FILE: lib/models/admin_model.dart
//
// PURPOSE:
//   Represents an Admin user in SGuard.
//   Admins have the highest access level — they can manage students, wardens,
//   scanners, and view all leave records including warden records.
//
// NOTE:
//   Admin registration collects name, phone, email, password only.
//   There is no institutional ID for admins.

class AdminModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    this.updatedAt,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
