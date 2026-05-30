// FILE: lib/views/warden/warden_dashboard_view.dart
//
// PURPOSE:
//   Main dashboard for wardens. Shows a summary of their hostel:
//   pending leave requests count, students currently out, total students.
//   Provides quick navigation to all warden sub-screens.

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
import '../../viewmodels/warden/warden_dashboard_viewmodel.dart';

class WardenDashboardView extends StatelessWidget {
  const WardenDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<WardenDashboardViewModel>(),
      child: const _WardenDashboardContent(),
    );
  }
}

class _WardenDashboardContent extends StatefulWidget {
  const _WardenDashboardContent();

  @override
  State<_WardenDashboardContent> createState() =>
      _WardenDashboardContentState();
}

class _WardenDashboardContentState extends State<_WardenDashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wardenId = context.read<AuthViewModel>().currentUserId ?? '';
      context.read<WardenDashboardViewModel>().loadDashboard(wardenId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WardenDashboardViewModel>();
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.wardenDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {}, // Warden profile — to implement
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.refresh(authVM.currentUserId ?? ''),
        child: vm.isLoading && vm.warden == null
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(vm, authVM),
      ),
    );
  }

  Widget _buildContent(WardenDashboardViewModel vm, AuthViewModel authVM) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting ────────────────────────────────────────────────────
          Text(
            'Hello, ${vm.warden?.name.split(' ').first ?? "Warden"} 👋',
            style: AppTextStyles.headlineMedium,
          ),
          Text(vm.warden?.hostel ?? '', style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),

          // ── Stats Row ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Pending Requests',
                  value: '${vm.pendingRequestsCount}',
                  icon: Icons.pending_actions,
                  color: vm.pendingRequestsCount > 0
                      ? AppColors.warning
                      : AppColors.success,
                  onTap: () => context.go(RouteNames.wardenLeaveRequests),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Total Students',
                  value: '${vm.totalStudentsCount}',
                  icon: Icons.people_outline,
                  color: AppColors.wardenColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Navigation Menu ───────────────────────────────────────────
          const SectionHeader(title: 'Manage'),
          _NavTile(
            icon: Icons.pending_actions,
            label: AppStrings.pendingRequests,
            subtitle: '${vm.pendingRequestsCount} pending',
            color: AppColors.warning,
            onTap: () => context.go(RouteNames.wardenLeaveRequests),
            badge: vm.pendingRequestsCount > 0
                ? '${vm.pendingRequestsCount}'
                : null,
          ),
          _NavTile(
            icon: Icons.people_outline,
            label: AppStrings.studentManagement,
            subtitle: 'View and update student details',
            color: AppColors.wardenColor,
            onTap: () => context.go(RouteNames.wardenStudentManagement),
          ),
          _NavTile(
            icon: Icons.event_note_outlined,
            label: AppStrings.myLeaveRequests,
            subtitle: 'Manage your own leave',
            color: AppColors.accent,
            onTap: () => context.go(RouteNames.wardenOwnLeave),
          ),

          const Divider(height: 32),

          // ── Logout ───────────────────────────────────────────────────
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

// ── Stat Card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.displayMedium.copyWith(color: color),
            ),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ── Navigation Tile ────────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(badge!, style: AppTextStyles.badge),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
