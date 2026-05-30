// FILE: lib/views/auth/login_view.dart
//
// PURPOSE:
//   Login screen for all three roles.
//   The role is passed in via the constructor (set from route param).
//   The form is the same for all roles — email + password.
//   On submit it calls AuthViewModel.login() with the correct role.
//
// HOW IT CONNECTS TO THE VIEWMODEL:
//   This view uses context.watch<AuthViewModel>() to read state.
//   When loading, it shows a spinner on the button.
//   When error occurs, it shows a snackbar.
//   When login succeeds, the router automatically redirects (via authVM notifyListeners).
//
// NO BUSINESS LOGIC HERE:
//   All validation rules, API calls, token storage — done in ViewModel/Repository.
//   The view only handles: rendering, form submission trigger, navigation to signup.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/user_role.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  final String roleString;

  const LoginView({super.key, required this.roleString});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role,
    );

    if (!success && mounted) {
      AppSnackbar.showError(
        context,
        authVM.errorMessage ?? AppStrings.loginFailed,
      );
    }
    // On success: authVM notifyListeners → router redirect → correct dashboard
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.roleSelection),
        ),
        // Role indicator chip in app bar
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _roleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _role.displayName,
            style: AppTextStyles.labelMedium.copyWith(color: _roleColor),
          ),
        ),
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
                  AppStrings.welcomeBack,
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.loginSubtitle,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                AppTextField(
                  label: AppStrings.email,
                  hint: AppStrings.emailHint,
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password field
                AppTextField(
                  label: AppStrings.password,
                  hint: AppStrings.passwordHint,
                  controller: _passwordController,
                  validator: Validators.required,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
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

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _roleColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                AppPrimaryButton(
                  label: AppStrings.login,
                  onPressed: _onSubmit,
                  isLoading: authVM.isLoading,
                  backgroundColor: _roleColor,
                ),
                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.noAccount, style: AppTextStyles.bodyMedium),
                    GestureDetector(
                      onTap: () => context.go(
                        '${RouteNames.signup}?role=${widget.roleString}',
                      ),
                      child: Text(
                        AppStrings.signUp,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: _roleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
