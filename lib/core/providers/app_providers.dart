import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../screens/auth/repo/auth_repository.dart';
import '../../screens/auth/provider/auth_provider.dart';
import '../../screens/map/provider/map_provider.dart';
import '../../screens/map/repo/map_repository.dart';
import '../../screens/booking_history/provider/booking_history_provider.dart';
import '../../screens/booking_history/repo/booking_history_repository.dart';
import '../../screens/emergency_contacts/provider/emergency_contacts_provider.dart';
import '../../screens/emergency_contacts/repo/emergency_contacts_repository.dart';
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
    ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider()),
    // Add Map Repository
    Provider<MapRepository>(create: (context) => MapRepository()),
    // Add Map Provider
    ChangeNotifierProvider<MapProvider>(
      create: (context) =>
          MapProvider(mapRepository: context.read<MapRepository>()),
    ),

    // Add Booking History Repository
    Provider<BookingHistoryRepository>(
      create: (context) => BookingHistoryRepository(),
    ),

    // Add Booking History Provider
    ChangeNotifierProvider<BookingHistoryProvider>(
      create: (context) => BookingHistoryProvider(
        repository: context.read<BookingHistoryRepository>(),
      ),
    ),

    // Add Emergency Contacts Repository
    Provider<EmergencyContactsRepository>(
      create: (context) => EmergencyContactsRepository(),
    ),

    // Add Emergency Contacts Provider
    ChangeNotifierProvider<EmergencyContactsProvider>(
      create: (context) => EmergencyContactsProvider(
        repository: context.read<EmergencyContactsRepository>(),
      ),
    ),
  ];
}
