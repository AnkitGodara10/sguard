// FILE: lib/views/student/request_leave_view.dart
//
// PURPOSE:
//   Screen where students submit Leave (L) requests to their warden.
//   Shows different UI based on the current leave state:
//     - No active leave → shows the request form
//     - Pending approval → shows waiting state with leave details
//     - Approved → shows QR code (same as SL but with L validity rules)
//     - Rejected → shows rejection reason + option to re-submit
//
// DUPLICATE LEAVE GUARD:
//   Students cannot have multiple active leaves of the same type.
//   The ViewModel handles this — if the API returns a 409 (conflict),
//   the ViewModel sets state to duplicateError and the view shows
//   an appropriate message instead of the form.
//
// WARDEN APPROVAL FLOW:
//   Submit form → backend notifies warden → warden approves/rejects
//   → student sees status change (polling or push notification)

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
import '../../models/leave_record_model.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/student/request_leave_viewmodel.dart';

class RequestLeaveView extends StatelessWidget {
  const RequestLeaveView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<RequestLeaveViewModel>(),
      child: const _RequestLeaveContent(),
    );
  }
}

class _RequestLeaveContent extends StatefulWidget {
  const _RequestLeaveContent();

  @override
  State<_RequestLeaveContent> createState() => _RequestLeaveContentState();
}

class _RequestLeaveContentState extends State<_RequestLeaveContent> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _fathersNameController = TextEditingController();
  final _fathersPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentId = context.read<AuthViewModel>().currentUserId ?? '';
      context.read<RequestLeaveViewModel>().loadExistingLeave(studentId);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _fathersNameController.dispose();
    _fathersPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RequestLeaveViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.leaveRequest),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.studentDashboard),
        ),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(RequestLeaveViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (vm.state) {
      case LeaveRequestState.initial:
        return _buildRequestForm(vm);
      case LeaveRequestState.submitted:
        return _buildPendingState(vm.leaveRecord!);
      case LeaveRequestState.approved:
        return _buildApprovedState(vm.leaveRecord!);
      case LeaveRequestState.rejected:
        return _buildRejectedState(vm.leaveRecord!);
      case LeaveRequestState.duplicateError:
        return _buildDuplicateError();
      case LeaveRequestState.error:
        return ErrorDisplay(
          message: vm.errorMessage ?? AppStrings.somethingWentWrong,
          onRetry: () {
            final studentId = context.read<AuthViewModel>().currentUserId ?? '';
            vm.loadExistingLeave(studentId);
          },
        );
      default:
        return _buildRequestForm(vm);
    }
  }

  // ── Request Form ───────────────────────────────────────────────────────────
  Widget _buildRequestForm(RequestLeaveViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Leave Request',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.leaveDescription,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            AppTextField(
              label: AppStrings.reason,
              hint: AppStrings.reasonHint,
              controller: _reasonController,
              validator: Validators.reason,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: AppStrings.fathersName,
              hint: AppStrings.fathersNameHint,
              controller: _fathersNameController,
              validator: Validators.name,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: AppStrings.fathersPhone,
              hint: AppStrings.fathersPhoneHint,
              controller: _fathersPhoneController,
              validator: Validators.phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),

            AppPrimaryButton(
              label: AppStrings.submit,
              icon: Icons.send_outlined,
              isLoading: vm.isLoading,
              backgroundColor: AppColors.accent,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<RequestLeaveViewModel>();
    final studentId = context.read<AuthViewModel>().currentUserId ?? '';

    final success = await vm.submitLeaveRequest(
      studentId: studentId,
      reason: _reasonController.text.trim(),
      fathersName: _fathersNameController.text.trim(),
      fathersPhone: _fathersPhoneController.text.trim(),
    );

    if (success && mounted) {
      AppSnackbar.showSuccess(context, AppStrings.leaveRequestSubmitted);
    } else if (!success && mounted) {
      AppSnackbar.showError(
        context,
        vm.errorMessage ?? AppStrings.somethingWentWrong,
      );
    }
  }

  // ── Pending State ──────────────────────────────────────────────────────────
  Widget _buildPendingState(LeaveRecord leave) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.statusPending.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              size: 56,
              color: AppColors.statusPending,
            ),
          ),
          const SizedBox(height: 24),
          Text(AppStrings.pendingApproval, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Your leave request has been sent to your warden. '
            'You will be notified once it is reviewed.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // Leave details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Request Details'),
                  InfoRow(
                    label: 'Reason',
                    value: leave.reason,
                    icon: Icons.note_outlined,
                  ),
                  InfoRow(
                    label: 'Submitted',
                    value: _formatDateTime(leave.createdAt),
                    icon: Icons.access_time,
                  ),
                  InfoRow(label: 'Status', value: ''),
                  StatusBadge.pending(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Approved State (shows QR) ──────────────────────────────────────────────
  Widget _buildApprovedState(LeaveRecord leave) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 8),
              Text(
                AppStrings.requestApproved,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Show this QR at the gate', style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),

          // QR placeholder — actual QR payload from backend
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
              data: leave.id, // Backend returns QR payload via leave record
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow(
                    label: AppStrings.reason,
                    value: leave.reason,
                    icon: Icons.note_outlined,
                  ),
                  if (leave.approvedByWardenName != null)
                    InfoRow(
                      label: 'Approved by',
                      value: leave.approvedByWardenName!,
                      icon: Icons.verified_user_outlined,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Rejected State ─────────────────────────────────────────────────────────
  Widget _buildRejectedState(LeaveRecord leave) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cancel_outlined, size: 72, color: AppColors.error),
          const SizedBox(height: 24),
          Text(AppStrings.requestRejected, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          if (leave.rejectionReason != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason for rejection:',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(leave.rejectionReason!, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          const SizedBox(height: 32),
          AppPrimaryButton(
            label: 'Submit New Request',
            icon: Icons.send_outlined,
            onPressed: () =>
                context.read<RequestLeaveViewModel>()
                // Reset state to show form again
                .loadExistingLeave(
                  context.read<AuthViewModel>().currentUserId ?? '',
                ),
          ),
        ],
      ),
    );
  }

  // ── Duplicate Error ────────────────────────────────────────────────────────
  Widget _buildDuplicateError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 72,
            color: AppColors.warning,
          ),
          const SizedBox(height: 24),
          Text('Active Leave Exists', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 12),
          Text(
            AppStrings.duplicateLeaveError,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          AppSecondaryButton(
            label: 'Back to Dashboard',
            onPressed: () => context.go(RouteNames.studentDashboard),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
