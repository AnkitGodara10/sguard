// FILE: lib/core/services/mock_data_service.dart
//
// PURPOSE:
//   Provides in-memory mock data for development and testing.
//   This service lets the entire app run without a real backend.
//
// HOW IT WORKS:
//   When the backend is NOT ready, repositories can call MockDataService
//   instead of ApiClient. Switch from mock to real by changing one flag
//   in injection.dart:
//
//     // During development:
//     static const bool useMockData = true;
//
//     // When backend is ready:
//     static const bool useMockData = false;
//
// WHAT THIS GIVES YOU:
//   - Every screen can be built and tested without a server
//   - QA can test role-based flows before backend is deployed
//   - UI designers can see realistic data immediately
//
// IMPORTANT:
//   This class uses the SAME model classes as production code.
//   Mock data shapes must exactly match what the API will return.
//   If the API returns a different JSON shape later, only fromJson()
//   needs updating — not the rest of the app.

import '../../models/student_model.dart';
import '../../models/warden_model.dart';
import '../../models/admin_model.dart';
import '../../models/auth_model.dart';
import '../../models/leave_record_model.dart';
import '../../models/qr_model.dart';
import '../../models/scanner_model.dart';
import '../../models/user_role.dart';
import '../constants/app_constants.dart';

class MockDataService {
  MockDataService._();

  // ── Mock Login Responses ───────────────────────────────────────────────────
  // These are returned when a user logs in during development.

  static LoginResponse mockStudentLogin(String email) => LoginResponse(
    accessToken: 'mock_student_token_${DateTime.now().millisecondsSinceEpoch}',
    refreshToken: 'mock_student_refresh_token',
    userId: 'student_001',
    role: UserRole.student,
    name: 'Arjun Sharma',
    email: email,
  );

  static LoginResponse mockWardenLogin(String email) => LoginResponse(
    accessToken: 'mock_warden_token_${DateTime.now().millisecondsSinceEpoch}',
    refreshToken: 'mock_warden_refresh_token',
    userId: 'warden_001',
    role: UserRole.warden,
    name: 'Dr. Meera Pillai',
    email: email,
  );

  static LoginResponse mockAdminLogin(String email) => LoginResponse(
    accessToken: 'mock_admin_token_${DateTime.now().millisecondsSinceEpoch}',
    refreshToken: 'mock_admin_refresh_token',
    userId: 'admin_001',
    role: UserRole.admin,
    name: 'Admin User',
    email: email,
  );

  // ── Mock Student ───────────────────────────────────────────────────────────

  static StudentModel get mockStudent => StudentModel(
    id: 'student_001',
    name: 'Arjun Sharma',
    email: 'arjun.sharma@college.edu',
    phone: '9876543210',
    hostelNumber: 'H3',
    roomNumber: '204',
    rollNumber: '21CS047',
    year: '3rd Year',
    fathersName: 'Ramesh Sharma',
    fathersPhone: '9876500000',
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
  );

  // ── Mock Warden ────────────────────────────────────────────────────────────

  static WardenModel get mockWarden => WardenModel(
    id: 'warden_001',
    wardenId: 'WRD-2021-03',
    name: 'Dr. Meera Pillai',
    email: 'meera.pillai@college.edu',
    phone: '9988776655',
    hostel: 'H3',
    createdAt: DateTime.now().subtract(const Duration(days: 500)),
  );

  // ── Mock Admin ─────────────────────────────────────────────────────────────

  static AdminModel get mockAdmin => AdminModel(
    id: 'admin_001',
    name: 'Admin User',
    email: 'admin@college.edu',
    phone: '9900112233',
    createdAt: DateTime.now().subtract(const Duration(days: 730)),
  );

  // ── Mock QR Code ───────────────────────────────────────────────────────────

  static QrModel mockSlQr({bool firstScanDone = false}) => QrModel(
    id: 'qr_sl_001',
    userId: 'student_001',
    leaveType: AppConstants.leaveTypeSl,
    leaveId: 'sl_001',
    payload: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_payload.mock_signature',
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    expiresAt: DateTime.now().add(const Duration(minutes: 28)),
    scanCount: firstScanDone ? 1 : 0,
    status: firstScanDone
        ? AppConstants.qrStatusScanning
        : AppConstants.qrStatusActive,
    firstScanAt: firstScanDone
        ? DateTime.now().subtract(const Duration(minutes: 1))
        : null,
  );

  // ── Mock Leave Records (SL) ────────────────────────────────────────────────

  static List<ShortLeaveRecord> get mockSlHistory => List.generate(
    8,
    (i) => ShortLeaveRecord(
      id: 'sl_00${i + 1}',
      serialNumber: i + 1,
      date: DateTime.now().subtract(Duration(days: i * 3)),
      studentId: 'student_001',
      studentName: 'Arjun Sharma',
      hostelNumber: 'H3',
      roomNumber: '204',
      phone: '9876543210',
      reason: [
        'Market visit',
        'Medical appointment',
        'Family visit',
        'Bank work',
        'Stationery purchase',
      ][i % 5],
      timeOut: DateTime.now().subtract(Duration(days: i * 3, hours: 14)),
      timeIn: DateTime.now().subtract(Duration(days: i * 3, hours: 12)),
      status: 'completed',
    ),
  );

  // ── Mock Leave Records (L) ─────────────────────────────────────────────────

