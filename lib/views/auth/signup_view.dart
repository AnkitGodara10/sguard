// FILE: lib/views/auth/signup_view.dart
//
// PURPOSE:
//   Signup screen that adapts its form fields based on user role.
//   Student, Warden, and Admin each require different registration fields
//   as per the spec. Instead of 3 separate signup screens, we use one
//   screen that shows/hides fields based on the role.
//
// ROLE-SPECIFIC FIELDS:
//   Student: name, phone, email, hostel number, room number, password
//   Warden:  warden ID, name, phone, email, hostel, password
//   Admin:   name, phone, email, password (no institutional ID)
//
// FORM SUBMISSION:
//   Calls the appropriate AuthViewModel.signupStudent/Warden/Admin method.
//   On success, AuthViewModel auto-logs in and router redirects to dashboard.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/auth_model.dart';
import '../../models/user_role.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';

class SignupView extends StatefulWidget {
  final String roleString;

  const SignupView({super.key, required this.roleString});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();

  // Common controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Student-specific
  final _hostelNumberController = TextEditingController();
  final _roomNumberController = TextEditingController();

  // Warden-specific
  final _wardenIdController = TextEditingController();
  final _hostelController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late UserRole _role;
  late Color _roleColor;

  @override
  void initState() {
    super.initState();
    _role = UserRole.fromString(widget.roleString) ?? UserRole.student;
    _roleColor = _colorForRole(_role);
  }

  Color _colorForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.studentColor;
      case UserRole.warden:
        return AppColors.wardenColor;
      case UserRole.admin:
        return AppColors.adminColor;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _hostelNumberController.dispose();
    _roomNumberController.dispose();
    _wardenIdController.dispose();
    _hostelController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    bool success = false;

    switch (_role) {
      case UserRole.student:
        success = await authVM.signupStudent(
          StudentSignupRequest(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            hostelNumber: _hostelNumberController.text.trim(),
            roomNumber: _roomNumberController.text.trim(),
          ),
        );
        break;

      case UserRole.warden:
        success = await authVM.signupWarden(
          WardenSignupRequest(
            wardenId: _wardenIdController.text.trim(),
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            hostel: _hostelController.text.trim(),
          ),
        );
        break;

      case UserRole.admin:
        success = await authVM.signupAdmin(
          AdminSignupRequest(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
        break;
    }

    if (!success && mounted) {
      AppSnackbar.showError(
        context,
        authVM.errorMessage ?? AppStrings.somethingWentWrong,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () =>
              context.go('${RouteNames.login}?role=${widget.roleString}'),
        ),
        title: Text('Sign Up as ${_role.displayName}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.createAccount,
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.signupSubtitle,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Role-specific fields ───────────────────────────────────

                // Warden ID (warden only)
                if (_role == UserRole.warden) ...[
                  AppTextField(
                    label: AppStrings.wardenId,
                    hint: AppStrings.wardenIdHint,
                    controller: _wardenIdController,
                    validator: Validators.wardenId,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                ],

                // Name (all roles)
                AppTextField(
                  label: AppStrings.name,
                  hint: AppStrings.nameHint,
                  controller: _nameController,
                  validator: Validators.name,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Phone (all roles)
                AppTextField(
                  label: AppStrings.phone,
                  hint: AppStrings.phoneHint,
                  controller: _phoneController,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Email (all roles)
                AppTextField(
                  label: AppStrings.email,
                  hint: AppStrings.emailHint,
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Hostel number (student only)
                if (_role == UserRole.student) ...[
                  AppTextField(
                    label: AppStrings.hostelNumber,
                    hint: AppStrings.hostelNumberHint,
                    controller: _hostelNumberController,
                    validator: Validators.hostelNumber,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: AppStrings.roomNumber,
                    hint: AppStrings.roomNumberHint,
                    controller: _roomNumberController,
                    validator: Validators.roomNumber,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                ],

                // Hostel (warden only)
                if (_role == UserRole.warden) ...[
                  AppTextField(
                    label: AppStrings.hostel,
                    hint: AppStrings.hostelHint,
                    controller: _hostelController,
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                ],

                // Password (all roles)
                AppTextField(
                  label: AppStrings.password,
                  hint: AppStrings.passwordHint,
                  controller: _passwordController,
                  validator: Validators.password,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                AppTextField(
                  label: AppStrings.confirmPassword,
                  hint: AppStrings.confirmPasswordHint,
                  controller: _confirmPasswordController,
                  validator: Validators.confirmPassword(
                    _passwordController.text,
                  ),
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 32),

                AppPrimaryButton(
                  label: 'Create Account',
                  onPressed: _onSubmit,
                  isLoading: authVM.isLoading,
                  backgroundColor: _roleColor,
                ),
                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => context.go(
                        '${RouteNames.login}?role=${widget.roleString}',
                      ),
                      child: Text(
                        'Log In',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: _roleColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
