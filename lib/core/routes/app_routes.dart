import 'package:flutter/material.dart';
import '../../presentation/pages/signup_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/dashboard_page.dart';
import '../../presentation/pages/forgot_password_page.dart';
import '../../presentation/pages/otp_verification_page.dart';
import '../../presentation/pages/reset_password_page.dart';
import 'routes_name.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    Routes.signUp: (_) => const SignUpPage(),
    Routes.login: (_) => const LoginPage(),
    Routes.dashboard: (_) => const DashboardPage(),
    Routes.checkEmail: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return OTPVerificationPage(
        mobileNumber: args?['mobile'] ?? '',
        isForgotPassword: false,
      );
    },
    Routes.forgotPassword: (_) => const ForgotPasswordPage(),
    Routes.otpVerification: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return OTPVerificationPage(
        mobileNumber: args?['mobile'] ?? '',
        isForgotPassword: args?['isForgotPassword'] ?? false,
      );
    },
    Routes.resetPassword: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ResetPasswordPage(mobileNumber: args?['mobile'] ?? '');
    },
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle custom routes if needed
    switch (settings.name) {
      default:
        return null;
    }
  }
}
