// FILE: lib/views/student/student_dashboard_view.dart
//
// PURPOSE:
//   The main home screen for logged-in students.
//   Shows current campus status, quick action cards for SL and Leave,
//   and a summary of recent leave activity.
//
// HOW IT WORKS:
//   1. On init, provides StudentDashboardViewModel via ChangeNotifierProvider
//   2. Calls viewModel.loadDashboard(studentId) in initState
//   3. Reads state from viewModel using context.watch
//   4. Navigation buttons use context.go() to route to sub-screens
//
// PROVIDER PATTERN:
//   The ViewModel is provided HERE (not in the router) because its lifecycle
//   is tied to this screen. When the user navigates away, the ViewModel
//   is disposed. Fresh state on every visit.

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
import '../../viewmodels/student/student_dashboard_viewmodel.dart';

class StudentDashboardView extends StatelessWidget {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel locally — scoped to this screen
    return ChangeNotifierProvider(
      create: (_) => getIt<StudentDashboardViewModel>(),
      child: const _StudentDashboardContent(),
    );
  }
}

class _StudentDashboardContent extends StatefulWidget {
  const _StudentDashboardContent();

  @override
  State<_StudentDashboardContent> createState() =>
      _StudentDashboardContentState();
}

class _StudentDashboardContentState extends State<_StudentDashboardContent> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentId = context.read<AuthViewModel>().currentUserId ?? '';
      context.read<StudentDashboardViewModel>().loadDashboard(studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentDashboardViewModel>();
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.studentDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go(RouteNames.studentProfile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.refresh(authVM.currentUserId ?? ''),
        child: _buildBody(vm, authVM),
      ),
    );
  }

  Widget _buildBody(StudentDashboardViewModel vm, AuthViewModel authVM) {
    if (vm.isLoading && vm.student == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.hasError) {
      return ErrorDisplay(
        message: vm.errorMessage ?? AppStrings.somethingWentWrong,
        onRetry: () => vm.refresh(authVM.currentUserId ?? ''),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting ────────────────────────────────────────────────────
          Text(
            'Hello, ${vm.student?.name.split(' ').first ?? "Student"} 👋',
            style: AppTextStyles.headlineMedium,
          ),
          Text(
            '${vm.student?.hostelNumber ?? ""} · Room ${vm.student?.roomNumber ?? ""}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),

          // ── Status Card ──────────────────────────────────────────────────
          _StatusCard(isOut: vm.isCurrentlyOut, statusLabel: vm.statusLabel),
          const SizedBox(height: 24),

          // ── Quick Actions ────────────────────────────────────────────────
          const SectionHeader(title: 'Quick Actions'),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  title: AppStrings.shortLeave,
                  subtitle: 'Valid 30 min',
                  icon: Icons.timer_outlined,
                  color: AppColors.studentColor,
                  badge: vm.hasActiveSlQr ? 'Active QR' : null,
                  onTap: () => context.go(RouteNames.studentGenerateSlQr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  title: AppStrings.leave,
                  subtitle: 'Warden approval',
                  icon: Icons.event_outlined,
                  color: AppColors.accent,
                  badge: vm.activeLeave != null
                      ? vm.activeLeave!.status == 'pending_approval'
                            ? 'Pending'
                            : 'Active'
                      : null,
                  onTap: () => context.go(RouteNames.studentRequestLeave),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── History Link ─────────────────────────────────────────────────
          ListTile(
            onTap: () => context.go(RouteNames.studentHistory),
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.history, color: AppColors.primary),
            ),
            title: Text(
              AppStrings.leaveHistory,
              style: AppTextStyles.titleSmall,
            ),
            subtitle: Text(
              'View your SL and Leave records',
              style: AppTextStyles.bodySmall,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          ),

          const Divider(height: 1),

          // ── Logout ───────────────────────────────────────────────────────
          const SizedBox(height: 8),
          ListTile(
            onTap: () => _confirmLogout(context),
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

  Future<void> _confirmLogout(BuildContext context) async {
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
      await context.read<AuthViewModel>().logout();
    }
  }
}

// ── Status Card ────────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final bool isOut;
  final String statusLabel;

  const _StatusCard({required this.isOut, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    final color = isOut ? AppColors.warning : AppColors.success;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOut ? Icons.directions_walk : Icons.home_outlined,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Status', style: AppTextStyles.bodySmall),
              Text(
                statusLabel,
                style: AppTextStyles.titleMedium.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Action Card ────────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.labelSmall.copyWith(color: color),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.titleSmall.copyWith(color: color)),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
