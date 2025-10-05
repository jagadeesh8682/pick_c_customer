import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/booking_history_provider.dart';

/// Booking History Screen showing past truck bookings
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load booking history when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingHistoryProvider>().loadBookingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Consumer<BookingHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          if (!provider.hasBookings) {
            return _buildEmptyState();
          }

          return _buildBookingList(provider);
        },
      ),
    );
  }

  /// Build custom app bar with dark background and yellow text
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[800],
      foregroundColor: Colors.yellow,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
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
      actions: [
        IconButton(
          onPressed: () {
            context.read<BookingHistoryProvider>().refresh();
          },
          icon: const Icon(Icons.refresh, color: Colors.yellow),
        ),
      ],
    );
  }

  /// Build scrollable list of booking entries
  Widget _buildBookingList(BookingHistoryProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.bookingHistory.length,
        itemBuilder: (context, index) {
          final booking = provider.bookingHistory[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBookingCard(
              booking: booking,
              onCancel:
                  booking['status'] == 'in_progress' ||
                      booking['status'] == 'pending'
                  ? () => _showCancelDialog(
                      context,
                      provider,
                      booking['bookingId'],
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(BookingHistoryProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              provider.error ?? 'An error occurred',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadBookingHistory(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No booking history found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your past truck bookings will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Show cancel booking dialog
  void _showCancelDialog(
    BuildContext context,
    BookingHistoryProvider provider,
    String bookingId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.cancelBooking(bookingId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled successfully'),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to cancel booking')),
                );
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  /// Build individual booking card
  Widget _buildBookingCard({
    required Map<String, dynamic> booking,
    VoidCallback? onCancel,
  }) {
    final date = _formatDate(booking['bookingTime'] ?? '');
    final cost = '₹ ${booking['fare']?.toString() ?? '0.0'}';
    final pickupLocation = booking['pickupLocation'] ?? 'Unknown location';
    final dropLocation = booking['dropLocation'] ?? 'Unknown location';
    final bookingId = booking['bookingId'] ?? 'Unknown ID';
    final rating = booking['rating'] ?? 0;
    final truckSpecs =
        '${booking['truckType'] ?? 'Unknown'} - ${booking['truckNumber'] ?? 'N/A'}';
    final status = booking['status'] ?? 'unknown';
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
          _buildBookingHeader(date, cost, status),
          // Content with light grey background
          _buildBookingContent(
            pickupLocation,
            dropLocation,
            bookingId,
            rating,
            truckSpecs,
            onCancel,
          ),
        ],
      ),
    );
  }

  /// Build booking header with dark background
  Widget _buildBookingHeader(String date, String cost, String status) {
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
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(
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
    VoidCallback? onCancel,
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
          // Cancel button if applicable
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel Booking'),
              ),
            ),
          ],
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

  /// Get status color based on booking status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Format date string
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today, ${_formatTime(date)}';
      } else if (difference.inDays == 1) {
        return 'Yesterday, ${_formatTime(date)}';
      } else if (difference.inDays < 7) {
        return '${_getWeekdayName(date.weekday)}, ${_formatTime(date)}';
      } else {
        return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  /// Format time
  String _formatTime(DateTime date) {
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final displayHour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    return '$displayHour:$minute $period';
  }

  /// Get weekday name
  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }
}
