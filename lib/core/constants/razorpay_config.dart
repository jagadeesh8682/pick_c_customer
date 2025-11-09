import 'package:flutter_dotenv/flutter_dotenv.dart';

class RazorpayConfig {
  // Test Key - Replace with your actual Razorpay key
  static const String testKey = 'rzp_test_1DP5mmOlF5G5ag';
  static const String liveKey = 'rzp_live_YOUR_LIVE_KEY_HERE';

  // Get Razorpay key from environment variables
  static String get razorpayKeyId => dotenv.env['RAZORPAY_KEY_ID'] ?? testKey;
  static String get razorpayKeySecret =>
      dotenv.env['RAZORPAY_KEY_SECRET'] ?? '';

  // Use environment key if available, otherwise fallback to test key
  static String get currentKey => razorpayKeyId;

  // Payment options
  static Map<String, dynamic> getPaymentOptions({
    required int amount,
    required String description,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) {
    return {
      'key': currentKey,
      'amount': amount,
      'name': 'Pick-C Cargo',
      'description': description,
      'prefill': {
        'contact': customerPhone ?? '9876543210',
        'email': customerEmail ?? 'customer@pickc.com',
        'name': customerName ?? 'Customer',
      },
      'theme': {
        'color': '#FFD700', // Yellow color matching the app theme
      },
      'currency': 'INR',
      'method': {'netbanking': true, 'card': true, 'wallet': true, 'upi': true},
    };
  }
}
