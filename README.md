# SGuard — Flutter App

> Campus Entry/Exit Tracking System

---

## Quick Start

```bash
# 1. Get dependencies
flutter pub get

# 2. Run on device/emulator
flutter run

# Default test credentials (mock mode):
#   Student:  any email  +  password: student123
#   Warden:   any email  +  password: warden123
#   Admin:    any email  +  password: admin123
```

---

## Architecture Overview

```
SGuard uses MVVM + Clean Architecture

USER ACTION
    ↓
VIEW (.dart in views/)
  - No logic. Only renders state + calls ViewModel methods.
    ↓
VIEWMODEL (.dart in viewmodels/)
  - Holds UI state (loading, error, data).
  - Calls Repository methods.
  - Never imports API or HTTP directly.
    ↓
REPOSITORY (.dart in core/repositories/)
  - Talks to ApiClient (real) or MockRepository (dev).
  - Returns Result<T> — never throws.
    ↓
API CLIENT (core/services/api_client.dart)
  - Dio-based HTTP client.
  - Injects Bearer token on every request.
  - Handles token refresh on 401.
    ↓
BACKEND (your server)
```

---

## Project Structure

```
lib/
├── main.dart                         # Entry point, init DI, runApp
├── app.dart                          # Root widget, MultiProvider, router
│
├── di/
│   └── injection.dart                # 🔧 ALL dependency wiring here
│
├── routes/
│   ├── app_router.dart               # GoRouter config, all routes
│   └── route_names.dart              # Route path constants
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Every color in the app
│   │   ├── app_constants.dart        # Every magic number/string
│   │   ├── app_strings.dart          # Every UI text string
│   │   ├── app_text_styles.dart      # Typography system
│   │   └── app_theme.dart            # Light + dark MaterialApp theme
│   │
│   ├── utils/
│   │   ├── date_formatter.dart       # All date/time formatting
│   │   ├── result.dart               # Result<T> error handling type
│   │   └── validators.dart           # Form field validators
│   │
│   ├── services/
│   │   ├── api_client.dart           # Dio HTTP client + interceptors
│   │   ├── connectivity_service.dart # Network status monitoring
│   │   ├── mock_data_service.dart    # In-memory mock data
│   │   ├── mock_vm_bridge.dart       # Architecture notes for mock→real
│   │   ├── notification_service.dart # Local + push notifications
│   │   └── secure_storage_service.dart # Auth token storage
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart      # Login, signup, logout
│   │   ├── student_repository.dart   # Student profile, QR, leave
│   │   ├── warden_repository.dart    # Warden profile, approvals
│   │   ├── admin_repository.dart     # Admin management, reports
│   │   ├── mock_auth_repository.dart # Mock login (dev mode)
│   │   ├── mock_student_repository.dart
│   │   ├── mock_warden_repository.dart
│   │   └── mock_admin_repository.dart
│   │
│   ├── guards/
│   │   └── auth_guard.dart           # Route redirect logic
│   │
│   └── widgets/
│       └── app_widgets.dart          # Reusable UI components
│
├── models/
│   ├── user_role.dart                # UserRole enum
│   ├── auth_model.dart               # Login/signup request & response DTOs
│   ├── student_model.dart            # StudentModel + StudentMasterRecord
│   ├── warden_model.dart             # WardenModel + WardenMasterRecord
│   ├── admin_model.dart              # AdminModel
│   ├── leave_record_model.dart       # ShortLeaveRecord, LeaveRecord, LeaveRequest
│   ├── qr_model.dart                 # QR code state model
│   └── scanner_model.dart            # ScannerModel + ScanResult enum
│
├── viewmodels/
│   ├── auth/
│   │   └── auth_viewmodel.dart       # App-wide auth state (singleton)
│   ├── student/
│   │   ├── student_dashboard_viewmodel.dart
│   │   ├── generate_sl_qr_viewmodel.dart   # QR + countdown timer logic
│   │   ├── request_leave_viewmodel.dart
│   │   ├── student_history_viewmodel.dart
│   │   └── student_profile_viewmodel.dart
│   ├── warden/
│   │   ├── warden_dashboard_viewmodel.dart
│   │   ├── leave_requests_viewmodel.dart
│   │   ├── student_management_viewmodel.dart
│   │   └── warden_own_leave_viewmodel.dart
│   └── admin/
│       ├── admin_dashboard_viewmodel.dart
│       ├── admin_student_list_viewmodel.dart
│       ├── admin_warden_list_viewmodel.dart
│       ├── scanner_management_viewmodel.dart
│       └── admin_reports_viewmodel.dart
│
└── views/
    ├── auth/
    │   ├── role_selection_view.dart  # First screen — pick student/warden/admin
    │   ├── login_view.dart           # Login (adapts to role)
    │   └── signup_view.dart          # Signup (adapts to role)
    ├── student/
    │   ├── student_dashboard_view.dart
    │   ├── generate_sl_qr_view.dart  # QR display + timer
    │   ├── request_leave_view.dart
    │   ├── student_history_view.dart
    │   └── student_profile_view.dart
    ├── warden/
    │   ├── warden_dashboard_view.dart
    │   ├── leave_requests_view.dart
    │   ├── student_management_view.dart
    │   └── warden_own_leave_view.dart
    └── admin/
        ├── admin_dashboard_view.dart
        ├── admin_student_list_view.dart
        ├── admin_warden_list_view.dart
        ├── scanner_management_view.dart
        └── admin_reports_view.dart
```

