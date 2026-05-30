// FILE: lib/views/warden/leave_requests_view.dart
//
// PURPOSE:
//   Warden screen showing all pending student leave requests.
//   Each request card shows: student name, room number, reason,
//   student phone, father's name, father's phone.
//   Warden can approve or reject each request.
//   Rejection requires entering a reason.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../models/leave_record_model.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/warden/leave_requests_viewmodel.dart';

class LeaveRequestsView extends StatelessWidget {
  const LeaveRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<LeaveRequestsViewModel>(),
      child: const _LeaveRequestsContent(),
    );
  }
}

class _LeaveRequestsContent extends StatefulWidget {
  const _LeaveRequestsContent();

  @override
  State<_LeaveRequestsContent> createState() => _LeaveRequestsContentState();
}

class _LeaveRequestsContentState extends State<_LeaveRequestsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wardenId = context.read<AuthViewModel>().currentUserId ?? '';
      context.read<LeaveRequestsViewModel>().loadRequests(wardenId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeaveRequestsViewModel>();

    // Handle action feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.actionSuccess != null && mounted) {
        AppSnackbar.showSuccess(context, vm.actionSuccess!);
        vm.clearMessages();
      }
      if (vm.errorMessage != null && mounted) {
        AppSnackbar.showError(context, vm.errorMessage!);
        vm.clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.pendingRequests),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.wardenDashboard),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          final wardenId = context.read<AuthViewModel>().currentUserId ?? '';
          return context.read<LeaveRequestsViewModel>().loadRequests(wardenId);
        },
        child: _buildBody(vm),
      ),
    );
  }

  Widget _buildBody(LeaveRequestsViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.requests.isEmpty) {
      return const EmptyState(
        message: AppStrings.noLeaveRequests,
        icon: Icons.inbox_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vm.requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _LeaveRequestCard(
        request: vm.requests[i],
        isProcessing: vm.isProcessing(vm.requests[i].id),
        onApprove: () => _onApprove(vm, vm.requests[i]),
        onReject: () => _onReject(vm, vm.requests[i]),
      ),
    );
  }

  void _onApprove(LeaveRequestsViewModel vm, LeaveRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Leave'),
        content: Text(
          'Approve leave request for ${request.studentName}?\n\n'
          'A QR code will be generated for the student.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Approve', style: TextStyle(color: AppColors.success)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await vm.approveRequest(request.id, request.studentName);
    }
  }

  void _onReject(LeaveRequestsViewModel vm, LeaveRequest request) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Leave'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject leave for ${request.studentName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Enter reason (optional)',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Reject', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await vm.rejectRequest(
        request.id,
        request.studentName,
        reasonController.text.trim(),
      );
    }
    reasonController.dispose();
  }
}

// ── Leave Request Card ─────────────────────────────────────────────────────────

class _LeaveRequestCard extends StatelessWidget {
  final LeaveRequest request;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _LeaveRequestCard({
    required this.request,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student name + timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.studentName,
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                Text(
                  DateFormatter.relativeTime(request.requestedAt),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Warden view fields from spec:
            // student name, room number, reason, student phone,
            // father's name, father's phone
            InfoRow(
              label: 'Room',
              value: '${request.hostelNumber} · ${request.roomNumber}',
              icon: Icons.door_back_door_outlined,
            ),
            InfoRow(
              label: AppStrings.reason,
              value: request.reason,
              icon: Icons.note_outlined,
            ),
            InfoRow(
              label: 'Student Phone',
              value: request.phone,
              icon: Icons.phone_outlined,
            ),
            if (request.fathersName != null)
              InfoRow(
                label: AppStrings.fathersName,
                value: request.fathersName!,
                icon: Icons.person_outline,
              ),
            if (request.fathersPhone != null)
              InfoRow(
                label: AppStrings.fathersPhone,
                value: request.fathersPhone!,
                icon: Icons.phone_outlined,
              ),

            const SizedBox(height: 16),

            // Action buttons
            isProcessing
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: AppSecondaryButton(
                          label: AppStrings.reject,
                          onPressed: onReject,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppPrimaryButton(
                          label: AppStrings.approve,
                          onPressed: onApprove,
                          backgroundColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
