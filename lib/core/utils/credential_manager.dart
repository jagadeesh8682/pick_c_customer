import 'package:shared_preferences/shared_preferences.dart';

class CredentialManager {
  static const String _mobileKey = 'mobile_number';
  static const String _passwordKey = 'password';

  static Future<void> saveCredentials(String mobile, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mobileKey, mobile);
    await prefs.setString(_passwordKey, password);
  }

  static Future<String?> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileKey);
  }

  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mobileKey);
    await prefs.remove(_passwordKey);
  }

  static Future<bool> hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_mobileKey) && prefs.containsKey(_passwordKey);
  }
}
