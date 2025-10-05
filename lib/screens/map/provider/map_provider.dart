import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repo/map_repository.dart';

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
  String _pickupAddress = '';
  String get pickupAddress => _pickupAddress;

  String _dropAddress = '';
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
      // Also update the pickup address to reflect current location
      await _reverseGeocode(_currentLocation!, 'pickup');
      print('Set current location as default pickup: ${_currentLocation}');
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
    // Trigger reverse geocoding to get the address
    _reverseGeocode(location, 'pickup');
    notifyListeners();
  }

  /// Update drop location coordinates
  void updateDropLocation(LatLng location) {
    _dropLocation = location;
    // Trigger reverse geocoding to get the address
    _reverseGeocode(location, 'drop');
    notifyListeners();
    print('Drop location updated: $location');
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
    // Generate unique addresses based on precise coordinates to avoid duplicates
    final lat = coordinates.latitude;
    final lng = coordinates.longitude;

    // Create unique identifiers from coordinates
    final latInt = (lat * 10000).round();
    final lngInt = (lng * 10000).round();
    final flatNumber = ((latInt + lngInt) % 200) + 1;
    final streetNumber = ((latInt * 2 + lngInt) % 500) + 1;
    final areaCode = ((latInt + lngInt * 3) % 50) + 1;

    // Mock addresses based on coordinate ranges with more specific locations
    if (lat > 17.3 && lat < 17.5 && lng > 78.4 && lng < 78.6) {
      return 'Flat ${flatNumber}A, Tower ${String.fromCharCode(65 + (areaCode % 5))}, Cyber Gateway, Hitech City, Hyderabad, Telangana 500081, India';
    } else if (lat > 12.9 && lat < 13.1 && lng > 77.5 && lng < 77.7) {
      return 'Flat ${flatNumber}B, ${streetNumber} Brigade Road, MG Road, Bangalore, Karnataka 560001, India';
    } else if (lat > 19.0 && lat < 19.2 && lng > 72.8 && lng < 73.0) {
      return 'Flat ${flatNumber}C, ${streetNumber} Marine Drive, Mumbai, Maharashtra 400020, India';
    } else if (lat > 28.6 && lat < 28.8 && lng > 77.0 && lng < 77.2) {
      return 'Flat ${flatNumber}D, ${streetNumber} Connaught Place, New Delhi, Delhi 110001, India';
    } else if (lat > 13.0 && lat < 13.2 && lng > 80.2 && lng < 80.4) {
      return 'Flat ${flatNumber}E, ${streetNumber} Anna Salai, Chennai, Tamil Nadu 600002, India';
    } else if (lat > 22.5 && lat < 22.7 && lng > 88.3 && lng < 88.5) {
      return 'Flat ${flatNumber}F, ${streetNumber} Park Street, Kolkata, West Bengal 700016, India';
    } else if (lat > 18.4 && lat < 18.6 && lng > 73.8 && lng < 74.0) {
      return 'Flat ${flatNumber}G, ${streetNumber} Koregaon Park, Pune, Maharashtra 411001, India';
    } else if (lat > 22.9 && lat < 23.1 && lng > 72.5 && lng < 72.7) {
      return 'Flat ${flatNumber}H, ${streetNumber} CG Road, Ahmedabad, Gujarat 380006, India';
    } else if (lat > 26.8 && lat < 27.0 && lng > 75.7 && lng < 75.9) {
      return 'Flat ${flatNumber}I, ${streetNumber} C-Scheme, Jaipur, Rajasthan 302001, India';
    } else if (lat > 26.8 && lat < 27.0 && lng > 80.9 && lng < 81.1) {
      return 'Flat ${flatNumber}J, ${streetNumber} Hazratganj, Lucknow, Uttar Pradesh 226001, India';
    } else if (lat > 37.4 && lat < 37.5 && lng > -122.1 && lng < -122.0) {
      // San Francisco Bay Area coordinates (for testing)
      return '${streetNumber} Main Street, Apt ${flatNumber}B, Mountain View, CA 94041, USA';
    } else {
      // Generate a more descriptive address for unknown locations with unique details
      final latDir = lat >= 0 ? 'N' : 'S';
      final lngDir = lng >= 0 ? 'E' : 'W';
      final areaName = 'Area${areaCode}';
      final cityName = 'City${streetNumber % 20}';
      return 'Flat ${flatNumber}A, ${streetNumber} Custom Street, ${areaName}, ${cityName}, ${latDir}${lat.abs().toStringAsFixed(2)}, ${lngDir}${lng.abs().toStringAsFixed(2)}';
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

  /// Search for a location and update the selected location type
  Future<void> searchLocation(String query, String locationType) async {
    if (query.isEmpty) return;

    try {
      // Simulate location search API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock search results based on query
      LatLng? coordinates = _getMockCoordinates(query);
      String address = _getMockSearchAddress(query);

      if (coordinates != null) {
        if (locationType == 'pickup') {
          _pickupLocation = coordinates;
          _pickupAddress = address;
        } else if (locationType == 'drop') {
          _dropLocation = coordinates;
          _dropAddress = address;
        }
        notifyListeners();
        print('Location search result: $query -> $address at $coordinates');
      }
    } catch (e) {
      print('Location search error: $e');
    }
  }

  /// Get mock search address based on query
  String _getMockSearchAddress(String query) {
    final lowerQuery = query.toLowerCase();

    // Generate unique identifiers from query to avoid duplicates
    final queryHash = query.hashCode.abs();
    final flatNumber = (queryHash % 200) + 1;
    final streetNumber = ((queryHash * 2) % 500) + 1;
    final areaCode = ((queryHash * 3) % 50) + 1;

    // Mock addresses for common search terms with detailed addresses
    if (lowerQuery.contains('hyderabad') || lowerQuery.contains('hitech')) {
      return 'Flat ${flatNumber}A, Tower ${String.fromCharCode(65 + (areaCode % 5))}, Cyber Gateway, Hitech City, Hyderabad, Telangana 500081, India';
    } else if (lowerQuery.contains('bangalore') ||
        lowerQuery.contains('bengaluru')) {
      return 'Flat ${flatNumber}B, ${streetNumber} Brigade Road, MG Road, Bangalore, Karnataka 560001, India';
    } else if (lowerQuery.contains('mumbai')) {
      return 'Flat ${flatNumber}C, ${streetNumber} Marine Drive, Mumbai, Maharashtra 400020, India';
    } else if (lowerQuery.contains('delhi')) {
      return 'Flat ${flatNumber}D, ${streetNumber} Connaught Place, New Delhi, Delhi 110001, India';
    } else if (lowerQuery.contains('chennai')) {
      return 'Flat ${flatNumber}E, ${streetNumber} Anna Salai, Chennai, Tamil Nadu 600002, India';
    } else if (lowerQuery.contains('kolkata')) {
      return 'Flat ${flatNumber}F, ${streetNumber} Park Street, Kolkata, West Bengal 700016, India';
    } else if (lowerQuery.contains('pune')) {
      return 'Flat ${flatNumber}G, ${streetNumber} Koregaon Park, Pune, Maharashtra 411001, India';
    } else if (lowerQuery.contains('ahmedabad')) {
      return 'Flat ${flatNumber}H, ${streetNumber} CG Road, Ahmedabad, Gujarat 380006, India';
    } else if (lowerQuery.contains('jaipur')) {
      return 'Flat ${flatNumber}I, ${streetNumber} C-Scheme, Jaipur, Rajasthan 302001, India';
    } else if (lowerQuery.contains('lucknow')) {
      return 'Flat ${flatNumber}J, ${streetNumber} Hazratganj, Lucknow, Uttar Pradesh 226001, India';
    } else if (lowerQuery.contains('san francisco') ||
        lowerQuery.contains('sf')) {
      return '${streetNumber} Main Street, Apt ${flatNumber}B, Mountain View, CA 94041, USA';
    } else if (lowerQuery.contains('kondapur') ||
        lowerQuery.contains('konda')) {
      return 'Flat ${flatNumber}K, Kondapur Heights, Hitech City Road, Kondapur, Hyderabad, Telangana 500081, India';
    } else if (lowerQuery.contains('tcs') || lowerQuery.contains('kohinoor')) {
      return 'Flat ${flatNumber}L, Tower ${String.fromCharCode(65 + (areaCode % 3))}, TCS Kohinoor Park, Kondapur, Hyderabad, Telangana 500081, India';
    } else if (lowerQuery.contains('flat') ||
        lowerQuery.contains('apartment')) {
      return 'Flat ${flatNumber}M, ${query} Street, Area ${areaCode}, City ${streetNumber % 20}';
    } else {
      // Return the query as address if no specific match, but make it more detailed
      return 'Flat ${flatNumber}N, ${query} Road, Area ${areaCode}, City ${streetNumber % 25}, State ${streetNumber % 30}';
    }
  }

  /// Clear pickup location
  void clearPickupLocation() {
    _pickupLocation = null;
    _pickupAddress = '';
    notifyListeners();
  }

  /// Clear drop location
  void clearDropLocation() {
    _dropLocation = null;
    _dropAddress = '';
    notifyListeners();
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
