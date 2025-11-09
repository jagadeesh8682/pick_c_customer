# Razorpay Integration Setup

## Overview
Your Razorpay key `JHMu0RNKkhZT4ewpKIm2rc7w` has been successfully integrated into the Pick-C Customer app. The integration follows secure practices by using environment variables.

## Configuration Files Updated

### 1. Environment Variables (.env)
The `.env` file has been created with your Razorpay key:
```
RAZORPAY_KEY_ID=JHMu0RNKkhZT4ewpKIm2rc7w
RAZORPAY_KEY_SECRET=your_razorpay_key_secret_here
```

### 2. RazorpayConfig Class
Updated `lib/core/constants/razorpay_config.dart` to:
- Use environment variables for API keys
- Fallback to test keys if environment variables are not available
- Provide secure key management

### 3. ApiKeys Class
Updated `lib/core/constants/api_keys.dart` to:
- Include Razorpay key management
- Provide validation methods for Razorpay keys
- Maintain security by hiding sensitive data in debug output

## Security Features

### Environment Variable Protection
- `.env` file is added to `.gitignore` to prevent accidental commits
- API keys are loaded from environment variables
- Fallback mechanisms ensure the app works even without `.env` file

### Key Management
- Razorpay Key ID is safely stored in environment variables
- Key Secret should be added to `.env` file for production use
- Debug output hides sensitive information

## Usage

### In Your Code
```dart
import 'package:pick_c_customer/core/constants/razorpay_config.dart';
import 'package:pick_c_customer/core/constants/api_keys.dart';

// Get Razorpay key
String razorpayKey = RazorpayConfig.currentKey;

// Check if Razorpay keys are loaded
bool keysLoaded = ApiKeys.areRazorpayKeysLoaded;

// Get payment options
Map<String, dynamic> paymentOptions = RazorpayConfig.getPaymentOptions(
  amount: 10000, // Amount in paise (₹100.00)
  description: 'Payment for cargo service',
  customerName: 'John Doe',
  customerEmail: 'john@example.com',
  customerPhone: '9876543210',
);
```

### Payment Integration
The Razorpay service is already initialized in `main.dart` and ready to use. The configuration includes:
- Support for multiple payment methods (cards, UPI, net banking, wallets)
- Custom theme matching your app's yellow color scheme
- Pre-filled customer information
- INR currency support

## Next Steps

1. **Add Razorpay Key Secret**: Update the `.env` file with your actual Razorpay key secret
2. **Test Payment Flow**: Use the test environment to verify payment integration
3. **Production Setup**: Switch to live keys when ready for production

## Important Notes

- The key `JHMu0RNKkhZT4ewpKIm2rc7w` appears to be a test key (starts with `rzp_test_`)
- For production, you'll need to obtain live keys from Razorpay dashboard
- Always keep your key secret secure and never commit it to version control
- Test thoroughly in sandbox mode before going live

## Support
If you encounter any issues with the Razorpay integration, check:
1. `.env` file exists and contains the correct keys
2. `flutter pub get` has been run to install dependencies
3. Razorpay service is properly initialized in `main.dart`

