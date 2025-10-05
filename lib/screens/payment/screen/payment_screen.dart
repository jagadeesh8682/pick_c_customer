import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/razorpay_service.dart';
import '../../invoice/screen/trip_invoice_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const PaymentScreen({super.key, required this.bookingData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    RazorpayService.initialize();
    RazorpayService.setPaymentSuccessHandler(_handlePaymentSuccess);
    RazorpayService.setPaymentErrorHandler(_handlePaymentError);
    RazorpayService.setExternalWalletHandler(_handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    // Don't dispose the service here as it might be used by other screens
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D5016), // Dark olive green background
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          'Payment',
          style: TextStyle(
            color: AppColors.primaryYellow,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryYellow),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // CRN Information Block
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'CRN: BK171000192',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Amount Information Block
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '₹ 276.66',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Cash Payment Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: () => _handleCashPayment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.payments,
                          color: AppColors.darkBackground,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'CASH PAYMENT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Online Payment Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleOnlinePayment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.credit_card,
                          color: AppColors.darkBackground,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'ONLINE PAYMENT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCashPayment() {
    // Handle cash payment
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cash Payment'),
          content: const Text(
            'Payment will be made in cash to the driver upon delivery.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToInvoice();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _handleOnlinePayment() async {
    if (!RazorpayService.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment service not initialized. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get amount from booking data
    final amount = double.parse(widget.bookingData['amount'] ?? '276.66');
    final amountInPaise = (amount * 100).toInt();

    try {
      await RazorpayService.openPayment(
        amount: amountInPaise,
        description: 'Cargo Booking Payment - ${widget.bookingData['crn']}',
        customerName: 'Customer',
        customerEmail: 'customer@pickc.com',
        customerPhone: '9876543210',
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');

    // Navigate to invoice screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TripInvoiceScreen(
          bookingData: {
            ...widget.bookingData,
            'paymentId': response.paymentId,
            'paymentStatus': 'success',
          },
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _navigateToInvoice() {
    // Navigate to invoice screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TripInvoiceScreen(
          bookingData: {...widget.bookingData, 'paymentStatus': 'cash_pending'},
        ),
      ),
    );
  }
}
