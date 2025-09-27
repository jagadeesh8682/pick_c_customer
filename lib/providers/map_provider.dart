import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repos/map_repository.dart';

/// Map Provider for managing map state and truck booking logic
class MapProvider extends ChangeNotifier {
  final MapRepository _mapRepository;

  MapProvider({required MapRepository mapRepository})
    : _mapRepository = mapRepository;

  // Current location
  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  // Selected truck type
  String _selectedTruckType = 'Mini';
  String get selectedTruckType => _selectedTruckType;

  // Location locked state
  bool _isLocationLocked = false;
  bool get isLocationLocked => _isLocationLocked;

  // Pickup and drop locations (coordinates)
  LatLng? _pickupLocation;
  LatLng? get pickupLocation => _pickupLocation;

  LatLng? _dropLocation;
  LatLng? get dropLocation => _dropLocation;

  // Pickup and drop location addresses (text)
  String _pickupAddress = 'Opp TCS Kohinoor Park, Kondapu';
  String get pickupAddress => _pickupAddress;

  String _dropAddress = 'Cargo drop location';
  String get dropAddress => _dropAddress;

  // Currently selected location type for editing
  String? _selectedLocationType; // 'pickup' or 'drop'
  String? get selectedLocationType => _selectedLocationType;

  // Truck availability
  final Map<String, String> _truckAvailability = {};
  Map<String, String> get truckAvailability => _truckAvailability;

  // Loading states
  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  bool _isBooking = false;
  bool get isBooking => _isBooking;

  /// Initialize the provider and fetch initial data
  Future<void> initialize() async {
    await _fetchCurrentLocation();
    await _fetchTruckAvailability();

    // Set pickup location to current location on first load
    if (_currentLocation != null && _pickupLocation == null) {
      _pickupLocation = _currentLocation;
    }
  }

  /// Update current location
  Future<void> updateLocation(LatLng newLocation) async {
    _currentLocation = newLocation;
    notifyListeners();
  }

  /// Select truck type
  void selectTruckType(String truckType) {
    _selectedTruckType = truckType;
    notifyListeners();
  }

  /// Lock/unlock location
  void lockLocation() {
    _isLocationLocked = !_isLocationLocked;
    notifyListeners();
  }

  /// Update pickup location coordinates
  void updatePickupLocation(LatLng location) {
    _pickupLocation = location;
    notifyListeners();
  }

  /// Update drop location coordinates
  void updateDropLocation(LatLng location) {
    _dropLocation = location;
    notifyListeners();
  }

  /// Update pickup address text and geocode to coordinates
  Future<void> updatePickupAddress(String address) async {
    _pickupAddress = address;
    notifyListeners();

    // Geocode address to coordinates
    if (address.isNotEmpty) {
      await _geocodeAddress(address, 'pickup');
    }
  }

  /// Update drop address text and geocode to coordinates
  Future<void> updateDropAddress(String address) async {
    _dropAddress = address;
    notifyListeners();

    // Geocode address to coordinates
    if (address.isNotEmpty) {
      await _geocodeAddress(address, 'drop');
    }
  }

