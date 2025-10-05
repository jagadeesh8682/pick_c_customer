import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import 'custom_widgets.dart';
import '../../../core/routes/routes_name.dart';
import '../../../core/utils/navigation_service.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/theme/app_colors.dart';

class OTPVerificationPage extends StatefulWidget {
  final String mobileNumber;
  final bool isForgotPassword;

  const OTPVerificationPage({
    super.key,
    required this.mobileNumber,
    this.isForgotPassword = false,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 30;

    _runTimer();
  }

  void _runTimer() async {
    while (_resendTimer > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendTimer--;
          if (_resendTimer <= 0) {
            _canResend = true;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Verify OTP',
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
                    'Enter the OTP sent to',
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

                  // OTP Field
                  CustomTextField(
                    label: 'Enter OTP',
                    hint: 'Enter 6-digit OTP',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    validator: _validateOTP,
                    maxLength: 6,
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Verify OTP Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: 'VERIFY OTP',
                        onPressed: authProvider.isLoading
                            ? null
                            : _handleVerifyOTP,
                        isLoading: authProvider.isLoading,
                        backgroundColor: AppColors.darkBackground,
                        textColor: AppColors.primaryYellow,
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Resend OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive OTP? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_canResend)
                        CustomLinkButton(
                          text: 'Resend OTP',
                          onPressed: _handleResendOTP,
                        )
                      else
                        Text(
                          'Resend in ${_resendTimer}s',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Back to Previous Screen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Wrong number? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      CustomLinkButton(
                        text: 'Go Back',
                        onPressed: _handleGoBack,
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

  String? _validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }

    if (value.length != 6) {
      return 'Please enter a valid 6-digit OTP';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP should contain only numbers';
    }

    return null;
  }

  void _handleVerifyOTP() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.verifyOTP(
        widget.mobileNumber,
        _otpController.text,
      );

      if (success && mounted) {
        CustomSnackBar.showSuccess(context, 'OTP verified successfully!');

        if (widget.isForgotPassword) {
          // Navigate to reset password screen
          NavigationService.pushNamed(
            Routes.resetPassword,
            arguments: {'mobile': widget.mobileNumber},
          );
        } else {
          // Navigate to dashboard for registration flow
          NavigationService.pushNamedAndRemoveUntil(
            Routes.dashboard,
            predicate: (route) => false,
          );
        }
      } else if (mounted) {
        CustomSnackBar.showError(
          context,
          authProvider.errorMessage ?? 'OTP verification failed',
        );
      }
    }
  }

  void _handleResendOTP() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.sendForgotPasswordOTP(
      widget.mobileNumber,
    );

    if (success && mounted) {
      CustomSnackBar.showSuccess(context, 'OTP resent successfully!');
      _startResendTimer();
    } else if (mounted) {
      CustomSnackBar.showError(
        context,
        authProvider.errorMessage ?? 'Failed to resend OTP',
      );
    }
  }

  void _handleGoBack() {
    NavigationService.pop();
  }
}
