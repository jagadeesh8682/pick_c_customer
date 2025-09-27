import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  /// Google Maps API Key from .env file
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Google Places API Key from .env file
  static String get googlePlacesApiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  /// Google Directions API Key from .env file
  static String get googleDirectionsApiKey =>
      dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ?? '';

  /// Check if API keys are properly loaded
  static bool get areApiKeysLoaded =>
      googleMapsApiKey.isNotEmpty &&
      googlePlacesApiKey.isNotEmpty &&
      googleDirectionsApiKey.isNotEmpty;

  /// Get all API keys as a map for debugging
  static Map<String, String> get allKeys => {
    'maps': googleMapsApiKey,
    'places': googlePlacesApiKey,
    'directions': googleDirectionsApiKey,
  };
}
