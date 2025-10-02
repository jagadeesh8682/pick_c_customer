import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../data/repositories/auth_repository.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../providers/map_provider.dart';
import '../../repos/map_repository.dart';
import '../network/network_service_impl.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    // Network Service
    Provider<NetworkServiceImpl>(create: (_) => NetworkServiceImpl()),

    Provider<AuthRepository>(
      create: (context) =>
          AuthRepository(networkService: context.read<NetworkServiceImpl>()),
    ),
    // Add Auth Provider
    ChangeNotifierProvider<AuthProvider>(
      create: (context) =>
          AuthProvider(authRepository: context.read<AuthRepository>()),
    ),
    // Add Map Repository
    Provider<MapRepository>(create: (context) => MapRepository()),
    // Add Map Provider
    ChangeNotifierProvider<MapProvider>(
      create: (context) =>
          MapProvider(mapRepository: context.read<MapRepository>()),
    ),

    // Add more providers here as needed
    // Example:
    // Provider<AuthRepository>(
    //   create: (context) => AuthRepository(
    //     networkService: context.read<NetworkServiceImpl>(),
    //   ),
    // ),
  ];
}
