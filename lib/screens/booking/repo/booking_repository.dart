import '../../../core/data/services/api_service.dart';
import '../../../core/data/models/booking/booking_models.dart';
import '../../../core/data/models/vehicle/vehicle_models.dart';

/// Repository for booking-related API operations
class BookingRepository {
  final ApiService _apiService = ApiService();

  /// Get cargo types
  Future<List<CargoType>> getCargoTypes() async {
    try {
      return await _apiService.getCargoTypes();
    } catch (e) {
      throw Exception('Failed to load cargo types: $e');
    }
  }

  /// Confirm booking
  Future<BookingResponse> confirmBooking(BookingRequest request) async {
    try {
      return await _apiService.confirmBooking(request);
    } catch (e) {
      throw Exception('Failed to confirm booking: $e');
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking({
    required String bookingNumber,
    required String cancellationReason,
  }) async {
    try {
      final request = CancelBookingRequest(
        bookingNumber: bookingNumber,
        cancellationReason: cancellationReason,
      );
      return await _apiService.cancelBooking(request);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
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
}

