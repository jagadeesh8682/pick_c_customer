/// Models for vehicle-related operations

/// Lookup model for vehicle types and groups from lookup API
class VehicleLookup {
  final int lookupId;
  final String lookupCode;
  final String lookupDescription;
  final String lookupCategory;

  VehicleLookup({
    required this.lookupId,
    required this.lookupCode,
    required this.lookupDescription,
    required this.lookupCategory,
  });

  factory VehicleLookup.fromJson(Map<String, dynamic> json) {
    return VehicleLookup(
      lookupId: json['LookupID'] ?? json['lookupId'] ?? 0,
      lookupCode: json['LookupCode'] ?? json['lookupCode'] ?? '',
      lookupDescription:
          json['LookupDescription'] ?? json['lookupDescription'] ?? '',
      lookupCategory: json['LookupCategory'] ?? json['lookupCategory'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LookupID': lookupId,
      'LookupCode': lookupCode,
      'LookupDescription': lookupDescription,
      'LookupCategory': lookupCategory,
    };
  }
}

class VehicleGroup {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  VehicleGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory VehicleGroup.fromJson(Map<String, dynamic> json) {
    return VehicleGroup(
      id: json['id'] ?? json['vehicleGroupId'] ?? 0,
      name: json['name'] ?? json['Name'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}

class VehicleType {
  final int id;
  final String name; // "Open" or "Closed"
  final String description;

  VehicleType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'] ?? json['vehicleTypeId'] ?? 0,
      name: json['name'] ?? json['Name'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
    );
  }
}

class CargoType {
  final int id;
  final String name;
  final String description;

  CargoType({required this.id, required this.name, required this.description});

  factory CargoType.fromJson(Map<String, dynamic> json) {
    return CargoType(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['Name'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
    );
  }
}

class RateCard {
  final int id;
  final String vehicleType; // Open/Closed
  final String truckSize; // Mini/Small/Medium/Large
  final double baseFare;
  final double perKmRate;
  final double perHourRate;
  final double minimumFare;

  RateCard({
    required this.id,
    required this.vehicleType,
    required this.truckSize,
    required this.baseFare,
    required this.perKmRate,
    required this.perHourRate,
    required this.minimumFare,
  });

  factory RateCard.fromJson(Map<String, dynamic> json) {
    return RateCard(
      id: json['id'] ?? 0,
      vehicleType: json['vehicleType'] ?? json['VehicleType'] ?? '',
      truckSize: json['truckSize'] ?? json['TruckSize'] ?? '',
      baseFare: (json['baseFare'] ?? 0).toDouble(),
      perKmRate: (json['perKmRate'] ?? 0).toDouble(),
      perHourRate: (json['perHourRate'] ?? 0).toDouble(),
      minimumFare: (json['minimumFare'] ?? 0).toDouble(),
    );
  }

  /// Calculate estimated fare based on distance and time
  double calculateFare({
    required double distance, // in km
    required double duration, // in hours
  }) {
    final distanceFare = distance * perKmRate;
    final timeFare = duration * perHourRate;
    final totalFare = baseFare + distanceFare + timeFare;
    return totalFare < minimumFare ? minimumFare : totalFare;
  }
}
