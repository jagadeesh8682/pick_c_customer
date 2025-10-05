import 'package:flutter/material.dart';
import '../repo/booking_history_repository.dart';

/// Booking History Provider for managing booking history state
class BookingHistoryProvider extends ChangeNotifier {
  final BookingHistoryRepository _repository;

  BookingHistoryProvider({required BookingHistoryRepository repository})
    : _repository = repository;

  // State variables
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _bookingHistory = [];
  List<Map<String, dynamic>> get bookingHistory => _bookingHistory;

  String? _error;
  String? get error => _error;

  /// Load booking history
  Future<void> loadBookingHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final history = await _repository.getBookingHistory();
      _bookingHistory = history;

      // Log success for debugging
      print('Successfully loaded ${history.length} booking records');
    } catch (e) {
      _error = e.toString();
      print('Error loading booking history: $e');

      // Show user-friendly error message
      if (e.toString().contains('mobile number not found')) {
        _error = 'Please login again to view your booking history';
      } else if (e.toString().contains('Unauthorized')) {
        _error = 'Session expired. Please login again';
      } else if (e.toString().contains('Network error')) {
        _error = 'Network error. Please check your internet connection';
      } else {
        _error = 'Failed to load booking history. Please try again';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      final success = await _repository.cancelBooking(bookingId);
      if (success) {
        // Update the booking status in the list
        final index = _bookingHistory.indexWhere(
          (booking) => booking['bookingId'] == bookingId,
        );
        if (index != -1) {
          _bookingHistory[index]['status'] = 'cancelled';
          notifyListeners();
        }
        print('Successfully cancelled booking: $bookingId');
      } else {
        print('Failed to cancel booking: $bookingId');
      }
      return success;
    } catch (e) {
      print('Error cancelling booking: $e');
      _error = 'Failed to cancel booking. Please try again';
      notifyListeners();
      return false;
    }
  }

  /// Refresh booking history
  Future<void> refresh() async {
    await loadBookingHistory();
  }

  /// Get booking by ID
  Map<String, dynamic>? getBookingById(String bookingId) {
    try {
      return _bookingHistory.firstWhere(
        (booking) => booking['bookingId'] == bookingId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get bookings by status
  List<Map<String, dynamic>> getBookingsByStatus(String status) {
    return _bookingHistory
        .where((booking) => booking['status'] == status)
        .toList();
  }

  /// Get total bookings count
  int get totalBookings => _bookingHistory.length;

  /// Get completed bookings count
  int get completedBookings => getBookingsByStatus('completed').length;

  /// Get in progress bookings count
  int get inProgressBookings => getBookingsByStatus('in_progress').length;

  /// Get cancelled bookings count
  int get cancelledBookings => getBookingsByStatus('cancelled').length;

  /// Get total fare spent
  double get totalFareSpent {
    return _bookingHistory
        .where((booking) => booking['status'] == 'completed')
        .fold(0.0, (sum, booking) => sum + (booking['fare'] as double));
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check if there are any bookings
  bool get hasBookings => _bookingHistory.isNotEmpty;

  /// Get bookings by date range
  List<Map<String, dynamic>> getBookingsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _bookingHistory.where((booking) {
      final bookingDate = DateTime.parse(booking['bookingTime']);
      return bookingDate.isAfter(startDate) && bookingDate.isBefore(endDate);
    }).toList();
  }

  /// Get recent bookings (last 30 days)
  List<Map<String, dynamic>> get recentBookings {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return getBookingsByDateRange(thirtyDaysAgo, DateTime.now());
  }
}
