import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/providers/app_providers.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/routes_name.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/navigation_service.dart';
import 'core/services/razorpay_service.dart';
import 'data/services/api_service.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dotenv
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // If .env file doesn't exist, continue without it
    print('Warning: .env file not found or could not be loaded: $e');
  }

  // Initialize API service
  ApiService().initialize();

  // Initialize Razorpay service
  RazorpayService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        title: 'Pick C Customer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: Routes.login,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const MapScreen(), // Changed to MapScreen for testing
      ),
    );
  }
}
