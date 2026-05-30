// FILE: lib/views/student/student_profile_view.dart
//
// PURPOSE:
//   Student profile screen. Shows all profile details and allows editing
//   of the three fields students are permitted to change:
//     - Phone number
//     - Email address
//     - Father's phone number
//
// All other fields (name, hostel, room) are read-only — wardens and admins
// manage those through their own screens.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/student/student_profile_viewmodel.dart';

class StudentProfileView extends StatelessWidget {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<StudentProfileViewModel>(),
      child: const _StudentProfileContent(),
    );
  }
}

class _StudentProfileContent extends StatefulWidget {
  const _StudentProfileContent();

  @override
  State<_StudentProfileContent> createState() => _StudentProfileContentState();
}

class _StudentProfileContentState extends State<_StudentProfileContent> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _fathersPhoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentId = context.read<AuthViewModel>().currentUserId ?? '';
      context.read<StudentProfileViewModel>().loadProfile(studentId);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _fathersPhoneController.dispose();
    super.dispose();
  }

  void _populateFields(StudentProfileViewModel vm) {
    if (vm.student != null) {
      _phoneController.text = vm.student!.phone;
      _emailController.text = vm.student!.email;
      _fathersPhoneController.text = vm.student!.fathersPhone ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentProfileViewModel>();

    // Show success/error snackbars
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.successMessage != null && mounted) {
        AppSnackbar.showSuccess(context, vm.successMessage!);
        vm.clearMessages();
      }
      if (vm.errorMessage != null && mounted) {
        AppSnackbar.showError(context, vm.errorMessage!);
        vm.clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myProfile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.studentDashboard),
        ),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () {
                _populateFields(vm);
                setState(() => _isEditing = true);
              },
              child: const Text(AppStrings.edit),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text(AppStrings.cancel),
            ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.student == null
          ? const Center(child: Text('Profile not found'))
          : _buildProfile(vm),
    );
  }

  Widget _buildProfile(StudentProfileViewModel vm) {
    final student = vm.student!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.studentColor.withOpacity(0.15),
            child: Text(
              student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.studentColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(student.name, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(
            '${student.hostelNumber} · Room ${student.roomNumber}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),

          // Read-only fields
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Academic Details'),
                  if (student.rollNumber != null)
                    InfoRow(
                      label: AppStrings.rollNumber,
                      value: student.rollNumber!,
                      icon: Icons.badge_outlined,
                    ),
                  if (student.year != null)
                    InfoRow(
                      label: AppStrings.year,
                      value: student.year!,
                      icon: Icons.school_outlined,
                    ),
                  InfoRow(
                    label: AppStrings.hostelNumber,
                    value: student.hostelNumber,
                    icon: Icons.apartment_outlined,
                  ),
                  InfoRow(
                    label: AppStrings.roomNumber,
                    value: student.roomNumber,
                    icon: Icons.door_back_door_outlined,
                  ),
                  if (student.fathersName != null)
                    InfoRow(
                      label: AppStrings.fathersName,
                      value: student.fathersName!,
                      icon: Icons.person_outline,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Editable fields
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Contact Details'),
                    if (!_isEditing) ...[
                      InfoRow(
                        label: AppStrings.phone,
                        value: student.phone,
                        icon: Icons.phone_outlined,
                      ),
                      InfoRow(
                        label: AppStrings.email,
                        value: student.email,
                        icon: Icons.email_outlined,
                      ),
                      InfoRow(
                        label: AppStrings.fathersPhone,
                        value: student.fathersPhone ?? '—',
                        icon: Icons.phone_outlined,
                      ),
                    ] else ...[
                      AppTextField(
                        label: AppStrings.phone,
                        controller: _phoneController,
                        validator: Validators.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: AppStrings.email,
                        controller: _emailController,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: AppStrings.fathersPhone,
                        controller: _fathersPhoneController,
                        validator: Validators.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      AppPrimaryButton(
                        label: AppStrings.save,
                        isLoading: vm.isUpdating,
                        onPressed: _save,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<StudentProfileViewModel>();
    final studentId = context.read<AuthViewModel>().currentUserId ?? '';

    final success = await vm.updateProfile(
      studentId,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      fathersPhone: _fathersPhoneController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _isEditing = false);
    }
  }
}
