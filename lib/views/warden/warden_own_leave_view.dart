// FILE: lib/views/warden/warden_own_leave_view.dart
//
// PURPOSE:
//   Screen for warden to manage their own leave.
//   Wardens have the same leave types as students:
//     - Short Leave (SL) — generates QR, 30-min validity, same rules
//     - Leave (L) — but request goes to Admin, not another warden
//   This screen shows both options in a tabbed interface.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/warden/warden_own_leave_viewmodel.dart';

class WardenOwnLeaveView extends StatelessWidget {
  const WardenOwnLeaveView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<WardenOwnLeaveViewModel>(),
      child: const _WardenOwnLeaveContent(),
    );
  }
}

class _WardenOwnLeaveContent extends StatefulWidget {
  const _WardenOwnLeaveContent();

  @override
  State<_WardenOwnLeaveContent> createState() => _WardenOwnLeaveContentState();
}

class _WardenOwnLeaveContentState extends State<_WardenOwnLeaveContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _slReasonController = TextEditingController();
  final _leaveReasonController = TextEditingController();
  final _slFormKey = GlobalKey<FormState>();
  final _leaveFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _slReasonController.dispose();
    _leaveReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WardenOwnLeaveViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.successMessage != null && mounted) {
        AppSnackbar.showSuccess(context, vm.successMessage!);
      }
      if (vm.errorMessage != null && mounted) {
        AppSnackbar.showError(context, vm.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myLeaveRequests),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.wardenDashboard),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Short Leave (SL)'),
            Tab(text: 'Leave (L)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSlTab(vm), _buildLeaveTab(vm)],
      ),
    );
  }

  // ── Short Leave Tab ────────────────────────────────────────────────────────
  Widget _buildSlTab(WardenOwnLeaveViewModel vm) {
    // If active QR exists, show it with timer
    if (vm.hasActiveSl && vm.activeSlQr != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(AppStrings.yourQrCode, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(AppStrings.qrSubtitle, style: AppTextStyles.bodySmall),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: QrImageView(
                data: vm.activeSlQr!.payload,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.qrExpiresIn, style: AppTextStyles.bodySmall),
            Text(vm.formattedSlCountdown, style: AppTextStyles.timerDisplay),
          ],
        ),
      );
    }

    // Otherwise show generation form
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _slFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.slDescription,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: AppStrings.reason,
              hint: AppStrings.reasonHint,
              controller: _slReasonController,
              validator: Validators.reason,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: AppStrings.generateQr,
              icon: Icons.qr_code,
              isLoading: vm.state == WardenLeaveScreenState.loading,
              backgroundColor: AppColors.wardenColor,
              onPressed: () {
                if (_slFormKey.currentState!.validate()) {
                  final wardenId =
                      context.read<AuthViewModel>().currentUserId ?? '';
                  vm.generateSlQr(wardenId, _slReasonController.text.trim());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Leave Tab ──────────────────────────────────────────────────────────────
  Widget _buildLeaveTab(WardenOwnLeaveViewModel vm) {
    // If there's an active/pending leave, show its status
    if (vm.hasActiveLeave && vm.activeLeave != null) {
      final leave = vm.activeLeave!;
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            StatusBadge.fromStatus(leave.status),
            const SizedBox(height: 16),
            Text(
              leave.isPending
                  ? 'Your leave request is pending Admin approval'
                  : 'Your leave has been approved',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: InfoRow(label: AppStrings.reason, value: leave.reason),
              ),
            ),
          ],
        ),
      );
    }

    // Show leave request form
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _leaveFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Your leave request will be sent to the Admin for approval.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: AppStrings.reason,
              hint: AppStrings.reasonHint,
              controller: _leaveReasonController,
              validator: Validators.reason,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Send Leave Request',
              icon: Icons.send_outlined,
              isLoading: vm.state == WardenLeaveScreenState.loading,
              backgroundColor: AppColors.accent,
              onPressed: () async {
                if (_leaveFormKey.currentState!.validate()) {
                  final wardenId =
                      context.read<AuthViewModel>().currentUserId ?? '';
                  await vm.requestLeave(
                    wardenId,
                    _leaveReasonController.text.trim(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