---

## Mock → Real Backend Switch

Open `lib/di/injection.dart` and change:

```dart
// No backend needed — uses MockDataService
const bool _useMockData = true;

// Real API — update AppConstants.apiBaseUrl first
const bool _useMockData = false;
```

When switching to real: set your backend URL in `lib/core/constants/app_constants.dart`:

```dart
static const String apiBaseUrl = 'https://YOUR_API_URL/v1';
```

---

## 🗄️  DATABASE INTEGRATION GUIDE

### When to add the database

Add the database when:
1. You start building the **backend server** (Node.js, Django, FastAPI, etc.)
2. OR you want local offline support in the Flutter app

---

### Option A — Backend Database (Recommended)

This is the standard approach. The Flutter app talks to your API.
The server owns the database. Flutter never touches the DB directly.

#### Recommended stack:
```
Backend: Node.js (Express) or Python (FastAPI)
Database: PostgreSQL
ORM: Prisma (Node) or SQLAlchemy (Python)
Auth: JWT tokens
QR signing: jsonwebtoken / python-jose
```

#### Tables you need:

```sql
-- Users (all roles share this table, role column differentiates)
CREATE TABLE users (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role         VARCHAR(10) NOT NULL,   -- 'student' | 'warden' | 'admin'
  name         VARCHAR(100) NOT NULL,
  email        VARCHAR(150) UNIQUE NOT NULL,
  phone        VARCHAR(15) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ
);

-- Students (extends users)
CREATE TABLE students (
  id              UUID PRIMARY KEY REFERENCES users(id),
  hostel_number   VARCHAR(20) NOT NULL,
  room_number     VARCHAR(20) NOT NULL,
  roll_number     VARCHAR(20),
  year            VARCHAR(20),
  fathers_name    VARCHAR(100),
  fathers_phone   VARCHAR(15)
);

-- Wardens (extends users)
CREATE TABLE wardens (
  id        UUID PRIMARY KEY REFERENCES users(id),
  warden_id VARCHAR(30) UNIQUE NOT NULL,
  hostel    VARCHAR(50) NOT NULL
);

-- Admin master lists
CREATE TABLE student_master_list (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  serial_number  SERIAL,
  roll_number    VARCHAR(20) UNIQUE NOT NULL,
  name           VARCHAR(100) NOT NULL,
  year           VARCHAR(20) NOT NULL,
  fathers_name   VARCHAR(100) NOT NULL,
  fathers_phone  VARCHAR(15) NOT NULL
);

CREATE TABLE warden_master_list (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  serial_number SERIAL,
  warden_id     VARCHAR(30) UNIQUE NOT NULL,
  name          VARCHAR(100) NOT NULL,
  hostel        VARCHAR(50) NOT NULL,
  phone         VARCHAR(15) NOT NULL
);

-- QR codes
CREATE TABLE qr_codes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES users(id),
  leave_type    VARCHAR(5) NOT NULL,   -- 'SL' | 'L'
  leave_id      UUID NOT NULL,
  payload       TEXT NOT NULL,          -- signed JWT
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  expires_at    TIMESTAMPTZ NOT NULL,
  scan_count    INT DEFAULT 0,
  status        VARCHAR(20) DEFAULT 'active',
  first_scan_at  TIMESTAMPTZ,
  second_scan_at TIMESTAMPTZ
);

-- Short leave records (SL)
CREATE TABLE short_leave_records (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  serial_number INT NOT NULL,
  date          DATE NOT NULL,
  student_id    UUID REFERENCES users(id),
  student_name  VARCHAR(100) NOT NULL,
  hostel_number VARCHAR(20) NOT NULL,
  room_number   VARCHAR(20) NOT NULL,
  phone         VARCHAR(15) NOT NULL,
  reason        TEXT NOT NULL,
  time_out      TIMESTAMPTZ,
  time_in       TIMESTAMPTZ,
  status        VARCHAR(30) DEFAULT 'pending_exit',
  qr_id         UUID REFERENCES qr_codes(id)
);

-- Leave records (L)
CREATE TABLE leave_records (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  serial_number         INT NOT NULL,
  student_id            UUID REFERENCES users(id),
  student_name          VARCHAR(100) NOT NULL,
  hostel_number         VARCHAR(20) NOT NULL,
  room_number           VARCHAR(20) NOT NULL,
  phone                 VARCHAR(15) NOT NULL,
  reason                TEXT NOT NULL,
  date_out              DATE,
  time_out              TIMESTAMPTZ,
  date_in               DATE,
  time_in               TIMESTAMPTZ,
  status                VARCHAR(30) DEFAULT 'pending_approval',
  approved_by_warden_id UUID REFERENCES users(id),
  rejection_reason      TEXT,
  approval_time         TIMESTAMPTZ,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  qr_id                 UUID REFERENCES qr_codes(id)
);

-- Scanner devices
CREATE TABLE scanners (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name           VARCHAR(100) NOT NULL,
  location       VARCHAR(200) NOT NULL,
  device_id      VARCHAR(100) UNIQUE NOT NULL,
  scanner_token  VARCHAR(255) NOT NULL,  -- for scanner authentication
  status         VARCHAR(20) DEFAULT 'active',
  registered_at  TIMESTAMPTZ DEFAULT NOW(),
  last_active_at TIMESTAMPTZ
);
```

