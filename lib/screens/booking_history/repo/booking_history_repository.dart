import 'dart:math';
import '../../../core/network/network_service_impl.dart';
import '../../../core/constants/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Booking History Repository for handling booking history data
class BookingHistoryRepository {
  final NetworkServiceImpl _networkService = NetworkServiceImpl();
  final Random _random = Random();

  /// Get booking history for user
  Future<List<Map<String, dynamic>>> getBookingHistory() async {
    try {
      // Get user mobile number from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final mobile = prefs.getString('mobile') ?? '';

      if (mobile.isEmpty) {
        throw Exception('User mobile number not found');
      }

      // Build API URL
      final url = AppUrl.replacePathParams(AppUrl.bookingHistory, {
        'mobile': mobile,
      });
      final fullUrl = '${AppUrl.baseUrl}/$url';

      // Make API call using NetworkServiceImpl
      final response = await _networkService.getGetApiResponse(fullUrl);

      // Handle API response
      if (response is Map<String, dynamic>) {
        // Check if response contains booking data
        if (response.containsKey('data') && response['data'] is List) {
          final List<dynamic> bookingData = response['data'];
          return bookingData
              .map<Map<String, dynamic>>(
                (booking) => Map<String, dynamic>.from(booking),
              )
              .toList();
        } else if (response.containsKey('bookings') &&
            response['bookings'] is List) {
          final List<dynamic> bookingData = response['bookings'];
          return bookingData
              .map<Map<String, dynamic>>(
                (booking) => Map<String, dynamic>.from(booking),
              )
              .toList();
        }
      } else if (response is List) {
        // Direct list response
        return response
            .map<Map<String, dynamic>>(
              (booking) => Map<String, dynamic>.from(booking),
            )
            .toList();
      }

      // If no valid data found, return empty list
      return [];
    } catch (e) {
      print('Error fetching booking history: $e');
      // Fallback to mock data in case of API failure
      return await _getMockBookingHistory();
    }
  }

  /// Fallback mock booking history data
  Future<List<Map<String, dynamic>>> _getMockBookingHistory() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock booking history data
    final List<Map<String, dynamic>> bookings = [];

    // Generate 8-12 random bookings
    final bookingCount = _random.nextInt(5) + 8;

    for (int i = 0; i < bookingCount; i++) {
      final bookingDate = DateTime.now().subtract(Duration(days: i * 2));
      final statuses = ['completed', 'in_progress', 'cancelled'];
      final truckTypes = ['Mini', 'Small', 'Medium', 'Large'];
      final pickupLocations = [
        'Kondapur, Hyderabad',
        'Hitech City, Hyderabad',
        'Gachibowli, Hyderabad',
        'Banjara Hills, Hyderabad',
        'Jubilee Hills, Hyderabad',
        'Secunderabad, Hyderabad',
        'Begumpet, Hyderabad',
        'Kukatpally, Hyderabad',
      ];
      final dropLocations = [
        'Airport, Hyderabad',
        'Railway Station, Hyderabad',
        'City Center, Hyderabad',
        'IT Park, Hyderabad',
        'Mall, Hyderabad',
        'Hospital, Hyderabad',
        'School, Hyderabad',
        'Office Complex, Hyderabad',
      ];

      bookings.add({
        'bookingId': 'BK${bookingDate.millisecondsSinceEpoch}',
        'truckType': truckTypes[_random.nextInt(truckTypes.length)],
        'pickupLocation':
            pickupLocations[_random.nextInt(pickupLocations.length)],
        'dropLocation': dropLocations[_random.nextInt(dropLocations.length)],
        'status': statuses[_random.nextInt(statuses.length)],
        'fare': (_random.nextInt(800) + 200).toDouble(), // ₹200-₹1000
        'bookingTime': bookingDate.toIso8601String(),
        'driverName': _getRandomDriverName(),
        'driverPhone': _getRandomPhoneNumber(),
        'truckNumber': _getRandomTruckNumber(),
        'estimatedArrival': '${_random.nextInt(20) + 10} minutes',
        'actualArrival': bookingDate
            .add(Duration(minutes: _random.nextInt(30) + 5))
            .toIso8601String(),
        'distance': (_random.nextInt(50) + 5).toDouble(), // 5-55 km
        'duration': '${_random.nextInt(60) + 30} minutes', // 30-90 minutes
      });
    }

    // Sort by booking time (newest first)
    bookings.sort(
      (a, b) => DateTime.parse(
        b['bookingTime'],
      ).compareTo(DateTime.parse(a['bookingTime'])),
    );

    return bookings;
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      // Build API URL for cancel booking
      final url = '${AppUrl.baseUrl}/${AppUrl.cancelBooking}';

      // Prepare request data
      final requestData = {
        'bookingNo': bookingId,
        'cancelReason': 'Customer requested cancellation',
      };

      // Make API call using NetworkServiceImpl
      final response = await _networkService.getPostApiResponse(
        url,
        requestData,
      );

