import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../provider/emergency_contacts_provider.dart';

/// Emergency Contacts Screen
class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyContactsProvider>().loadEmergencyContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Emergency',
          style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<EmergencyContactsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: provider.emergencyContacts.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final contact = provider.emergencyContacts[index];
                  return _buildEmergencyContactItem(contact);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build Emergency Contact Item
  Widget _buildEmergencyContactItem(Map<String, dynamic> contact) {
    return InkWell(
      onTap: () => _handleContactTap(contact),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getIconColor(contact['type']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _getIcon(contact['type']),
                color: _getIconColor(contact['type']),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact['number'],
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Call Button
            IconButton(
              onPressed: () => _handleCall(contact['number']),
              icon: Icon(Icons.phone, color: Colors.green[600], size: 28),
            ),
          ],
        ),
      ),
    );
  }

  /// Get icon for emergency type
  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'police':
        return Icons.local_police;
      case 'fire':
        return Icons.local_fire_department;
      case 'ambulance':
        return Icons.local_hospital;
      default:
        return Icons.emergency;
    }
  }

  /// Get icon color for emergency type
  Color _getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'police':
        return Colors.blue[700]!;
      case 'fire':
        return Colors.red[600]!;
      case 'ambulance':
        return Colors.green[600]!;
      default:
        return Colors.orange[600]!;
    }
  }

  /// Handle contact tap
  void _handleContactTap(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(contact['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Number: ${contact['number']}'),
            const SizedBox(height: 8),
            Text('Description: ${contact['description']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleCall(contact['number']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  /// Handle call action
  void _handleCall(String number) {
    // Remove any spaces and special characters except + and -
    final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Emergency Service'),
        content: Text('Do you want to call $cleanNumber?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _makeCall(cleanNumber);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  /// Make the actual call
  void _makeCall(String number) {
    try {
      // Copy number to clipboard
      Clipboard.setData(ClipboardData(text: number));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Number $number copied to clipboard'),
          backgroundColor: Colors.green[600],
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      // Note: In a real app, you would use url_launcher to make actual calls
      // For now, we'll just copy the number to clipboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red[600]),
      );
    }
  }
}
