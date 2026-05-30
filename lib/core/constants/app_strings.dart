// FILE: lib/core/constants/app_strings.dart
//
// PURPOSE:
//   Stores every user-facing text string displayed in the UI.
//   Centralizing strings here:
//     1. Makes future localization (l10n) straightforward — replace this class
//        with ARB-based lookups without touching any view files
//     2. Prevents typos in repeated strings (e.g. "Short Leave" spelled
//        inconsistently across screens)
//     3. Makes copy editing easy — product/marketing can update text by
//        editing just this file
//
// RULES:
//   - Every text shown to the user must come from here
//   - Never hardcode display strings inside widget files
//   - Group strings by screen/feature

class AppStrings {
  AppStrings._();

  // ── App General ───────────────────────────────────────────────────────────
  static const String appName = 'SGuard';
  static const String appTagline = 'Campus Security, Simplified';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String submit = 'Submit';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String approve = 'Approve';
  static const String reject = 'Reject';
  static const String refresh = 'Refresh';
  static const String search = 'Search';
  static const String noData = 'No data available';
  static const String noInternet =
      'No internet connection. Please check your network.';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';

  // ── Role Selection Screen ─────────────────────────────────────────────────
  static const String selectRole = 'Select Your Role';
  static const String selectRoleSubtitle =
      'Choose how you want to access SGuard';
  static const String roleStudent = 'Student';
  static const String roleWarden = 'Warden / Staff';
  static const String roleAdmin = 'Admin';
  static const String studentRoleDesc = 'Manage your leaves and QR codes';
  static const String wardenRoleDesc = 'Approve leaves and manage students';
  static const String adminRoleDesc = 'Full system access and management';

  // ── Auth - Login ──────────────────────────────────────────────────────────
  static const String welcomeBack = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue to SGuard';
  static const String email = 'Email';
  static const String emailHint = 'Enter your email address';
  static const String password = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String forgotPassword = 'Forgot Password?';
  static const String login = 'Log In';
  static const String noAccount = "Don't have an account? ";
  static const String signUp = 'Sign Up';
  static const String loginSuccess = 'Login successful';
  static const String loginFailed = 'Invalid email or password';

  // ── Auth - Signup ─────────────────────────────────────────────────────────
  static const String createAccount = 'Create Account';
  static const String signupSubtitle = 'Fill in your details to register';
  static const String name = 'Full Name';
  static const String nameHint = 'Enter your full name';
  static const String phone = 'Phone Number';
  static const String phoneHint = 'Enter 10-digit mobile number';
  static const String hostelNumber = 'Hostel Number';
  static const String hostelNumberHint = 'e.g. H1, H2, Boys Block A';
  static const String roomNumber = 'Room Number';
  static const String roomNumberHint = 'e.g. 204, G-12';
  static const String wardenId = 'Warden ID';
  static const String wardenIdHint = 'Enter your official Warden ID';
  static const String hostel = 'Hostel';
  static const String hostelHint = 'Enter the hostel you manage';
  static const String confirmPassword = 'Confirm Password';
  static const String confirmPasswordHint = 'Re-enter your password';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signupSuccess = 'Account created successfully!';
  static const String passwordsDoNotMatch = 'Passwords do not match';

  // ── Student Dashboard ─────────────────────────────────────────────────────
  static const String studentDashboard = 'Dashboard';
  static const String myLeaves = 'My Leaves';
  static const String shortLeave = 'Short Leave';
  static const String shortLeaveAbbr = 'SL';
  static const String leave = 'Leave';
  static const String leaveAbbr = 'L';
  static const String generateQr = 'Generate QR';
  static const String requestLeave = 'Request Leave';
  static const String myHistory = 'My History';
  static const String currentlyOut = 'Currently Out';
  static const String onCampus = 'On Campus';
  static const String activeLeave = 'Active Leave';
  static const String noActiveLeave = 'No active leave';
  static const String slDescription =
      'Quick exit for a few hours. Valid for 30 minutes.';
  static const String leaveDescription =
      'Overnight or multi-day leave. Requires warden approval.';

  // ── QR Screen ─────────────────────────────────────────────────────────────
  static const String yourQrCode = 'Your QR Code';
  static const String qrSubtitle = 'Show this to the gate scanner';
  static const String qrExpiresIn = 'Expires in';
  static const String qrExpired = 'QR Code Expired';
  static const String qrExpiredMessage =
      'This QR code has expired. Please generate a new one.';
  static const String regenerateQr = 'Regenerate QR';
  static const String qrScannedOnce = 'Exit recorded. Show this on return.';
  static const String qrScannedTwice =
      'Entry recorded. You are back on campus.';
  static const String qrGenerating = 'Generating QR Code...';
  static const String qrValidFor = 'Valid for';
  static const String minutes = 'minutes';
  static const String hours = 'hours';
  static const String reason = 'Reason for Leave';
  static const String reasonHint = 'e.g. Market visit, Medical appointment';

