import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/pages/signup_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/dashboard_page.dart';
import '../../presentation/pages/forgot_password_page.dart';
import '../../presentation/pages/otp_verification_page.dart';
import '../../presentation/pages/reset_password_page.dart';
import '../../screens/map_screen.dart';
import '../../screens/booking_history_screen.dart';
import '../../screens/rate_card_screen.dart';
import '../../screens/webview_screen.dart';
import '../../screens/emergency_contacts/emergency_contacts_screen.dart';
import '../../providers/emergency_contacts/emergency_contacts_provider.dart';
import '../../repos/emergency_contacts/emergency_contacts_repository.dart';
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
    Routes.map: (_) => const MapScreen(),

    // Menu Screen Routes
    Routes.bookingHistory: (_) => const BookingHistoryScreen(),
    Routes.rateCard: (_) => const RateCardScreen(),
    Routes.emergencyContacts: (_) => ChangeNotifierProvider(
      create: (context) =>
          EmergencyContactsProvider(repository: EmergencyContactsRepository()),
      child: const EmergencyContactsScreen(),
    ),
    Routes.help: (_) => const WebViewScreen(
      url: 'https://pickcargo.in/Dashboard/Helpdesk',
      title: 'Help',
    ),
    Routes.about: (_) => const PlaceholderScreen(title: 'About'),
    Routes.referral: (_) => const PlaceholderScreen(title: 'Referral'),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Handle custom routes if needed
    switch (settings.name) {
      default:
        return null;
    }
  }
}

/// Placeholder Screen for menu items not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                '$title Coming Soon',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This feature is under development and will be available soon.',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.yellow,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