  /// Geocode address to coordinates
  Future<void> _geocodeAddress(String address, String locationType) async {
    try {
      // Simulate geocoding API call
      // In a real app, you would use Google Geocoding API or similar
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock coordinates based on address keywords
      LatLng? coordinates = _getMockCoordinates(address);

      if (coordinates != null) {
        if (locationType == 'pickup') {
          _pickupLocation = coordinates;
        } else if (locationType == 'drop') {
          _dropLocation = coordinates;
        }
        notifyListeners();
        _logLocations();
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
  }

  /// Get mock coordinates based on address keywords
  LatLng? _getMockCoordinates(String address) {
    final lowerAddress = address.toLowerCase();

    // Mock coordinates for common locations
    if (lowerAddress.contains('hyderabad') || lowerAddress.contains('hitech')) {
      return const LatLng(17.3850, 78.4867);
    } else if (lowerAddress.contains('bangalore') ||
        lowerAddress.contains('bengaluru')) {
      return const LatLng(12.9716, 77.5946);
    } else if (lowerAddress.contains('mumbai')) {
      return const LatLng(19.0760, 72.8777);
    } else if (lowerAddress.contains('delhi')) {
      return const LatLng(28.7041, 77.1025);
    } else if (lowerAddress.contains('chennai')) {
      return const LatLng(13.0827, 80.2707);
    } else if (lowerAddress.contains('kolkata')) {
      return const LatLng(22.5726, 88.3639);
    } else if (lowerAddress.contains('pune')) {
      return const LatLng(18.5204, 73.8567);
    } else if (lowerAddress.contains('ahmedabad')) {
      return const LatLng(23.0225, 72.5714);
    } else if (lowerAddress.contains('jaipur')) {
      return const LatLng(26.9124, 75.7873);
    } else if (lowerAddress.contains('lucknow')) {
      return const LatLng(26.8467, 80.9462);
    }

    // Default to a random location near current location if available
    if (_currentLocation != null) {
      return LatLng(
        _currentLocation!.latitude + (0.01 * (address.length % 10 - 5)),
        _currentLocation!.longitude + (0.01 * (address.length % 10 - 5)),
      );
    }

    return null;
  }

  /// Reverse geocode coordinates to address
  Future<void> _reverseGeocode(LatLng coordinates, String locationType) async {
    try {
      // Simulate reverse geocoding API call
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock address based on coordinates
      String address = _getMockAddress(coordinates);

      print('Reverse geocoding: $locationType -> $address');

      if (locationType == 'pickup') {
        _pickupAddress = address;
      } else if (locationType == 'drop') {
        _dropAddress = address;
      }
      notifyListeners();
    } catch (e) {
      print('Reverse geocoding error: $e');
    }
  }

  /// Get mock address based on coordinates
  String _getMockAddress(LatLng coordinates) {
    // Mock addresses based on coordinate ranges with more specific locations
    if (coordinates.latitude > 17.3 &&
        coordinates.latitude < 17.5 &&
        coordinates.longitude > 78.4 &&
        coordinates.longitude < 78.6) {
      return 'Hyderabad, Telangana, India';
    } else if (coordinates.latitude > 12.9 &&
        coordinates.latitude < 13.1 &&
        coordinates.longitude > 77.5 &&
        coordinates.longitude < 77.7) {
      return 'Bangalore, Karnataka, India';
    } else if (coordinates.latitude > 19.0 &&
        coordinates.latitude < 19.2 &&
        coordinates.longitude > 72.8 &&
        coordinates.longitude < 73.0) {
      return 'Mumbai, Maharashtra, India';
    } else if (coordinates.latitude > 28.6 &&
        coordinates.latitude < 28.8 &&
        coordinates.longitude > 77.0 &&
        coordinates.longitude < 77.2) {
      return 'Delhi, India';
    } else if (coordinates.latitude > 13.0 &&
        coordinates.latitude < 13.2 &&
        coordinates.longitude > 80.2 &&
        coordinates.longitude < 80.4) {
      return 'Chennai, Tamil Nadu, India';
    } else if (coordinates.latitude > 22.5 &&
        coordinates.latitude < 22.7 &&
        coordinates.longitude > 88.3 &&
        coordinates.longitude < 88.5) {
      return 'Kolkata, West Bengal, India';
    } else if (coordinates.latitude > 18.4 &&
        coordinates.latitude < 18.6 &&
        coordinates.longitude > 73.8 &&
        coordinates.longitude < 74.0) {
      return 'Pune, Maharashtra, India';
    } else if (coordinates.latitude > 22.9 &&
        coordinates.latitude < 23.1 &&
        coordinates.longitude > 72.5 &&
        coordinates.longitude < 72.7) {
      return 'Ahmedabad, Gujarat, India';
    } else if (coordinates.latitude > 26.8 &&
        coordinates.latitude < 27.0 &&
        coordinates.longitude > 75.7 &&
        coordinates.longitude < 75.9) {
      return 'Jaipur, Rajasthan, India';
    } else if (coordinates.latitude > 26.8 &&
        coordinates.latitude < 27.0 &&
        coordinates.longitude > 80.9 &&
        coordinates.longitude < 81.1) {
      return 'Lucknow, Uttar Pradesh, India';
    } else {
      // Generate a more descriptive address for unknown locations
      final latDir = coordinates.latitude >= 0 ? 'N' : 'S';
      final lngDir = coordinates.longitude >= 0 ? 'E' : 'W';
      return 'Location ${coordinates.latitude.abs().toStringAsFixed(4)}°$latDir, ${coordinates.longitude.abs().toStringAsFixed(4)}°$lngDir';
    }
  }

  /// Set selected location type for editing
  void setSelectedLocationType(String? locationType) {
    _selectedLocationType = locationType;
    notifyListeners();
  }

  /// Handle marker drag for pickup or drop location
  void onMarkerDrag(String locationType, LatLng newPosition) {
    if (locationType == 'pickup') {
      updatePickupLocation(newPosition);
      _reverseGeocode(newPosition, 'pickup');
    } else if (locationType == 'drop') {
      updateDropLocation(newPosition);
      _reverseGeocode(newPosition, 'drop');
    }
    _logLocations();
  }

  /// Log pickup and drop locations
  void _logLocations() {
    print('=== LOCATION LOG ===');
    print(
      'Current Location: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}',
    );
    print(
      'Pickup Location: ${_pickupLocation?.latitude}, ${_pickupLocation?.longitude}',
    );
    print('Pickup Address: $_pickupAddress');
    print(
      'Drop Location: ${_dropLocation?.latitude}, ${_dropLocation?.longitude}',
    );
    print('Drop Address: $_dropAddress');
    print('==================');
  }

  /// Public method to log locations (can be called from UI)
  void logLocations() {
    _logLocations();
  }

  /// Book truck now
  Future<Map<String, dynamic>?> bookNow() async {
    if (_currentLocation == null) return null;

    _isBooking = true;
    notifyListeners();

    try {
      final result = await _mapRepository.bookTruck(
        truckType: _selectedTruckType,
        pickupLocation: {
          'latitude': _currentLocation!.latitude,
          'longitude': _currentLocation!.longitude,
        },
        dropLocation: {
          'latitude': _currentLocation!.latitude + 0.01, // Mock drop location
          'longitude': _currentLocation!.longitude + 0.01,
        },
        isNow: true,
      );

      _isBooking = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isBooking = false;
      notifyListeners();
      return null;
    }
  }

  /// Book truck for later
  Future<Map<String, dynamic>?> bookLater() async {
    if (_currentLocation == null) return null;

    _isBooking = true;
    notifyListeners();

    try {
      final result = await _mapRepository.bookTruck(
        truckType: _selectedTruckType,
        pickupLocation: {
          'latitude': _currentLocation!.latitude,
          'longitude': _currentLocation!.longitude,
        },
        dropLocation: {
          'latitude': _currentLocation!.latitude + 0.01, // Mock drop location
          'longitude': _currentLocation!.longitude + 0.01,
        },
        isNow: false,
      );

      _isBooking = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isBooking = false;
      notifyListeners();
      return null;
    }
  }

  /// Fetch current location
  Future<void> _fetchCurrentLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      final location = await _mapRepository.getCurrentLocation();
      _currentLocation = LatLng(location['latitude']!, location['longitude']!);
    } catch (e) {
      // Fallback to default location (Hyderabad)
      _currentLocation = const LatLng(17.3850, 78.4867);
    }

    _isLoadingLocation = false;
    notifyListeners();
  }

  /// Fetch truck availability for all types
  Future<void> _fetchTruckAvailability() async {
    final truckTypes = ['Mini', 'Small', 'Medium', 'Large'];

    for (final type in truckTypes) {
      try {
        final availability = await _mapRepository.fetchTruckAvailability(type);
        _truckAvailability[type] = availability;
      } catch (e) {
        _truckAvailability[type] = 'No trucks';
      }
    }

    notifyListeners();
  }
}
