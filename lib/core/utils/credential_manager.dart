import 'package:shared_preferences/shared_preferences.dart';

class CredentialManager {
  static const String _mobileKey = 'mobile_number';
  static const String _passwordKey = 'password';
  static const String token = 'token';

  static Future<void> saveCredentials(String mobile, String password, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mobileKey, mobile);
    await prefs.setString(_passwordKey, password);
    await prefs.setString(token, 'your_token_here'); // Save token if needed
  }

  static Future<String?> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileKey);
  }

  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(token);
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mobileKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(token);
  }

  static Future<bool> hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_mobileKey) && prefs.containsKey(_passwordKey) && prefs.containsKey(token);
  }
}
