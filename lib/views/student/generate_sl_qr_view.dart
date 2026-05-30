// FILE: lib/views/student/generate_sl_qr_view.dart
//
// PURPOSE:
//   Screen where students generate their Short Leave QR code.
//   Displays the QR code, countdown timer, and scan status.
//
// VIEW STATES (driven by GenerateSlQrViewModel):
//   readyToGenerate → Shows reason input + Generate button
//   loading         → Shows spinner
//   active          → Shows QR + countdown timer
//   scanning        → Shows QR + "exit recorded" message (no timer)
//   used            → Shows "entry recorded" + return to dashboard button
//   expired         → Shows expiry message + regenerate button
//   error           → Shows error + retry

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart' as s;
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/student/generate_sl_qr_viewmodel.dart';

class GenerateSlQrView extends StatelessWidget {
  const GenerateSlQrView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<GenerateSlQrViewModel>(),
      child: const _GenerateSlQrContent(),
    );
  }
}

class _GenerateSlQrContent extends StatefulWidget {
  const _GenerateSlQrContent();

  @override
  State<_GenerateSlQrContent> createState() => _GenerateSlQrContentState();
}

class _GenerateSlQrContentState extends State<_GenerateSlQrContent> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentId = context.read<AuthViewModel>().currentUserId ?? '';
      context.read<GenerateSlQrViewModel>().loadScreen(studentId);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GenerateSlQrViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Short Leave QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.studentDashboard),
        ),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(GenerateSlQrViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (vm.state) {
      case QrScreenState.readyToGenerate:
        return _buildGenerateForm(vm);
      case QrScreenState.active:
        return _buildQrDisplay(vm);
      case QrScreenState.scanning:
        return _buildScanningState(vm);
      case QrScreenState.used:
        return _buildUsedState();
      case QrScreenState.expired:
        return _buildExpiredState(vm);
      case QrScreenState.error:
        return ErrorDisplay(
          message: vm.errorMessage ?? s.AppStrings.somethingWentWrong,
          onRetry: () {
            final studentId = context.read<AuthViewModel>().currentUserId ?? '';
            vm.loadScreen(studentId);
          },
        );
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  // ── Generate Form ──────────────────────────────────────────────────────────
  Widget _buildGenerateForm(GenerateSlQrViewModel vm) {
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
                color: AppColors.studentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.studentColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.studentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.AppStrings.slDescription,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.studentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppTextField(
              label: s.AppStrings.reason,
              hint: s.AppStrings.reasonHint,
              controller: _reasonController,
              validator: Validators.reason,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            AppPrimaryButton(
              label: s.AppStrings.generateQr,
              icon: Icons.qr_code,
              isLoading: vm.isLoading,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final studentId =
                      context.read<AuthViewModel>().currentUserId ?? '';
                  vm.generateQr(studentId, _reasonController.text.trim());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── QR Display (Active State) ──────────────────────────────────────────────
  Widget _buildQrDisplay(GenerateSlQrViewModel vm) {
    final minutes = vm.remainingTime.inMinutes;
    final isExpiringSoon = minutes < 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(s.AppStrings.yourQrCode, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            s.AppStrings.qrSubtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // QR Code
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: vm.qrCode?.payload ?? '',
              version: QrVersions.auto,
              size: 240,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // Countdown timer
          Text(s.AppStrings.qrExpiresIn, style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Text(
            vm.formattedCountdown,
            style: AppTextStyles.timerDisplay.copyWith(
              color: isExpiringSoon ? AppColors.error : AppColors.primary,
            ),
          ),
          if (isExpiringSoon)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'QR expiring soon! Use it now.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
          const SizedBox(height: 8),
          Text('minutes : seconds', style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  // ── Scanning State (After First Scan) ─────────────────────────────────────
  Widget _buildScanningState(GenerateSlQrViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_walk,
              size: 64,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 24),
          Text('Exit Recorded', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            s.AppStrings.qrScannedOnce,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Show this QR code when you return',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 32),

          // Still show the QR for return scan
          if (vm.qrCode != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: QrImageView(
                data: vm.qrCode!.payload,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  // ── Used State (After Second Scan) ────────────────────────────────────────
  Widget _buildUsedState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home, size: 64, color: AppColors.success),
          ),
          const SizedBox(height: 24),
          Text('Entry Recorded', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            s.AppStrings.qrScannedTwice,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          AppPrimaryButton(
            label: 'Back to Dashboard',
            onPressed: () => context.go(RouteNames.studentDashboard),
            icon: Icons.home_outlined,
          ),
        ],
      ),
    );
  }

  // ── Expired State ──────────────────────────────────────────────────────────
  Widget _buildExpiredState(GenerateSlQrViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_off_outlined,
            size: 72,
            color: AppColors.statusExpired,
          ),
          const SizedBox(height: 24),
          Text(s.AppStrings.qrExpired, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            s.AppStrings.qrExpiredMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          if (vm.canRegenerate)
            AppPrimaryButton(
              label: s.AppStrings.regenerateQr,
              icon: Icons.qr_code,
              onPressed: () => setState(() {
                // Reset to form state
                _reasonController.clear();
              }),
            ),
        ],
      ),
    );
  }
}
