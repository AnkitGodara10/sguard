// FILE: lib/core/widgets/role_color_helper.dart
//
// PURPOSE:
//   Provides consistent role-based colors and icons across all views.
//   Extracted as a utility so every view uses the same color for each role
//   without repeating the switch() logic.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/user_role.dart';

class RoleColorHelper {
  RoleColorHelper._();

  static Color colorForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.studentColor;
      case UserRole.warden:
        return AppColors.wardenColor;
      case UserRole.admin:
        return AppColors.adminColor;
    }
  }

  static IconData iconForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school_outlined;
      case UserRole.warden:
        return Icons.manage_accounts_outlined;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }

  static String dashboardTitleForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student Dashboard';
      case UserRole.warden:
        return 'Warden Dashboard';
      case UserRole.admin:
        return 'Admin Dashboard';
    }
  }
}