  // ── Leave Request Screen ──────────────────────────────────────────────────
  static const String leaveRequest = 'Leave Request';
  static const String leaveRequestSubtitle =
      'Submit a leave request to your warden';
  static const String fromDate = 'From Date';
  static const String toDate = 'To Date';
  static const String fathersName = "Father's Name";
  static const String fathersNameHint = "Enter your father's full name";
  static const String fathersPhone = "Father's Phone";
  static const String fathersPhoneHint =
      "Enter father's 10-digit mobile number";
  static const String leaveRequestSubmitted =
      'Leave request submitted successfully';
  static const String pendingApproval = 'Pending Warden Approval';
  static const String requestApproved = 'Request Approved';
  static const String requestRejected = 'Request Rejected';
  static const String duplicateLeaveError =
      'You already have an active leave of this type';

  // ── Student History Screen ────────────────────────────────────────────────
  static const String leaveHistory = 'Leave History';
  static const String shortLeaveHistory = 'Short Leave History';
  static const String leaveRecords = 'Leave Records';
  static const String timeOut = 'Time Out';
  static const String timeIn = 'Time In';
  static const String dateOut = 'Date Out';
  static const String dateIn = 'Date In';
  static const String serialNumber = 'S.No.';
  static const String noHistoryFound = 'No leave history found';

  // ── Warden Dashboard ──────────────────────────────────────────────────────
  static const String wardenDashboard = 'Warden Dashboard';
  static const String pendingRequests = 'Pending Requests';
  static const String studentManagement = 'Student Management';
  static const String myLeaveRequests = 'My Leave Requests';
  static const String totalStudents = 'Total Students';
  static const String studentsOut = 'Students Out';
  static const String approveRequest = 'Approve Request';
  static const String rejectRequest = 'Reject Request';
  static const String leaveRequestDetails = 'Leave Request Details';
  static const String noLeaveRequests = 'No pending leave requests';
  static const String studentReturned = 'Student returned to campus';

  // ── Warden - Student Management ───────────────────────────────────────────
  static const String updateHostelRoom = 'Update Hostel / Room';
  static const String newHostelNumber = 'New Hostel Number';
  static const String newRoomNumber = 'New Room Number';
  static const String studentUpdated = 'Student details updated successfully';
  static const String viewStudentRecords = 'View Records';

  // ── Admin Dashboard ───────────────────────────────────────────────────────
  static const String adminDashboard = 'Admin Dashboard';
  static const String studentList = 'Student List';
  static const String wardenList = 'Warden List';
  static const String scannerManagement = 'Scanner Management';
  static const String reports = 'Reports';
  static const String addStudent = 'Add Student';
  static const String addWarden = 'Add Warden';
  static const String registerScanner = 'Register Scanner';

  // ── Admin - Student Master List ───────────────────────────────────────────
  static const String rollNumber = 'Roll Number';
  static const String rollNumberHint = 'e.g. 21CS001';
  static const String year = 'Year';
  static const String yearHint = 'e.g. 2nd Year';
  static const String studentAddedSuccess = 'Student added to master list';

  // ── Admin - Warden Master List ────────────────────────────────────────────
  static const String wardenAddedSuccess = 'Warden added to master list';

  // ── Admin - Scanner Management ────────────────────────────────────────────
  static const String scannerName = 'Scanner Name';
  static const String scannerNameHint = 'e.g. Main Gate Scanner';
  static const String scannerLocation = 'Scanner Location';
  static const String scannerLocationHint = 'e.g. Main Entrance';
  static const String scannerRegistered = 'Scanner registered successfully';
  static const String scannerActive = 'Active';
  static const String scannerInactive = 'Inactive';
  static const String noScanners = 'No scanners registered';

  // ── Scanner Result ────────────────────────────────────────────────────────
  static const String scanSuccess = 'Scan Successful';
  static const String scanFailure = 'Scan Failed';
  static const String scanInvalidQr = 'Invalid QR Code';
  static const String scanExpiredQr = 'QR Code Expired';
  static const String scanUnauthorized = 'Unauthorized QR Code';
  static const String exitRecorded = 'Exit Recorded';
  static const String entryRecorded = 'Entry Recorded';
  static const String tooSoon = 'Cannot scan — minimum time not elapsed';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profile = 'Profile';
  static const String myProfile = 'My Profile';
  static const String editProfile = 'Edit Profile';
  static const String logout = 'Logout';
  static const String logoutConfirm = 'Are you sure you want to log out?';
  static const String profileUpdated = 'Profile updated successfully';

  // ── Validation Messages ───────────────────────────────────────────────────
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPhone =
      'Please enter a valid 10-digit phone number';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordWeak =
      'Password must contain uppercase, lowercase and a number';

  // ── Error Messages ────────────────────────────────────────────────────────
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError =
      'You are not authorized to perform this action.';
  static const String notFoundError = 'The requested resource was not found.';
  static const String timeoutError = 'Request timed out. Please try again.';
}
