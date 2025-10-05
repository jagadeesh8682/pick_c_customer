import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../rating/screen/driver_rating_screen.dart';

class TripInvoiceScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const TripInvoiceScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          'Pick-C',
          style: TextStyle(
            color: AppColors.primaryYellow,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryYellow),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInvoiceHeader(),
            const SizedBox(height: 20),
            _buildCustomerDetails(),
            const SizedBox(height: 20),
            _buildTotalBillAmount(),
            const SizedBox(height: 20),
            _buildBillBreakup(),
            const SizedBox(height: 20),
            _buildOtherCharges(),
            const SizedBox(height: 20),
            _buildGSTAndTotal(),
            const SizedBox(height: 30),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: AppColors.primaryYellow,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRIP INVOICE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCurrentDate(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Customer Name', 'XYZ'),
          const SizedBox(height: 12),
          _buildDetailRow('CRN No.', bookingData['crn'] ?? 'BK171000192'),
        ],
      ),
    );
  }

  Widget _buildTotalBillAmount() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL BILL AMOUNT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${bookingData['amount'] ?? '277.00'}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillBreakup() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL BILL BREAKUP',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(color: AppColors.textSecondary),
          const SizedBox(height: 16),
          _buildBreakupRow('Base Fare for 3.00 km', '₹ 250.00'),
          _buildBreakupRow('Distance Fare for 0.00 km', '₹ 0.00'),
          _buildBreakupRow('Travel Time Fare for 11 Mins', '₹ 11.00'),
          const SizedBox(height: 12),
          _buildBreakupRow('Total Fare', '₹ 261.00', isHighlighted: true),
        ],
      ),
    );
  }

  Widget _buildOtherCharges() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OTHER CHARGES',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(color: AppColors.textSecondary),
          const SizedBox(height: 16),
          _buildBreakupRow('Loading & UnLoading Charges', '₹ 0.00'),
          _buildBreakupRow('Waiting / Night time Charges', '₹ 0.00'),
          _buildBreakupRow('Offers / Discount', '₹ 0.00'),
          const SizedBox(height: 12),
          _buildBreakupRow(
            'Other Charges Total',
            '₹ 261.00',
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGSTAndTotal() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBreakupRow('GST - 6%', '₹ 15.66'),
          const SizedBox(height: 12),
          _buildBreakupRow(
            'Total Bill Amount (rounded off)',
            '₹ ${bookingData['amount'] ?? '277.00'}',
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'CONTACT US',
          Icons.phone,
          () => _handleContactUs(context),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          'EMAIL INVOICE',
          Icons.email,
          () => _handleEmailInvoice(context),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          'RATE THE DRIVER',
          Icons.star,
          () => _handleRateDriver(context),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label :',
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakupRow(
    String label,
    String amount, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primaryYellow.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted
                    ? AppColors.darkBackground
                    : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: isHighlighted
                  ? AppColors.darkBackground
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.info,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        icon: Icon(icon, color: AppColors.primaryYellow, size: 24),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  void _handleContactUs(BuildContext context) {
    // Copy phone number to clipboard
    Clipboard.setData(const ClipboardData(text: '+91-9876543210'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone number copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleEmailInvoice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice email sent successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleRateDriver(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverRatingScreen(bookingData: bookingData),
      ),
    );
  }
}
