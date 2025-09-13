import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../network/network_service_impl.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    // Network Service
    Provider<NetworkServiceImpl>(create: (_) => NetworkServiceImpl()),

    // Add more providers here as needed
    // Example:
    // Provider<AuthRepository>(
    //   create: (context) => AuthRepository(
    //     networkService: context.read<NetworkServiceImpl>(),
    //   ),
    // ),
  ];
}
