// FILE: lib/views/auth/role_selection_view.dart
//
// PURPOSE:
//   The first screen users see when they open SGuard.
//   Displays three role cards (Student, Warden, Admin) and navigates
//   to the Login screen with the selected role as a query parameter.
//
// DESIGN NOTES:
//   Clean, authoritative campus security aesthetic.
//   Each role card has its own color identity matching AppColors role colors.
//
// HOW NAVIGATION WORKS:
//   Tapping a role card calls context.go('/auth/login?role=student')
//   The login screen reads the role parameter and shows the correct form.
//
// NO BUSINESS LOGIC HERE:
//   This is a pure navigation screen. There is no ViewModel.
//   All it does is present options and route the user.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../routes/route_names.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(AppStrings.selectRole, style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text(
                AppStrings.selectRoleSubtitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // ── Role Cards ────────────────────────────────────────────────
              _RoleCard(
                title: AppStrings.roleStudent,
                description: AppStrings.studentRoleDesc,
                icon: Icons.school_outlined,
                color: AppColors.studentColor,
                onTap: () => context.go('${RouteNames.login}?role=student'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: AppStrings.roleWarden,
                description: AppStrings.wardenRoleDesc,
                icon: Icons.manage_accounts_outlined,
                color: AppColors.wardenColor,
                onTap: () => context.go('${RouteNames.login}?role=warden'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: AppStrings.roleAdmin,
                description: AppStrings.adminRoleDesc,
                icon: Icons.admin_panel_settings_outlined,
                color: AppColors.adminColor,
                onTap: () => context.go('${RouteNames.login}?role=admin'),
              ),

              const Spacer(),

              // ── Footer ───────────────────────────────────────────────────
              Center(
                child: Text(
                  AppStrings.appTagline,
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Role Card Widget ───────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(color: color),
                    ),
                    const SizedBox(height: 3),
                    Text(description, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: color.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