#### Serial number reset logic (backend):
```javascript
// SL serial resets daily — get today's count + 1
const today = new Date().toISOString().split('T')[0];
const count = await db.shortLeaveRecords.count({
  where: { date: today }
});
const serialNumber = count + 1;

// Leave serial resets weekly — get this week's count + 1
const weekStart = getMonday(new Date());
const count = await db.leaveRecords.count({
  where: { created_at: { gte: weekStart } }
});
const serialNumber = count + 1;
```

#### QR JWT signing (backend):
```javascript
// Generate QR payload — signed so gate scanner can verify it
const jwt = require('jsonwebtoken');

const qrPayload = jwt.sign({
  userId: student.id,
  leaveType: 'SL',
  leaveId: leaveRecord.id,
  issuedAt: Date.now(),
}, process.env.QR_SECRET, { expiresIn: '30m' });

// Scanner verifies:
try {
  const decoded = jwt.verify(qrPayload, process.env.QR_SECRET);
  // Valid — update scan record
} catch (err) {
  // Invalid/expired — return 'red light' response
}
```

---

### Option B — Local SQLite (Offline Support)

Add `sqflite` to pubspec.yaml for local caching.
Use this for offline QR viewing and record caching — NOT as primary storage.

```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.9.0
```

Create `lib/core/services/local_db_service.dart`:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'sguard.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Cache tables — mirrors backend models
    await db.execute('''
      CREATE TABLE cached_sl_records (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        reason TEXT NOT NULL,
        time_out TEXT,
        time_in TEXT,
        status TEXT NOT NULL,
        synced_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cached_qr (
        id TEXT PRIMARY KEY,
        payload TEXT NOT NULL,
        leave_type TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        scan_count INTEGER DEFAULT 0,
        status TEXT NOT NULL
      )
    ''');
  }
}
```

**When to use local DB:**
- Cache the student's QR code so it's viewable offline
- Cache the last 7 days of leave records for offline viewing
- Queue leave requests when offline, sync when connected

---

## Push Notifications (FCM)

When your backend is ready, add Firebase Cloud Messaging:

```yaml
# Add to pubspec.yaml
firebase_core: ^3.0.0
firebase_messaging: ^15.0.0
```

Update `notification_service.dart` to handle push messages:
- Warden receives push when student submits leave request
- Student receives push when warden approves/rejects
- Warden receives push when student returns from leave (L)

---

## Scanner Device Integration

The gate scanner is a separate device (Raspberry Pi, tablet, or dedicated hardware).
It calls your backend's `/scanner/scan` endpoint.

```
POST /scanner/scan
Headers: { Authorization: Bearer <scanner_token> }
Body: { qr_payload: "eyJhbGci..." }

