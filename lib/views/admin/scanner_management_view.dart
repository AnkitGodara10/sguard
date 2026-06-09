// FILE: lib/views/admin/scanner_management_view.dart
//
// PURPOSE:
//   Admin screen to register and manage gate scanner devices.
//   Only admin-registered scanners can process QR codes.
//   Shows all registered scanners with active/inactive status.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../models/scanner_model.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/admin/scanner_management_viewmodel.dart';

class ScannerManagementView extends StatelessWidget {
  const ScannerManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ScannerManagementViewModel>(),
      child: const _ScannerManagementContent(),
    );
  }
}

class _ScannerManagementContent extends StatefulWidget {
  const _ScannerManagementContent();

  @override
  State<_ScannerManagementContent> createState() =>
      _ScannerManagementContentState();
}

class _ScannerManagementContentState extends State<_ScannerManagementContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScannerManagementViewModel>().loadScanners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScannerManagementViewModel>();

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
        title: const Text(AppStrings.scannerManagement),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.adminDashboard),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterScannerSheet(context, vm),
        backgroundColor: AppColors.adminColor,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.registerScanner),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.scanners.isEmpty
          ? const EmptyState(
              message: AppStrings.noScanners,
              icon: Icons.qr_code_scanner,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vm.scanners.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ScannerCard(
                scanner: vm.scanners[i],
                onDeactivate: () => vm.deactivateScanner(vm.scanners[i].id),
              ),
            ),
    );
  }

  void _showRegisterScannerSheet(
    BuildContext context,
    ScannerManagementViewModel vm,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final deviceIdCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.registerScanner,
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: AppStrings.scannerName,
                  hint: AppStrings.scannerNameHint,
                  controller: nameCtrl,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: AppStrings.scannerLocation,
                  hint: AppStrings.scannerLocationHint,
                  controller: locationCtrl,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Device ID',
                  hint: 'Unique hardware ID of the scanner',
                  controller: deviceIdCtrl,
                  validator: Validators.required,
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: 'Register',
                  isLoading: vm.isRegistering,
                  backgroundColor: AppColors.adminColor,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final success = await vm.registerScanner(
                      name: nameCtrl.text.trim(),
                      location: locationCtrl.text.trim(),
                      deviceId: deviceIdCtrl.text.trim(),
                    );
                    if (success && ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScannerCard extends StatelessWidget {
  final ScannerModel scanner;
  final VoidCallback onDeactivate;

  const _ScannerCard({required this.scanner, required this.onDeactivate});

  @override
  Widget build(BuildContext context) {
    final isActive = scanner.isActive;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                color: isActive ? AppColors.success : AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scanner.name, style: AppTextStyles.titleSmall),
                  Text(scanner.location, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatusBadge(
                        label: isActive
                            ? AppStrings.scannerActive
                            : AppStrings.scannerInactive,
                        color: isActive ? AppColors.success : AppColors.error,
                      ),
                      if (scanner.lastActiveAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Last: ${DateFormatter.relativeTime(scanner.lastActiveAt!)}',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isActive)
              IconButton(
                icon: const Icon(
                  Icons.power_settings_new,
                  color: AppColors.error,
                ),
                onPressed: onDeactivate,
                tooltip: 'Deactivate',
              ),
          ],
        ),
      ),
    );
  }
}
