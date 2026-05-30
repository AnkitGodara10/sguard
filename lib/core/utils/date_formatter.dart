// FILE: lib/core/utils/date_formatter.dart
//
// PURPOSE:
//   Provides consistent date and time formatting across the entire app.
//   Leave records display dates in multiple formats depending on context
//   (history tables, QR screens, warden dashboards). Centralizing all
//   formatting here prevents inconsistencies like "12/05/2024" vs "May 12, 2024"
//   appearing on different screens.
//
// HOW IT WORKS:
//   - Static methods take DateTime objects and return formatted strings
//   - Never call DateFormat() directly inside a widget or ViewModel —
//     always route through this class

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  // ── Date Formats ──────────────────────────────────────────────────────────

  /// Formats: "15 May 2024"
  static String displayDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  /// Formats: "15/05/2024"
  static String shortDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  /// Formats: "Monday, 15 May 2024"
  static String fullDate(DateTime dateTime) {
    return DateFormat('EEEE, dd MMM yyyy').format(dateTime);
  }

  /// Formats: "May 2024"
  static String monthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy').format(dateTime);
  }

  // ── Time Formats ──────────────────────────────────────────────────────────

  /// Formats: "02:30 PM"
  static String displayTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Formats: "14:30"
  static String time24(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Formats: "14:30:00"
  static String time24WithSeconds(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  // ── Combined Formats ──────────────────────────────────────────────────────

  /// Formats: "15 May 2024, 02:30 PM"
  static String displayDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  /// Formats: "15/05/2024 14:30"
  static String shortDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // ── QR Timer ──────────────────────────────────────────────────────────────

  /// Formats a Duration as "MM:SS" for QR countdown timer
  static String countdownTimer(Duration duration) {
    if (duration.isNegative) return '00:00';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Formats a Duration as "H hrs M mins" for display
  static String durationDisplay(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  // ── Relative Time ─────────────────────────────────────────────────────────

  /// Returns human-readable relative time: "2 hours ago", "Just now", etc.
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? "minute" : "minutes"} ago';
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? "hour" : "hours"} ago';
    } else if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${d == 1 ? "day" : "days"} ago';
    } else {
      return displayDate(dateTime);
    }
  }

  // ── Parsing ───────────────────────────────────────────────────────────────

  /// Parses an ISO 8601 string from the API into a DateTime
  /// Returns null if parsing fails
  static DateTime? parseApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Converts a DateTime to ISO 8601 string for API requests
  static String toApiDate(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  // ── Leave-specific Helpers ────────────────────────────────────────────────

  /// Checks if a QR code has expired based on creation time and validity
  static bool isQrExpired(DateTime createdAt, Duration validity) {
    return DateTime.now().isAfter(createdAt.add(validity));
  }

  /// Returns remaining time for a QR code
  static Duration qrRemainingTime(DateTime createdAt, Duration validity) {
    final expiry = createdAt.add(validity);
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Calculates if minimum scan gap has been met
  static bool hasMinimumTimePassed(DateTime firstScan, Duration minGap) {
    return DateTime.now().isAfter(firstScan.add(minGap));
  }
}
