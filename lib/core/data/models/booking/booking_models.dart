/// Models for booking-related operations

class BookingRequest {
  final String pickupLocation;
  final String dropLocation;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final int vehicleGroupId;
  final int openClosedId;
  final String cargoType;
  final String cargoWeight;
  final int rateCardId;
  final double estimatedFare;

  BookingRequest({
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.vehicleGroupId,
    required this.openClosedId,
    required this.cargoType,
    required this.cargoWeight,
    required this.rateCardId,
    required this.estimatedFare,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'vehicleGroupId': vehicleGroupId,
      'openClosedId': openClosedId,
      'cargoType': cargoType,
      'cargoWeight': cargoWeight,
      'rateCardId': rateCardId,
      'estimatedFare': estimatedFare,
    };
  }
}

class BookingResponse {
  final String bookingNumber;
  final String status;
  final String message;
  final String? vehicleDetails;
  final String? driverName;
  final String? driverPhone;

  BookingResponse({
    required this.bookingNumber,
    required this.status,
    required this.message,
    this.vehicleDetails,
    this.driverName,
    this.driverPhone,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      bookingNumber: json['bookingNumber'] ?? json['bookingNo'] ?? '',
      status: json['status'] ?? json['Status'] ?? '',
      message: json['message'] ?? json['Message'] ?? '',
      vehicleDetails: json['vehicleDetails'],
      driverName: json['driverName'] ?? json['driver_name'],
      driverPhone: json['driverPhone'] ?? json['driver_phone'],
    );
  }
}

class NearestDataRequest {
  final double currentLat;
  final double currentLng;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final int
  vehicleTypeId; // Changed from String vehicleType to int vehicleTypeId
  final int vehicleGroupId;

  NearestDataRequest({
    required this.currentLat,
    required this.currentLng,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.vehicleTypeId,
    required this.vehicleGroupId,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentLat': currentLat,
      'currentLng': currentLng,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'vehicleTypeId': vehicleTypeId,
      'vehicleGroupId': vehicleGroupId,
    };
  }
}

class Truck {
  final String id;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String vehicleType;
  final double distance;
  final double rating;
  final double latitude;
  final double longitude;

  Truck({
    required this.id,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.distance,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory Truck.fromJson(Map<String, dynamic> json) {
    return Truck(
      id: json['id']?.toString() ?? '',
      driverName: json['driverName'] ?? json['driver_name'] ?? '',
      driverPhone: json['driverPhone'] ?? json['driver_phone'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? json['vehicle_number'] ?? '',
      vehicleType: json['vehicleType'] ?? json['vehicle_type'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}

class TripEstimateRequest {
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final int vehicleGroupId;
  final int openClosedId;
  final String cargoType;

  TripEstimateRequest({
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.vehicleGroupId,
    required this.openClosedId,
    required this.cargoType,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'vehicleGroupId': vehicleGroupId,
      'openClosedId': openClosedId,
      'cargoType': cargoType,
    };
  }
}

class TripEstimate {
  final double estimatedFare;
  final double distance; // in km
  final int duration; // in minutes
  final String currency;

  TripEstimate({
    required this.estimatedFare,
    required this.distance,
    required this.duration,
    this.currency = 'INR',
  });

  factory TripEstimate.fromJson(Map<String, dynamic> json) {
    return TripEstimate(
      estimatedFare: (json['estimatedFare'] ?? 0).toDouble(),
      distance: (json['distance'] ?? 0).toDouble(),
      duration: json['duration'] ?? 0,
      currency: json['currency'] ?? 'INR',
    );
  }
}

class CancelBookingRequest {
  final String bookingNumber;
  final String cancellationReason;

  CancelBookingRequest({
    required this.bookingNumber,
    required this.cancellationReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingNumber': bookingNumber,
      'cancellationReason': cancellationReason,
    };
  }
}
