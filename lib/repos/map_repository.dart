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

  /// Simulates getting current location
  /// Returns mock location data
  Future<Map<String, double>> getCurrentLocation() async {
    // Simulate location fetch delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Return mock location (Hyderabad coordinates)
    return {'latitude': 17.3850, 'longitude': 78.4867};
  }
}
