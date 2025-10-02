import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../constants/razorpay_config.dart';

class RazorpayService {
  static Razorpay? _razorpay;
  static bool _isInitialized = false;

  static void initialize() {
    if (_isInitialized) return;

    try {
      _razorpay = Razorpay();
      _isInitialized = true;
      print('Razorpay initialized successfully');
    } catch (e) {
      print('Error initializing Razorpay: $e');
      _isInitialized = false;
    }
  }

  static void setPaymentSuccessHandler(
    Function(PaymentSuccessResponse) handler,
  ) {
    if (_razorpay != null) {
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, handler);
    }
  }

  static void setPaymentErrorHandler(Function(PaymentFailureResponse) handler) {
    if (_razorpay != null) {
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, handler);
    }
  }

  static void setExternalWalletHandler(
    Function(ExternalWalletResponse) handler,
  ) {
    if (_razorpay != null) {
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, handler);
    }
  }

  static Future<void> openPayment({
    required int amount,
    required String description,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    if (!_isInitialized || _razorpay == null) {
      throw Exception('Razorpay not initialized');
    }

    final options = RazorpayConfig.getPaymentOptions(
      amount: amount,
      description: description,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
    );

    try {
      _razorpay!.open(options);
    } catch (e) {
      throw Exception('Failed to open payment: $e');
    }
  }

  static void dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _isInitialized = false;
  }

  static bool get isInitialized => _isInitialized;
}
