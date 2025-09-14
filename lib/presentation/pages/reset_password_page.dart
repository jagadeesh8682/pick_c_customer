import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_widgets.dart';
import '../../core/routes/routes_name.dart';
import '../../core/utils/navigation_service.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../core/theme/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  final String mobileNumber;

  const ResetPasswordPage({super.key, required this.mobileNumber});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Reset Password',
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.primaryYellow,
      ),
      body: Container(
        color: AppColors.backgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Header Text
                  Text(
                    'Create a new password for',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimensions.paddingSmall),

                  Text(
                    '+91 ${widget.mobileNumber}',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimensions.paddingXLarge),

                  // New Password Field
                  CustomTextField(
                    label: 'New Password',
                    hint: 'Enter your new password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Confirm Password Field
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your new password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: AppDimensions.paddingXLarge),

                  // Reset Password Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'RESET PASSWORD',
                        onPressed: authProvider.isLoading
                            ? null
                            : _handleResetPassword,
                        isLoading: authProvider.isLoading,
                        backgroundColor: AppColors.darkBackground,
                        textColor: AppColors.primaryYellow,
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Back to Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      CustomLinkButton(
                        text: 'Login',
                        onPressed: _handleBackToLogin,
                      ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your new password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resetPassword(
        mobileNumber: widget.mobileNumber,
        newPassword: _passwordController.text,
      );

      if (success && mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Password reset successfully! You can now login with your new password.',
        );

        // Navigate back to login screen
        NavigationService.pushNamedAndRemoveUntil(
          Routes.login,
          predicate: (route) => false,
        );
      } else if (mounted) {
        CustomSnackBar.showError(
          context,
          authProvider.errorMessage ?? 'Password reset failed',
        );
      }
    }
  }

  void _handleBackToLogin() {
    NavigationService.pushNamedAndRemoveUntil(
      Routes.login,
      predicate: (route) => false,
    );
  }
}