  static List<LeaveRecord> get mockLeaveHistory => [
    LeaveRecord(
      id: 'leave_001',
      serialNumber: 1,
      studentId: 'student_001',
      studentName: 'Arjun Sharma',
      hostelNumber: 'H3',
      roomNumber: '204',
      phone: '9876543210',
      reason: 'Festival holidays - Diwali',
      dateOut: DateTime.now().subtract(const Duration(days: 30)),
      timeOut: DateTime.now().subtract(const Duration(days: 30, hours: 10)),
      dateIn: DateTime.now().subtract(const Duration(days: 27)),
      timeIn: DateTime.now().subtract(const Duration(days: 27, hours: 18)),
      status: 'completed',
      approvedByWardenId: 'warden_001',
      approvedByWardenName: 'Dr. Meera Pillai',
      createdAt: DateTime.now().subtract(const Duration(days: 32)),
    ),
    LeaveRecord(
      id: 'leave_002',
      serialNumber: 2,
      studentId: 'student_001',
      studentName: 'Arjun Sharma',
      hostelNumber: 'H3',
      roomNumber: '204',
      phone: '9876543210',
      reason: 'Medical treatment - knee injury',
      dateOut: DateTime.now().subtract(const Duration(days: 10)),
      timeOut: DateTime.now().subtract(const Duration(days: 10, hours: 9)),
      dateIn: null,
      timeIn: null,
      status: 'active',
      approvedByWardenId: 'warden_001',
      approvedByWardenName: 'Dr. Meera Pillai',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

  // ── Mock Pending Leave Requests (for warden) ───────────────────────────────

  static List<LeaveRequest> get mockLeaveRequests => [
    LeaveRequest(
      id: 'req_001',
      studentId: 'student_002',
      studentName: 'Priya Menon',
      roomNumber: '108',
      hostelNumber: 'H3',
      phone: '9123456789',
      reason: 'Sister\'s wedding ceremony in hometown',
      fathersName: 'Suresh Menon',
      fathersPhone: '9000012345',
      requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'pending_approval',
    ),
    LeaveRequest(
      id: 'req_002',
      studentId: 'student_003',
      studentName: 'Rahul Nair',
      roomNumber: '212',
      hostelNumber: 'H3',
      phone: '9876501234',
      reason: 'Medical appointment at Apollo Hospital',
      fathersName: 'Biju Nair',
      fathersPhone: '9900011122',
      requestedAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'pending_approval',
    ),
  ];

  // ── Mock Student Master List ───────────────────────────────────────────────

  static List<StudentMasterRecord> get mockStudentMasterList =>
      List.generate(15, (i) {
        final years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
        return StudentMasterRecord(
          id: 'smaster_00${i + 1}',
          serialNumber: i + 1,
          rollNumber: '21CS0${(i + 1).toString().padLeft(2, '0')}',
          name: [
            'Arjun Sharma',
            'Priya Menon',
            'Rahul Nair',
            'Sneha Pillai',
            'Arun Kumar',
            'Divya Krishnan',
            'Karthik Raj',
            'Anjali Singh',
            'Rohan Verma',
            'Nisha Thomas',
            'Vijay Mohan',
            'Lakshmi Devi',
            'Siddharth Iyer',
            'Meera Das',
            'Aakash Patel',
          ][i],
          year: years[i % 4],
          fathersName: 'Father of Student ${i + 1}',
          fathersPhone: '98${(76543210 + i).toString()}',
        );
      });

  // ── Mock Warden Master List ────────────────────────────────────────────────

  static List<WardenMasterRecord> get mockWardenMasterList => [
    const WardenMasterRecord(
      id: 'wmaster_001',
      serialNumber: 1,
      wardenId: 'WRD-2021-01',
      name: 'Prof. Anand Krishnaswamy',
      hostel: 'H1',
      phone: '9988776600',
    ),
    const WardenMasterRecord(
      id: 'wmaster_002',
      serialNumber: 2,
      wardenId: 'WRD-2021-02',
      name: 'Dr. Lakshmi Ramachandran',
      hostel: 'H2',
      phone: '9988776611',
    ),
    const WardenMasterRecord(
      id: 'wmaster_003',
      serialNumber: 3,
      wardenId: 'WRD-2021-03',
      name: 'Dr. Meera Pillai',
      hostel: 'H3',
      phone: '9988776655',
    ),
  ];

  // ── Mock Scanners ──────────────────────────────────────────────────────────

  static List<ScannerModel> get mockScanners => [
    ScannerModel(
      id: 'scanner_001',
      name: 'Main Gate Scanner',
      location: 'Main Entrance – Gate 1',
      deviceId: 'SGUARD-SCAN-001',
      status: 'active',
      registeredAt: DateTime.now().subtract(const Duration(days: 60)),
      lastActiveAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ScannerModel(
      id: 'scanner_002',
      name: 'Side Gate Scanner',
      location: 'Side Entrance – Gate 2',
      deviceId: 'SGUARD-SCAN-002',
      status: 'active',
      registeredAt: DateTime.now().subtract(const Duration(days: 60)),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ScannerModel(
      id: 'scanner_003',
      name: 'Hostel Block C Scanner',
      location: 'Hostel Block C Entrance',
      deviceId: 'SGUARD-SCAN-003',
      status: 'inactive',
      registeredAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];
}
