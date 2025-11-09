/// Models for driver-related operations

class DriverDetails {
  final String id;
  final String name;
  final String phone;
  final String vehicleNumber;
  final String vehicleType;
  final String vehicleModel;
  final double rating;
  final int totalTrips;
  final String photoUrl;
  final bool isOnline;

  DriverDetails({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.vehicleModel,
    required this.rating,
    required this.totalTrips,
    required this.photoUrl,
    required this.isOnline,
  });

  factory DriverDetails.fromJson(Map<String, dynamic> json) {
    return DriverDetails(
      id: json['id'] ?? json['driverId'] ?? json['mDriverId'] ?? '',
      name: json['name'] ?? json['driverName'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? json['vehicle_number'] ?? '',
      vehicleType: json['vehicleType'] ?? json['vehicle_type'] ?? '',
      vehicleModel: json['vehicleModel'] ?? json['vehicle_model'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalTrips: json['totalTrips'] ?? 0,
      photoUrl: json['photoUrl'] ?? json['photo_url'] ?? '',
      isOnline: json['isOnline'] ?? json['is_online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'rating': rating,
      'totalTrips': totalTrips,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
    };
  }
}

class DriverLocation {
  final String driverId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? heading;

  DriverLocation({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.heading,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      driverId: json['driverId'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      speed: json['speed']?.toDouble(),
      heading: json['heading']?.toDouble(),
    );
  }
}

class DriverRating {
  final double averageRating;
  final int totalRatings;
  final Map<String, int> ratingDistribution; // {"5": 50, "4": 30, ...}

  DriverRating({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory DriverRating.fromJson(Map<String, dynamic> json) {
    return DriverRating(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      ratingDistribution: Map<String, int>.from(
        json['ratingDistribution'] ?? {},
      ),
    );
  }
}

class BookingDriverInfo {
  final String bookingNumber;
  final DriverDetails driver;
  final DriverLocation? currentLocation;
  final String status; // assigned, on_way, arrived, completed
  final DateTime? estimatedArrival;

  BookingDriverInfo({
    required this.bookingNumber,
    required this.driver,
    this.currentLocation,
    required this.status,
    this.estimatedArrival,
  });

  factory BookingDriverInfo.fromJson(Map<String, dynamic> json) {
    return BookingDriverInfo(
      bookingNumber: json['bookingNumber'] ?? '',
      driver: DriverDetails.fromJson(json['driver'] ?? {}),
      currentLocation: json['currentLocation'] != null
          ? DriverLocation.fromJson(json['currentLocation'])
          : null,
      status: json['status'] ?? '',
      estimatedArrival: json['estimatedArrival'] != null
          ? DateTime.parse(json['estimatedArrival'])
          : null,
    );
  }
}



