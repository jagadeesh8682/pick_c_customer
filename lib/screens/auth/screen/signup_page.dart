import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../repo/auth_models.dart';
import 'custom_widgets.dart';
import '../../../core/utils/navigation_service.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/theme/app_colors.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Register',
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.primaryYellow,
      ),
      body: Container(
        color: AppColors.backgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Full Name Field
                  CustomTextField(
                    label: 'Full name *',
                    hint: 'Enter your full name',
                    controller: _nameController,
                    validator: _validateName,
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Mobile Number Field
                  CustomTextField(
                    label: '10-digit mobile number *',
                    hint: 'Enter your mobile number',
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    validator: _validateMobileNumber,
                  ),

                  const SizedBox(height: AppDimensions.paddingSmall),

                  // OTP Info Text
                  Text(
                    'OTP will be sent to this mobile number',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Email Field
                  CustomTextField(
                    label: 'Email id',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Password Field
                  CustomTextField(
                    label: 'Enter password *',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Confirm Password Field
                  CustomTextField(
                    label: 'Re-enter password *',
                    hint: 'Confirm your password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: AppDimensions.paddingXLarge),

                  // Sign Up Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'SIGN UP',
                        onPressed: authProvider.isLoading
                            ? null
                            : _handleSignUp,
                        isLoading: authProvider.isLoading,
                        backgroundColor: AppColors.darkBackground,
                        textColor: AppColors.primaryYellow,
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      CustomLinkButton(text: 'Login', onPressed: _handleLogin),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  String? _validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }

    // Remove any non-digit characters
    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.length != 10) {
      return 'Please enter a valid 10-digit mobile number';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
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

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Clean mobile number (remove any non-digit characters)
      final cleanMobileNumber = _mobileController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      try {
        final signUpRequest = SignUpRequest(
          userName: _nameController.text.trim(),
          mobileNumber: cleanMobileNumber,
          email: _emailController.text.trim().isEmpty
              ? '${cleanMobileNumber}@pickcargo.in'
              : _emailController.text.trim(),
          password: _passwordController.text,
          reEnterPwd: _confirmPasswordController.text,
        );

        final success = await authProvider.signUp(signUpRequest);

        if (success && mounted) {
          CustomSnackBar.showSuccess(
            context,
            'Registration successful! You can now login.',
          );

          // Navigate back to login screen
          NavigationService.pop();
        } else if (mounted) {
          CustomSnackBar.showError(
            context,
            authProvider.errorMessage ?? 'Registration failed',
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.showError(
            context,
            'Failed to get device information: $e',
          );
        }
      }
    }
  }

  void _handleLogin() {
    NavigationService.pop();
  }
}
