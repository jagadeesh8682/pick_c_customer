import '../../../core/data/services/api_service.dart';
import '../../../core/data/models/driver/driver_models.dart';

/// Repository for driver-related API operations
class DriverRepository {
  final ApiService _apiService = ApiService();

  /// Get driver details by booking number
  Future<DriverDetails> getDriverDetails(String bookingNo) async {
    try {
      return await _apiService.getDriverDetails(bookingNo);
    } catch (e) {
      throw Exception('Failed to get driver details: $e');
    }
  }

  /// Get driver current location
  Future<DriverLocation> getDriverLocation(String driverId) async {
    try {
      return await _apiService.getDriverLocation(driverId);
    } catch (e) {
      throw Exception('Failed to get driver location: $e');
    }
  }

  /// Get driver rating
  Future<DriverRating> getDriverRating(String driverId) async {
    try {
      return await _apiService.getDriverRating(driverId);
    } catch (e) {
      throw Exception('Failed to get driver rating: $e');
    }
  }

  /// Monitor driver location continuously
  Future<DriverLocation> monitorDriver(String driverId) async {
    try {
      return await _apiService.monitorDriverLocation(driverId);
    } catch (e) {
      throw Exception('Failed to monitor driver: $e');
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
}

