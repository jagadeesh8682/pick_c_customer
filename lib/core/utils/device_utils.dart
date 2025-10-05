import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceUtils {
  static const String _deviceIdKey = 'device_id';

  /// Get or generate a unique device ID
  static Future<String> getDeviceId() async {
    try {
      // First try to get stored device ID
      final prefs = await SharedPreferences.getInstance();
      String? storedDeviceId = prefs.getString(_deviceIdKey);

      if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
        return storedDeviceId;
      }

      // Generate new device ID
      String deviceId = await _generateDeviceId();

      // Store the generated device ID
      await prefs.setString(_deviceIdKey, deviceId);

      return deviceId;
    } catch (e) {
      // Fallback to a simple UUID-like string
      return _generateFallbackDeviceId();
    }
  }

  /// Generate device ID based on platform-specific information
  static Future<String> _generateDeviceId() async {
    try {
      if (Platform.isAndroid) {
        // Generate Android device ID using timestamp and platform info
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = (timestamp % 10000).toString().padLeft(4, '0');
        return 'android_${timestamp}_$random';
      } else if (Platform.isIOS) {
        // Generate iOS device ID using timestamp and platform info
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = (timestamp % 10000).toString().padLeft(4, '0');
        return 'ios_${timestamp}_$random';
      } else {
        return _generateFallbackDeviceId();
      }
    } catch (e) {
      return _generateFallbackDeviceId();
    }
  }

  /// Generate a fallback device ID using timestamp and random
  static String _generateFallbackDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'fallback_${timestamp}_$random';
  }

  /// Get device type (Android/iOS)
  static String getDeviceType() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else {
      return 'Unknown';
    }
  }

  /// Get device model information
  static Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        return 'Android Device';
      } else if (Platform.isIOS) {
        return 'iOS Device';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Clear stored device ID (useful for testing or reset)
  static Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }
}