Response (success):
{ result: "success", type: "exit"|"entry", student_name: "..." }

Response (failure):
{ result: "invalid"|"expired"|"too_soon" }
```

The scanner shows green/red LED based on the `result` field.
Only admin-registered scanner tokens are accepted — unregistered devices are rejected.

---

## Environment Configuration

Create these files (never commit them):

**`.env` (for backend):**
```
DATABASE_URL=postgresql://user:pass@localhost:5432/sguard
JWT_SECRET=your_very_long_jwt_secret_here
QR_SECRET=different_secret_for_qr_signing
PORT=3000
```

**`lib/core/constants/app_constants.dart` (for Flutter):**
```dart
// Development
static const String apiBaseUrl = 'http://10.0.2.2:3000/v1'; // Android emulator
// static const String apiBaseUrl = 'http://localhost:3000/v1'; // iOS simulator
// static const String apiBaseUrl = 'https://api.yoursite.com/v1'; // Production
```

---

## Role-Based Access Summary

| Feature                         | Student | Warden | Admin |
|---------------------------------|---------|--------|-------|
| Generate SL QR                  | ✅      | ✅     | —     |
| Request Leave (L)               | ✅      | ✅*    | —     |
| Approve/Reject Leave            | —       | ✅     | ✅*   |
| View own leave history          | ✅      | ✅     | —     |
| View all student records        | —       | ✅     | ✅    |
| Modify hostel/room numbers      | —       | ✅     | ✅    |
| Modify own phone/email          | ✅      | —      | —     |
| Add to student master list      | —       | —      | ✅    |
| Add to warden master list       | —       | —      | ✅    |
| Register gate scanners          | —       | —      | ✅    |
| View all records + warden recs  | —       | —      | ✅    |

*Warden's own Leave (L) request goes to Admin, not another warden.
*Admin approves warden leave requests.

---

## QR Lifecycle Diagram

```
Student taps "Generate SL QR"
         ↓
   [Backend generates JWT-signed QR payload]
         ↓
   QR displayed to student — 30 min timer starts
         ↓
   Student shows QR at gate
         ↓
   [Scanner sends payload to backend]
         ↓
   Backend validates JWT signature
         ↓
   ┌── VALID ────────────────────────────────┐
   │  scanCount = 1, status = "scanning"     │
   │  time_out recorded                      │
   │  Timer STOPS (QR won't expire now)      │
   │  Gate scanner: GREEN LIGHT              │
   └─────────────────────────────────────────┘
         ↓  (student returns, shows QR again)
   [Scanner scans again]
         ↓
   Backend checks: min 5 min since first scan?
         ↓
   ┌── YES ──────────────────────────────────┐
   │  scanCount = 2, status = "used"         │
   │  time_in recorded                       │
   │  QR deleted                             │
   │  Gate scanner: GREEN LIGHT              │
   └─────────────────────────────────────────┘
         ↓
   ┌── NO ───────────────────────────────────┐
   │  Gate scanner: RED LIGHT                │
   │  "Cannot scan — minimum time not met"   │
   └─────────────────────────────────────────┘

INVALID QR (not from backend / forged):
   Backend rejects JWT verification
   Gate scanner: RED LIGHT
```

---

## Running Tests

```bash
# Unit tests (models, validators, date formatter)
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

---

## Checklist Before Backend Integration

- [ ] Set `_useMockData = false` in `injection.dart`
- [ ] Update `apiBaseUrl` in `app_constants.dart`
- [ ] Ensure all API endpoints match `AppConstants` paths
- [ ] Add FCM for push notifications
- [ ] Set up proper JWT signing for QR payloads
- [ ] Implement serial number reset logic (daily for SL, weekly for L)
- [ ] Register scanner devices via admin dashboard
- [ ] Test QR scanner integration with backend `/scanner/scan`
- [ ] Enable SSL certificate verification in `api_client.dart`
- [ ] Remove `LogInterceptor` from `api_client.dart` in production