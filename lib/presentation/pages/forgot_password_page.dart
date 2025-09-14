import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_widgets.dart';
import '../../core/routes/routes_name.dart';
import '../../core/utils/navigation_service.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../core/theme/app_colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Forgot Password',
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
                    'Enter your mobile number to receive OTP for password reset',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppDimensions.paddingXLarge),

                  // Mobile Number Field
                  CustomTextField(
                    label: 'Mobile number',
                    hint: 'Enter your mobile number',
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    validator: _validateMobileNumber,
                  ),

                  const SizedBox(height: AppDimensions.paddingXLarge),

                  // Send OTP Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'SEND OTP',
                        onPressed: authProvider.isLoading
                            ? null
                            : _handleSendOTP,
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

  void _handleSendOTP() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Clean mobile number (remove any non-digit characters)
      final cleanMobileNumber = _mobileController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      final success = await authProvider.sendForgotPasswordOTP(
        mobileNumber: cleanMobileNumber,
      );

      if (success && mounted) {
        CustomSnackBar.showSuccess(
          context,
          'OTP sent successfully to your mobile number!',
        );

        // Navigate to OTP verification screen
        NavigationService.pushNamed(
          Routes.otpVerification,
          arguments: {'mobile': cleanMobileNumber, 'isForgotPassword': true},
        );
      } else if (mounted) {
        CustomSnackBar.showError(
          context,
          authProvider.errorMessage ?? 'Failed to send OTP',
        );
      }
    }
  }

  void _handleBackToLogin() {
    NavigationService.pop();
  }
}