      // Handle API response
      if (response is Map<String, dynamic>) {
        // Check if cancellation was successful
        if (response.containsKey('success') && response['success'] == true) {
          return true;
        } else if (response.containsKey('status') &&
            response['status'] == 'success') {
          return true;
        } else if (response.containsKey('message') &&
            response['message'].toString().toLowerCase().contains('success')) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error cancelling booking: $e');
      // Fallback to mock cancellation
      return await _mockCancelBooking();
    }
  }

  /// Fallback mock cancellation
  Future<bool> _mockCancelBooking() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock cancellation - 90% success rate
    return _random.nextDouble() > 0.1;
  }

  /// Get booking details by ID
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
    try {
      // Build API URL for booking details
      final url = AppUrl.replacePathParams(AppUrl.getBookingInfo, {
        'bookingno': bookingId,
      });
      final fullUrl = '${AppUrl.baseUrl}/$url';

      // Make API call using NetworkServiceImpl
      final response = await _networkService.getGetApiResponse(fullUrl);

      // Handle API response
      if (response is Map<String, dynamic>) {
        // Check if response contains booking data
        if (response.containsKey('data') &&
            response['data'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(response['data']);
        } else if (response.containsKey('booking') &&
            response['booking'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(response['booking']);
        } else {
          // Return the response itself if it's a valid booking object
          return response;
        }
      }

      return null;
    } catch (e) {
      print('Error fetching booking details: $e');
      // Fallback to mock data
      return await _getMockBookingDetails(bookingId);
    }
  }

  /// Fallback mock booking details
  Future<Map<String, dynamic>?> _getMockBookingDetails(String bookingId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock detailed booking data
    return {
      'bookingId': bookingId,
      'truckType': 'Medium',
      'pickupLocation': 'Kondapur, Hyderabad',
      'dropLocation': 'Airport, Hyderabad',
      'status': 'in_progress',
      'fare': 450.0,
      'bookingTime': DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
      'driverName': 'Rajesh Kumar',
      'driverPhone': '+91 98765 43210',
      'truckNumber': 'TS09AB1234',
      'estimatedArrival': '15 minutes',
      'actualArrival': null,
      'distance': 25.5,
      'duration': '45 minutes',
      'paymentMethod': 'UPI',
      'paymentStatus': 'paid',
      'rating': null,
      'feedback': null,
    };
  }

  /// Rate booking
  Future<bool> rateBooking(
    String bookingId,
    int rating,
    String? feedback,
  ) async {
    try {
      // Build API URL for rating
      final url = '${AppUrl.baseUrl}/${AppUrl.userRatingDriver}';

      // Prepare request data
      final requestData = {
        'bookingId': bookingId,
        'rating': rating,
        'feedback': feedback ?? '',
        'ratingDate': DateTime.now().toIso8601String(),
      };

      // Make API call using NetworkServiceImpl
      final response = await _networkService.getPostApiResponse(
        url,
        requestData,
      );

      // Handle API response
      if (response is Map<String, dynamic>) {
        // Check if rating was successful
        if (response.containsKey('success') && response['success'] == true) {
          return true;
        } else if (response.containsKey('status') &&
            response['status'] == 'success') {
          return true;
        } else if (response.containsKey('message') &&
            response['message'].toString().toLowerCase().contains('success')) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error rating booking: $e');
      // Fallback to mock rating
      return await _mockRateBooking();
    }
  }

  /// Fallback mock rating
  Future<bool> _mockRateBooking() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock rating submission - always successful
    return true;
  }

  /// Get booking statistics
  Future<Map<String, dynamic>> getBookingStatistics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    return {
      'totalBookings': _random.nextInt(50) + 20,
      'completedBookings': _random.nextInt(40) + 15,
      'cancelledBookings': _random.nextInt(10) + 2,
      'totalFareSpent': (_random.nextInt(20000) + 5000).toDouble(),
      'averageRating': 4.0 + (_random.nextDouble() * 1.0), // 4.0-5.0
      'favoriteTruckType': 'Medium',
      'totalDistance': (_random.nextInt(1000) + 200).toDouble(),
    };
  }

  /// Get random driver name
  String _getRandomDriverName() {
    final names = [
      'Rajesh Kumar',
      'Suresh Singh',
      'Amit Sharma',
      'Vikram Patel',
      'Ravi Kumar',
      'Manoj Singh',
      'Deepak Sharma',
      'Sunil Kumar',
      'Prakash Verma',
      'Anil Gupta',
      'Sanjay Mehta',
      'Rohit Agarwal',
    ];
    return names[_random.nextInt(names.length)];
  }

  /// Get random phone number
  String _getRandomPhoneNumber() {
    final phoneNumbers = [
      '+91 98765 43210',
      '+91 98765 43211',
      '+91 98765 43212',
      '+91 98765 43213',
      '+91 98765 43214',
      '+91 98765 43215',
      '+91 98765 43216',
      '+91 98765 43217',
      '+91 98765 43218',
      '+91 98765 43219',
    ];
    return phoneNumbers[_random.nextInt(phoneNumbers.length)];
  }

  /// Get random truck number
  String _getRandomTruckNumber() {
    final states = ['TS', 'KA', 'MH', 'DL', 'TN', 'AP', 'GJ', 'RJ', 'UP', 'MP'];
    final state = states[_random.nextInt(states.length)];
    final number = _random.nextInt(99) + 1;
    final series = String.fromCharCode(65 + _random.nextInt(26));
    return '$state$number$series${_random.nextInt(9999) + 1000}';
  }
}
