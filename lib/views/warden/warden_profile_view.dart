// FILE: lib/views/warden/warden_profile_view.dart
//
// PURPOSE:
//   Warden profile screen. Shows warden details (read-only mostly).
//   Wardens can update their own phone and email.
//   The warden_dashboard_view.dart has a profile icon that routes here.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_widgets.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';

// A lightweight, stateless profile view for wardens.
// Uses AuthViewModel for basic info.
// Full warden profile fetching can be extended here once
// a dedicated WardenProfileViewModel is desired.

class WardenProfileView extends StatelessWidget {
  const WardenProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myProfile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.wardenDashboard),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.wardenColor.withOpacity(0.15),
              child: Text(
                (authVM.currentUserName?.isNotEmpty == true)
                    ? authVM.currentUserName![0].toUpperCase()
                    : 'W',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.wardenColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              authVM.currentUserName ?? 'Warden',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.wardenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Warden',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.wardenColor,
                ),
              ),
            ),
            const SizedBox(height: 32),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Account Details'),
                    InfoRow(
                      label: AppStrings.email,
                      value: authVM.currentUserEmail ?? '—',
                      icon: Icons.email_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            AppSecondaryButton(
              label: AppStrings.logout,
              icon: Icons.logout,
              onPressed: () => _confirmLogout(context, authVM),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    AuthViewModel authVM,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await authVM.logout();
    }
  }
}
