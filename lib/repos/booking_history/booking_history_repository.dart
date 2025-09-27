import 'dart:math';

/// Booking History Repository for handling booking history data
class BookingHistoryRepository {
  final Random _random = Random();

  /// Get booking history for user
  Future<List<Map<String, dynamic>>> getBookingHistory() async {
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
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock cancellation - 90% success rate
    return _random.nextDouble() > 0.1;
  }

  /// Get booking details by ID
  Future<Map<String, dynamic>?> getBookingDetails(String bookingId) async {
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

