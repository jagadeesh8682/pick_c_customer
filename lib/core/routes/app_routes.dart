import 'package:flutter/material.dart';
import '../../presentation/pages/signup_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/dashboard_page.dart';
import 'routes_name.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    Routes.signUp: (_) => const SignUpPage(),

    Routes.login: (_) => const LoginPage(),

    Routes.resetPasswordScreen: (_) => const ResetPasswordScreen(),

    Routes.enterMail: (_) => const MailToSetPasswordScreen(),

    Routes.mailToSetPassword: (_) => const MailToSetPasswordScreen(),

    Routes.dashboard: (_) => const DashboardPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle Firebase reset password deep link with query parameters
    if (settings.name != null && settings.name!.startsWith('/reset-password')) {
      // Extract oobCode from the URL query parameters
      String? oobCode;
      try {
        final uri = Uri.parse(settings.name!);
        oobCode = uri.queryParameters['oobCode'];
      } catch (e) {
        // If parsing fails, oobCode remains null
      }

      return MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(oobCode: oobCode),
        settings: settings,
      );
    }

    // Handle Firebase email verification deep link with query parameters
    if (settings.name != null && settings.name!.startsWith('/login')) {
      // Extract oobCode and mode from the URL query parameters
      String? oobCode;
      String? mode;
      try {
        final uri = Uri.parse(settings.name!);
        oobCode = uri.queryParameters['oobCode'];
        mode = uri.queryParameters['mode'];
      } catch (e) {
        // If parsing fails, values remain null
      }

      return MaterialPageRoute(
        builder: (_) => LoginScreen(oobCode: oobCode, mode: mode),
        settings: settings,
      );
    }

    switch (settings.name) {
      case Routes.checkEmail:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] as String? ?? 'example@gmail.com';
        return MaterialPageRoute(
          builder: (_) => CheckEmailScreen(email: email),
          settings: settings,
        );

      case Routes.resetPasswordScreen:
        // Handle Firebase reset password URL with oobCode
        final args = settings.arguments as Map<String, dynamic>?;
        final oobCode = args?['oobCode'] as String?;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(oobCode: oobCode),
          settings: settings,
        );

      default:
        return null;
    }
  }
}

// Placeholder widgets for other screens
class LoginScreen extends StatelessWidget {
  final String? oobCode;
  final String? mode;

  const LoginScreen({super.key, this.oobCode, this.mode});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login Screen - To be implemented')),
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  final String? oobCode;

  const ResetPasswordScreen({super.key, this.oobCode});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Reset Password Screen - To be implemented')),
    );
  }
}

class MailToSetPasswordScreen extends StatelessWidget {
  const MailToSetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Mail To Set Password Screen - To be implemented'),
      ),
    );
  }
}

class CheckEmailScreen extends StatelessWidget {
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Check Email Screen - Email: $email')),
    );
  }
}
