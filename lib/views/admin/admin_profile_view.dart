import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sguard/core/constants/app_colors.dart';
import 'package:sguard/core/constants/app_strings.dart';
import 'package:sguard/core/constants/app_text_styles.dart';
import 'package:sguard/core/widgets/app_widgets.dart';
import 'package:sguard/routes/route_names.dart';
import 'package:sguard/viewmodels/auth/auth_viewmodel.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => context.go(RouteNames.adminDashboard),
        ),
        title: Text(AppStrings.profile, style: AppTextStyles.titleMedium),
        centerTitle: true,
      ),
      body: authVM.isLoading
          ? const AppLoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _AvatarSection(name: user?.name ?? ''),
                  const SizedBox(height: 32),
                  _InfoCard(
                    items: [
                      _InfoItem(
                        icon: Icons.person_outline,
                        label: AppStrings.name,
                        value: user?.name ?? AppStrings.notAvailable,
                      ),
                      _InfoItem(
                        icon: Icons.email_outlined,
                        label: AppStrings.email,
                        value: user?.email ?? AppStrings.notAvailable,
                      ),
                      _InfoItem(
                        icon: Icons.phone_outlined,
                        label: AppStrings.phone,
                        value: user?.phone ?? AppStrings.notAvailable,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    items: [
                      _InfoItem(
                        icon: Icons.shield_outlined,
                        label: AppStrings.role,
                        value: AppStrings.admin,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (authVM.errorMessage != null)
                    AppErrorBanner(message: authVM.errorMessage!),
                  AppPrimaryButton(
                    label: AppStrings.logout,
                    onPressed: () async {
                      await authVM.logout();
                      if (context.mounted) context.go(RouteNames.roleSelection);
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final String name;
  const _AvatarSection({required this.name});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: Text(
            _initials,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name.isEmpty ? AppStrings.admin : name,
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AppStrings.admin,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: items),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: AppTextStyles.bodyMedium),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
            indent: 48,
            endIndent: 0,
          ),
      ],
    );
  }
}
