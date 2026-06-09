// FILE: lib/views/admin/admin_student_list_view.dart
//
// PURPOSE:
//   Admin screen to view and add students to the master list.
//   Shows serial number, roll number, name, year, father's name, father's phone.
//   Admin can add new students via a bottom sheet form.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../models/student_model.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/admin/admin_student_list_viewmodel.dart';

class AdminStudentListView extends StatelessWidget {
  const AdminStudentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AdminStudentListViewModel>(),
      child: const _AdminStudentListContent(),
    );
  }
}

class _AdminStudentListContent extends StatefulWidget {
  const _AdminStudentListContent();

  @override
  State<_AdminStudentListContent> createState() =>
      _AdminStudentListContentState();
}

class _AdminStudentListContentState extends State<_AdminStudentListContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStudentListViewModel>().loadStudents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminStudentListViewModel>();

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
        title: const Text(AppStrings.studentList),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.adminDashboard),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentSheet(context, vm),
        backgroundColor: AppColors.adminColor,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addStudent),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name or roll number...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: vm.setSearch,
            ),
          ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.filteredStudents.isEmpty
                ? const EmptyState(
                    message: 'No students in master list',
                    icon: Icons.school_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.filteredStudents.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _StudentMasterCard(student: vm.filteredStudents[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddStudentSheet(
    BuildContext context,
    AdminStudentListViewModel vm,
  ) {
    final formKey = GlobalKey<FormState>();
    final rollController = TextEditingController();
    final nameController = TextEditingController();
    final yearController = TextEditingController();
    final fatherNameController = TextEditingController();
    final fatherPhoneController = TextEditingController();

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
                Text(AppStrings.addStudent, style: AppTextStyles.titleLarge),
                const SizedBox(height: 20),
                AppTextField(
                  label: AppStrings.rollNumber,
                  hint: AppStrings.rollNumberHint,
                  controller: rollController,
                  validator: Validators.rollNumber,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: AppStrings.name,
                  hint: AppStrings.nameHint,
                  controller: nameController,
                  validator: Validators.name,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: AppStrings.year,
                  hint: AppStrings.yearHint,
                  controller: yearController,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: AppStrings.fathersName,
                  hint: AppStrings.fathersNameHint,
                  controller: fatherNameController,
                  validator: Validators.name,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: AppStrings.fathersPhone,
                  hint: AppStrings.fathersPhoneHint,
                  controller: fatherPhoneController,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                AppPrimaryButton(
                  label: AppStrings.addStudent,
                  isLoading: vm.isAdding,
                  backgroundColor: AppColors.adminColor,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final success = await vm.addStudent(
                      rollNumber: rollController.text.trim(),
                      name: nameController.text.trim(),
                      year: yearController.text.trim(),
                      fathersName: fatherNameController.text.trim(),
                      fathersPhone: fatherPhoneController.text.trim(),
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

class _StudentMasterCard extends StatelessWidget {
  final StudentMasterRecord student;

  const _StudentMasterCard({required this.student});

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
                color: AppColors.adminColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${student.serialNumber}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.adminColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: AppTextStyles.titleSmall),
                  Text(
                    '${student.rollNumber} · ${student.year}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
