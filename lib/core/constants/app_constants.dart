// FILE: lib/core/constants/app_constants.dart
//
// PURPOSE:
//   Stores every non-UI constant in the app — durations, limits, keys,
//   API paths, regex patterns. This prevents magic numbers and hardcoded
//   strings from appearing in business logic or UI code.
//
// RULES:
//   - Every "magic number" or "magic string" must live here
//   - Group constants logically with section comments
//   - Constants are final (value-type) or const (compile-time)

class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'SGuard';
  static const String appVersion = '1.0.0';

  // ── QR Code Rules ─────────────────────────────────────────────────────────
  // Short Leave QR validity from generation (in minutes)
  static const int slQrValidityMinutes = 30;

  // Leave QR validity from generation (in hours)
  static const int leaveQrValidityHours = 3;

  // Minimum time between SL first and second scan (in minutes)
  static const int slMinTimeBetweenScansMinutes = 5;

  // Minimum time between Leave first and second scan (in hours)
  static const int leaveMinTimeBetweenScansHours = 12;

  // Maximum QR scans before it is deleted
  static const int qrMaxScans = 2;

  // ── Data Retention Rules ──────────────────────────────────────────────────
  // Student can view their own SL records for this many days
  static const int studentSlHistoryDays = 30;

  // Student can view their own Leave records for this many months
  static const int studentLeaveHistoryMonths = 6;

  // ── Serial Number Resets ──────────────────────────────────────────────────
  // SL serial number resets every day (true = daily reset)
  static const String slSerialResetFrequency = 'daily';

  // Leave serial number resets every week
  static const String leaveSerialResetFrequency = 'weekly';

  // ── Secure Storage Keys ───────────────────────────────────────────────────
  // These are the keys used with flutter_secure_storage
  // NEVER reference raw strings like 'auth_token' anywhere else
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserEmail = 'user_email';

  // ── Shared Preferences Keys ───────────────────────────────────────────────
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefThemeMode = 'theme_mode';
  static const String prefLastLoginRole = 'last_login_role';

  // ── API Configuration ─────────────────────────────────────────────────────
  // Base URL — will be configured from environment or config file in production
  // For now it's a placeholder. Backend integration will replace this.
  static const String apiBaseUrl = 'https://api.sguard.example.com/v1';
  static const Duration apiConnectTimeout = Duration(seconds: 15);
  static const Duration apiReceiveTimeout = Duration(seconds: 30);

  // ── API Endpoints ─────────────────────────────────────────────────────────
  // Auth
  static const String endpointLogin = '/auth/login';
  static const String endpointSignup = '/auth/signup';
  static const String endpointLogout = '/auth/logout';
  static const String endpointRefreshToken = '/auth/refresh';

  // Student
  static const String endpointStudentProfile = '/student/profile';
  static const String endpointGenerateSlQr = '/student/sl/qr/generate';
  static const String endpointRequestLeave = '/student/leave/request';
  static const String endpointStudentSlHistory = '/student/sl/history';
  static const String endpointStudentLeaveHistory = '/student/leave/history';

  // Warden
  static const String endpointWardenProfile = '/warden/profile';
  static const String endpointLeaveRequests = '/warden/leave/requests';
  static const String endpointApproveLeave = '/warden/leave/approve';
  static const String endpointRejectLeave = '/warden/leave/reject';
  static const String endpointWardenStudents = '/warden/students';

  // Admin
  static const String endpointAdminStudentList = '/admin/students';
  static const String endpointAdminWardenList = '/admin/wardens';
  static const String endpointAdminScannerList = '/admin/scanners';
  static const String endpointRegisterScanner = '/admin/scanners/register';
  static const String endpointAdminReports = '/admin/reports';

  // Scanner
  static const String endpointScanQr = '/scanner/scan';

  // ── Validation ────────────────────────────────────────────────────────────
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int phoneNumberLength = 10; // Indian mobile numbers

  // ── Regex Patterns ────────────────────────────────────────────────────────
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(r'^[6-9]\d{9}$'); // Indian mobile
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
  );

  // ── Leave Types ───────────────────────────────────────────────────────────
  // These string identifiers are used in API calls, models, and route params.
  // Never use raw strings 'SL' or 'L' in code — always use these constants.
  static const String leaveTypeSl = 'SL'; // Short Leave
  static const String leaveTypeL = 'L'; // Leave

  // ── User Roles ────────────────────────────────────────────────────────────
  static const String roleStudent = 'student';
  static const String roleWarden = 'warden';
  static const String roleAdmin = 'admin';

  // ── QR Status Values ──────────────────────────────────────────────────────
  static const String qrStatusActive = 'active';
  static const String qrStatusUsed = 'used'; // scanned 2 times
  static const String qrStatusExpired = 'expired'; // time limit reached
  static const String qrStatusScanning = 'scanning'; // first scan done

  // ── Leave Status Values ───────────────────────────────────────────────────
  static const String leaveStatusPending = 'pending';
  static const String leaveStatusApproved = 'approved';
  static const String leaveStatusRejected = 'rejected';
  static const String leaveStatusActive = 'active'; // student is out
  static const String leaveStatusCompleted = 'completed'; // student returned
  static const String leaveStatusExpired = 'expired';

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Animation Durations ───────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ── Scanner ───────────────────────────────────────────────────────────────
  // How long the scanner shows green/red result light (in seconds)
  static const int scannerResultDisplaySeconds = 3;
}
