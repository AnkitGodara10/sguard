// FILE: lib/views/admin/admin_warden_list_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../models/warden_model.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/admin/admin_warden_list_viewmodel.dart';

class AdminWardenListView extends StatelessWidget {
  const AdminWardenListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AdminWardenListViewModel>(),
      child: const _AdminWardenListContent(),
    );
  }
}

class _AdminWardenListContent extends StatefulWidget {
  const _AdminWardenListContent();

  @override
  State<_AdminWardenListContent> createState() =>
      _AdminWardenListContentState();
}

class _AdminWardenListContentState extends State<_AdminWardenListContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminWardenListViewModel>().loadWardens();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminWardenListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.wardenList),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.adminDashboard),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWardenSheet(context, vm),
        backgroundColor: AppColors.wardenColor,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addWarden),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name, warden ID, hostel...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: vm.setSearch,
            ),
          ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.filteredWardens.isEmpty
                ? const EmptyState(
                    message: 'No wardens in master list',
                    icon: Icons.manage_accounts_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.filteredWardens.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _WardenMasterCard(warden: vm.filteredWardens[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddWardenSheet(BuildContext context, AdminWardenListViewModel vm) {
    final formKey = GlobalKey<FormState>();
    final wardenIdCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final hostelCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

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
                Text(AppStrings.addWarden, style: AppTextStyles.titleLarge),
                const SizedBox(height: 20),
                AppTextField(
                  label: AppStrings.wardenId,
                  hint: AppStrings.wardenIdHint,
                  controller: wardenIdCtrl,
                  validator: Validators.wardenId,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: AppStrings.name,
                  hint: AppStrings.nameHint,
                  controller: nameCtrl,
                  validator: Validators.name,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: AppStrings.hostel,
                  hint: AppStrings.hostelHint,
                  controller: hostelCtrl,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: AppStrings.phone,
                  hint: AppStrings.phoneHint,
                  controller: phoneCtrl,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: AppStrings.addWarden,
                  isLoading: vm.isAdding,
                  backgroundColor: AppColors.wardenColor,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final success = await vm.addWarden(
                      wardenId: wardenIdCtrl.text.trim(),
                      name: nameCtrl.text.trim(),
                      hostel: hostelCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
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

class _WardenMasterCard extends StatelessWidget {
  final WardenMasterRecord warden;

  const _WardenMasterCard({required this.warden});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.wardenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${warden.serialNumber}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.wardenColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(warden.name, style: AppTextStyles.titleSmall),
                  Text(
                    '${warden.wardenId} · ${warden.hostel}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Text(warden.phone, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
