import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sguard/core/constants/app_colors.dart';
import 'package:sguard/core/constants/app_strings.dart';
import 'package:sguard/core/constants/app_text_styles.dart';
import 'package:sguard/core/utils/date_formatter.dart';
import 'package:sguard/core/widgets/app_widgets.dart';
import 'package:sguard/core/widgets/qr_countdown_widget.dart';
import 'package:sguard/models/leave_record_model.dart';
import 'package:sguard/routes/route_names.dart';
import 'package:sguard/viewmodels/student/student_viewmodel.dart';

/// Minimum time a student must remain outside before the return QR is shown.
const _kMinimumOutDuration = Duration(hours: 12);

class ActiveLeaveStatusView extends StatefulWidget {
  const ActiveLeaveStatusView({super.key});

  @override
  State<ActiveLeaveStatusView> createState() => _ActiveLeaveStatusViewState();
}

class _ActiveLeaveStatusViewState extends State<ActiveLeaveStatusView> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCountdown();
    });
  }

  void _startCountdown() {
    final vm = context.read<StudentViewModel>();
    final leave = vm.activeLeave;
    if (leave == null) return;

    final exitTime = leave.exitScannedAt ?? leave.fromDate;
    final returnAllowedAt = exitTime.add(_kMinimumOutDuration);
    _updateRemaining(returnAllowedAt);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining(returnAllowedAt);
    });
  }

  void _updateRemaining(DateTime returnAllowedAt) {
    final now = DateTime.now();
    final diff = returnAllowedAt.difference(now);
    if (mounted) {
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentViewModel>();
    final leave = vm.activeLeave;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => context.go(RouteNames.studentDashboard),
        ),
        title: Text(AppStrings.activeLeave, style: AppTextStyles.titleMedium),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const AppLoadingIndicator()
          : leave == null
          ? _EmptyState(onBack: () => context.go(RouteNames.studentDashboard))
          : _LeaveActiveBody(leave: leave, remaining: _remaining),
    );
  }
}

// ---------------------------------------------------------------------------
// Main body
// ---------------------------------------------------------------------------

class _LeaveActiveBody extends StatelessWidget {
  final LeaveRecordModel leave;
  final Duration remaining;

  const _LeaveActiveBody({required this.leave, required this.remaining});

  bool get _returnAllowed => remaining == Duration.zero;

  @override
  Widget build(BuildContext context) {
    final exitTime = leave.exitScannedAt ?? leave.fromDate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          // Status banner
          _OutStatusBanner(),
          const SizedBox(height: 24),
          // Exit time
          _InfoRow(
            icon: Icons.login_outlined,
            label: AppStrings.exitTime,
            value: DateFormatter.displayTime(exitTime),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: AppStrings.leaveDate,
            value: DateFormatter.displayDate(exitTime),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.description_outlined,
            label: AppStrings.reason,
            value: leave.reason,
          ),
          const SizedBox(height: 32),
          // Countdown / QR section
          _returnAllowed
              ? _ReturnQrSection(leave: leave)
              : _CountdownSection(remaining: remaining),
        ],
      ),
    );
  }
}

class _OutStatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_walk, color: AppColors.warning, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.currentlyOut,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.returnQrAvailableAfter12Hours,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownSection extends StatelessWidget {
  final Duration remaining;
  const _CountdownSection({required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.minimumTimeRemaining,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        QrCountdownWidget(
          remainingTime: remaining,
          totalTime: _kMinimumOutDuration,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.scanReturnQrAfterCountdown,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ReturnQrSection extends StatelessWidget {
  final LeaveRecordModel leave;
  const _ReturnQrSection({required this.leave});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withOpacity(0.4)),
          ),
          child: Text(
            AppStrings.returnQrReady,
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.success),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: QrImageView(
            data: leave.returnQrPayload ?? leave.id,
            version: QrVersions.auto,
            size: 200,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.textPrimary,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.showReturnQrToWarden,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBack;
  const _EmptyState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(AppStrings.noActiveLeave, style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            AppStrings.noActiveLeaveDescription,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(label: AppStrings.goBack, onPressed: onBack),
        ],
      ),
    );
  }
}
