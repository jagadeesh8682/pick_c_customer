import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import 'custom_widgets.dart';
import '../../../core/routes/routes_name.dart';
import '../../../core/utils/navigation_service.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Login',
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

                  // Mobile Number Field
                  CustomTextField(
                    label: 'Enter mobile number',
                    hint: 'Enter your mobile number',
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    validator: _validateMobileNumber,
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Password Field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Forgot Password and Help Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomLinkButton(
                        text: 'FORGOT PASSWORD ?',
                        onPressed: _handleForgotPassword,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingSmall),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomLinkButton(text: 'HELP', onPressed: _handleHelp),
                    ],
                  ),

                  const Spacer(),

                  // Login Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'LOGIN',
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        isLoading: authProvider.isLoading,
                        backgroundColor: AppColors.darkBackground,
                        textColor: AppColors.primaryYellow,
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      CustomLinkButton(
                        text: 'Sign Up',
                        onPressed: _handleSignUp,
                      ),
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  void _handleLogin() {
    NavigationService.pushNamedAndRemoveUntil(
      Routes.map,
      predicate: (route) => false,
    );
    // if (_formKey.currentState!.validate()) {
    //   final authProvider = Provider.of<AuthProvider>(context, listen: false);

    //   // Clean mobile number (remove any non-digit characters)
    //   final cleanMobileNumber = _mobileController.text.replaceAll(
    //     RegExp(r'[^\d]'),
    //     '',
    //   );

    //   final success = await authProvider.loginWithMobile(
    //     mobileNumber: cleanMobileNumber,
    //     password: _passwordController.text,
    //   );

    //   if (success && mounted) {
    //     CustomSnackBar.showSuccess(context, 'Login successful!');
    //     NavigationService.pushNamedAndRemoveUntil(
    //       Routes.dashboard,
    //       predicate: (route) => false,
    //     );
    //   } else if (mounted) {
    //     CustomSnackBar.showError(
    //       context,
    //       authProvider.errorMessage ?? 'Login failed',
    //     );
    //   }
    // }
  }

  void _handleForgotPassword() {
    NavigationService.pushNamed(Routes.forgotPassword);
  }

  void _handleHelp() {
    CustomSnackBar.showInfo(context, 'Help feature coming soon!');
  }

  void _handleSignUp() {
    NavigationService.pushNamed(Routes.signUp);
  }
}
