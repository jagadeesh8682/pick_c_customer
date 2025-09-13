import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_providers.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/routes_name.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_initialization.dart';
import 'core/utils/navigation_service.dart';
import 'core/network/network_service_impl.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  await AppInitialization.initializeAll();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...AppProviders.providers,
        // Add Auth Repository
        Provider<AuthRepository>(
          create: (context) => AuthRepository(
            networkService: context.read<NetworkServiceImpl>(),
          ),
        ),
        // Add Auth Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(authRepository: context.read<AuthRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Pick C Customer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: Routes.login,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const LoginPage(),
      ),
    );
  }
}
