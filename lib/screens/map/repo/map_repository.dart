import 'package:geolocator/geolocator.dart';

/// Map Repository for handling truck booking related data
class MapRepository {
  /// Simulates fetching truck availability for a specific truck type
  /// Returns availability status as a string
  Future<String> fetchTruckAvailability(String truckType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // For now, return "No trucks" for all types
    // In a real app, this would make an API call to the backend
    return "No trucks";
  }

  /// Simulates booking a truck
  /// Returns booking confirmation
  Future<Map<String, dynamic>> bookTruck({
    required String truckType,
    required Map<String, double> pickupLocation,
    required Map<String, double> dropLocation,
    required bool isNow,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock booking data
    return {
      'bookingId': 'BK${DateTime.now().millisecondsSinceEpoch}',
      'truckType': truckType,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'isNow': isNow,
      'status': 'confirmed',
      'estimatedArrival': isNow ? '15 minutes' : 'Scheduled',
    };
  }

  /// Get current location with proper permission handling
  Future<Map<String, double>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return _getDefaultLocation();
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return _getDefaultLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return _getDefaultLocation();
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('Current location: ${position.latitude}, ${position.longitude}');
      return {'latitude': position.latitude, 'longitude': position.longitude};
    } catch (e) {
      print('Error getting location: $e');
      return _getDefaultLocation();
    }
  }

  /// Get default location (Hyderabad) as fallback
  Map<String, double> _getDefaultLocation() {
    print('Using default location (Hyderabad)');
    return {'latitude': 17.3850, 'longitude': 78.4867};
  }
}
