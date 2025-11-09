import '../../../core/data/services/api_service.dart';
import '../../../core/data/models/booking/booking_models.dart';
import '../../../screens/auth/repo/auth_models.dart';

/// Repository for home screen API operations
class HomeRepository {
  final ApiService _apiService = ApiService();

  /// Register device ID for push notifications
  Future<bool> registerDeviceId({
    required String deviceId,
    required String mobileNo,
  }) async {
    try {
      final device = Device(deviceId: deviceId, mobileNo: mobileNo);
      return await _apiService.saveDeviceId(device);
    } catch (e) {
      throw Exception('Failed to register device: $e');
    }
  }

  /// Search nearby trucks
  Future<List<Truck>> searchNearbyTrucks({
    required double currentLat,
    required double currentLng,
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    required int vehicleTypeId,
    required int vehicleGroupId,
  }) async {
    try {
      final request = NearestDataRequest(
        currentLat: currentLat,
        currentLng: currentLng,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropLat: dropLat,
        dropLng: dropLng,
        vehicleTypeId: vehicleTypeId,
        vehicleGroupId: vehicleGroupId,
      );
      return await _apiService.searchNearbyTrucks(request);
    } catch (e) {
      throw Exception('Failed to search trucks: $e');
    }
  }

  /// Check if customer is in active trip
  Future<bool> isInTrip() async {
    try {
      return await _apiService.isInTrip();
    } catch (e) {
      throw Exception('Failed to check trip status: $e');
    }
  }

  /// Check if driver reached pickup location
  Future<bool> checkDriverReachedPickup() async {
    try {
      return await _apiService.checkDriverReachedPickup();
    } catch (e) {
      throw Exception('Failed to check driver status: $e');
    }
  }

  /// Get booking information
  Future<Map<String, dynamic>> getBookingInfo(String bookingNo) async {
    try {
      return await _apiService.getBookingInfo(bookingNo);
    } catch (e) {
      throw Exception('Failed to get booking info: $e');
    }
  }

  /// Get confirmed driver details
  Future<Map<String, dynamic>> getDriverDetails(String bookingNo) async {
    try {
      final driver = await _apiService.getDriverDetails(bookingNo);
      return driver.toJson();
    } catch (e) {
      throw Exception('Failed to get driver details: $e');
    }
  }

  /// Check if customer has due payment
  Future<bool> hasCustomerDuePayment() async {
    try {
      return await _apiService.hasCustomerDuePayment();
    } catch (e) {
      throw Exception('Failed to check payment status: $e');
    }
  }

  /// Reverse geocode coordinates to address
  Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final result = await _apiService.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );

      // Extract formatted address from Google Maps response
      if (result['results'] != null && (result['results'] as List).isNotEmpty) {
        final firstResult = (result['results'] as List)[0];
        return firstResult['formatted_address'] ?? 'Address not found';
      }
      return 'Address not found';
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }
}
