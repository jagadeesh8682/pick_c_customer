import 'package:flutter/material.dart';

/// Booking History Screen showing past truck bookings
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: _buildBookingList(),
    );
  }

  /// Build custom app bar with dark background and yellow text
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[800],
      foregroundColor: Colors.yellow,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          // Navigate back
        },
        icon: const Icon(Icons.arrow_back, color: Colors.yellow),
      ),
      title: const Text(
        'Your Bookings History',
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Build scrollable list of booking entries
  Widget _buildBookingList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBookingCard(
          date: 'Mon, Jun 02, 2025 10:13 AM',
          cost: '₹ 556.0',
          pickupLocation: 'F959+48 Kondapur, Telangana, India',
          dropLocation:
              'Lemon Tree (Hitec City), Phase 2, HITEC City, Hyderabad, Telangana',
          bookingId: 'BK250600002',
          rating: 4,
          truckSpecs: '700kgs - Mini - Open Truck',
        ),
        const SizedBox(height: 12),
        _buildBookingCard(
          date: 'Wed, Mar 19, 2025 10:14 AM',
          cost: '₹ 10786.0',
          pickupLocation:
              'Krishe Emerald, Krishe Emerald, Laxmi Cyber City, Whitefields, Kondapur,',
          dropLocation:
              'Kondapur, opposite Harsha Toyota, Land Mark Residency, Kondapur,',
          bookingId: 'BK250300004',
          rating: 4,
          truckSpecs: '700kgs - Mini - Open Truck',
        ),
        const SizedBox(height: 12),
        _buildBookingCard(
          date: 'Wed, Jan 22, 2025 23:34 PM',
          cost: '₹ 377.0',
          pickupLocation:
              'No: 8, Raja Rajeswari nagar, behind 8th Betalion, Raghavendra Colony,',
          dropLocation:
              'Mikkilineni Residency, 440, Park Avenue Colony, Raja Rajeshwara Nagar,',
          bookingId: 'BK250100005',
          rating: 4,
          truckSpecs: '700kgs - Mini - Open Truck',
        ),
        const SizedBox(height: 12),
        _buildBookingCard(
          date: 'Thu, Dec 19, 2024 22:17 PM',
          cost: '₹ 0.0',
          pickupLocation:
              'No: 8, Raja Rajeswari nagar, behind 8th Betalion, Raghavendra Colony,',
          dropLocation:
              '1422, near Tata Motors, Park Avenue Colony, Raja Rajeshwara Nagar,',
          bookingId: 'BK241200008',
          rating: 4,
          truckSpecs: '700kgs - Mini - Open Truck',
        ),
      ],
    );
  }

  /// Build individual booking card
  Widget _buildBookingCard({
    required String date,
    required String cost,
    required String pickupLocation,
    required String dropLocation,
    required String bookingId,
    required int rating,
    required String truckSpecs,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with dark background
          _buildBookingHeader(date, cost),
          // Content with light grey background
          _buildBookingContent(
            pickupLocation,
            dropLocation,
            bookingId,
            rating,
            truckSpecs,
          ),
        ],
      ),
    );
  }

  /// Build booking header with dark background
  Widget _buildBookingHeader(String date, String cost) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Truck icon in yellow circle
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Date and cost
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  cost,
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Paid status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'PAID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build booking content with light grey background
  Widget _buildBookingContent(
    String pickupLocation,
    String dropLocation,
    String bookingId,
    int rating,
    String truckSpecs,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pickup location
          _buildLocationRow(
            icon: Icons.flag,
            iconColor: Colors.green,
            location: pickupLocation,
          ),
          const SizedBox(height: 8),
          // Drop location
          _buildLocationRow(
            icon: Icons.flag,
            iconColor: Colors.red,
            location: dropLocation,
          ),
          const SizedBox(height: 12),
          // Divider
          Container(height: 1, color: Colors.grey[400]),
          const SizedBox(height: 12),
          // Driver rating and booking details
          Row(
            children: [
              // Driver icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.black, size: 18),
              ),
              const SizedBox(width: 8),
              // Rating
              Text(
                '$rating',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              // Stars
              ...List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 16,
                  color: index < rating ? Colors.yellow : Colors.grey[400],
                );
              }),
              const SizedBox(width: 16),
              // Booking ID
              Text(
                bookingId,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Truck specifications
          Text(
            truckSpecs,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build location row with icon and text
  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String location,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
