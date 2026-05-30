// FILE: lib/views/admin/admin_dashboard_view.dart
//
// PURPOSE:
//   Main dashboard for admin users. Shows high-level system stats
//   (total students, wardens, scanners, pending warden leave requests)
//   and navigation to all admin sub-screens.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AdminDashboardViewModel>(),
      child: const _AdminDashboardContent(),
    );
  }
}

class _AdminDashboardContent extends StatefulWidget {
  const _AdminDashboardContent();

  @override
  State<_AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<_AdminDashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDashboardViewModel>();
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminDashboard),
        backgroundColor: AppColors.adminColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.loadDashboard(),
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(vm, authVM),
      ),
    );
  }

  Widget _buildContent(AdminDashboardViewModel vm, AuthViewModel authVM) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting ────────────────────────────────────────────────────
          Text('Admin Dashboard', style: AppTextStyles.headlineMedium),
          Text(
            'System overview and management',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),

          // ── Stats Grid ────────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatTile(
                label: 'Students',
                value: '${vm.totalStudents}',
                icon: Icons.school_outlined,
                color: AppColors.studentColor,
                onTap: () => context.go(RouteNames.adminStudentList),
              ),
              _StatTile(
                label: 'Wardens',
                value: '${vm.totalWardens}',
                icon: Icons.manage_accounts_outlined,
                color: AppColors.wardenColor,
                onTap: () => context.go(RouteNames.adminWardenList),
              ),
              _StatTile(
                label: 'Scanners',
                value: '${vm.totalScanners}',
                icon: Icons.qr_code_scanner,
                color: AppColors.adminColor,
                onTap: () => context.go(RouteNames.adminScannerManagement),
              ),
              _StatTile(
                label: 'Warden Leaves',
                value: '${vm.pendingWardenLeaves}',
                icon: Icons.pending_actions,
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Management Menu ───────────────────────────────────────────
          const SectionHeader(title: 'Management'),
          _MenuTile(
            icon: Icons.school_outlined,
            label: AppStrings.studentList,
            subtitle: 'Add and view students',
            color: AppColors.studentColor,
            onTap: () => context.go(RouteNames.adminStudentList),
          ),
          _MenuTile(
            icon: Icons.manage_accounts_outlined,
            label: AppStrings.wardenList,
            subtitle: 'Add and view wardens',
            color: AppColors.wardenColor,
            onTap: () => context.go(RouteNames.adminWardenList),
          ),
          _MenuTile(
            icon: Icons.qr_code_scanner,
            label: AppStrings.scannerManagement,
            subtitle: 'Register and manage gate scanners',
            color: AppColors.adminColor,
            onTap: () => context.go(RouteNames.adminScannerManagement),
          ),
          _MenuTile(
            icon: Icons.bar_chart_outlined,
            label: AppStrings.reports,
            subtitle: 'View all leave records',
            color: AppColors.info,
            onTap: () => context.go(RouteNames.adminReports),
          ),

          const Divider(height: 32),

          ListTile(
            onTap: () => _confirmLogout(context, authVM),
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: AppColors.error),
            ),
            title: Text(
              AppStrings.logout,
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.headlineLarge.copyWith(color: color),
                ),
                Text(label, style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: AppTextStyles.titleSmall),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.textSecondary,
      ),
    );
  }
}
