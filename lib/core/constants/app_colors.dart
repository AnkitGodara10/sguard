// FILE: lib/core/constants/app_colors.dart
//
// PURPOSE:
//   Centralizes every color used in the SGuard app.
//   By defining colors here, you guarantee visual consistency and
//   make design updates trivial — change one value, it propagates everywhere.
//
// RULES:
//   - Never use raw Color(0xFF...) values inside widget files
//   - Always reference AppColors.something
//   - Add semantic names (e.g. "success", "error") not just hex values

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor — this class is never instantiated

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A237E); // Deep Indigo
  static const Color primaryLight = Color(0xFF3949AB); // Medium Indigo
  static const Color primaryDark = Color(0xFF0D1257); // Dark Indigo
  static const Color accent = Color(0xFF00BCD4); // Cyan accent

  // ── Role Colors ───────────────────────────────────────────────────────────
  // Each user role has its own color identity to visually differentiate
  // dashboards and role-specific UI components
  static const Color studentColor = Color(0xFF1565C0); // Blue
  static const Color wardenColor = Color(0xFF2E7D32); // Green
  static const Color adminColor = Color(0xFF6A1B9A); // Purple

  // ── Semantic Colors ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF43A047); // Green — gate scan success
  static const Color error = Color(0xFFE53935); // Red — gate scan failure
  static const Color warning = Color(0xFFFB8C00); // Orange — QR expiring soon
  static const Color info = Color(0xFF039BE5); // Light blue — informational

  // ── Background Colors ─────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2FF);

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F1219);
  static const Color surfaceDark = Color(0xFF1A1F2E);
  static const Color surfaceVariantDark = Color(0xFF252B3B);

  // ── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7080);
  static const Color textHint = Color(0xFFB0B7C3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Border & Divider ──────────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // ── QR Scanner Colors ─────────────────────────────────────────────────────
  static const Color scannerGreen = Color(0xFF00C853); // Successful QR scan
  static const Color scannerRed = Color(0xFFD50000); // Failed/invalid QR scan
  static const Color scannerOverlay = Color(0x88000000);

  // ── Leave Status Colors ───────────────────────────────────────────────────
  static const Color statusApproved = Color(0xFF43A047);
  static const Color statusPending = Color(0xFFFB8C00);
  static const Color statusRejected = Color(0xFFE53935);
  static const Color statusExpired = Color(0xFF9E9E9E);
  static const Color statusActive = Color(0xFF1565C0);
}
