/// Emergency Contacts Repository
class EmergencyContactsRepository {
  /// Get emergency contacts
  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock emergency contacts data
    return [
      {
        'id': 'police_001',
        'name': 'Police',
        'number': '100',
        'type': 'police',
        'category': 'emergency',
        'description': 'Emergency police services for immediate assistance',
        'priority': 1,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'fire_001',
        'name': 'Fire Department',
        'number': '101',
        'type': 'fire',
        'category': 'emergency',
        'description':
            'Fire department for fire emergencies and rescue operations',
        'priority': 2,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'ambulance_001',
        'name': 'Ambulance',
        'number': '102,108',
        'type': 'ambulance',
        'category': 'emergency',
        'description': 'Medical emergency services and ambulance',
        'priority': 3,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];
  }

  /// Add emergency contact
  Future<bool> addEmergencyContact(Map<String, dynamic> contact) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock implementation - in real app, this would make API call
    print(
      'Adding emergency contact: ${contact['name']} - ${contact['number']}',
    );

    // Return success
    return true;
  }

  /// Remove emergency contact
  Future<bool> removeEmergencyContact(String contactId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock implementation - in real app, this would make API call
    print('Removing emergency contact: $contactId');

    // Return success
    return true;
  }

  /// Update emergency contact
  Future<bool> updateEmergencyContact(
    String contactId,
    Map<String, dynamic> updatedContact,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock implementation - in real app, this would make API call
    print('Updating emergency contact: $contactId');
    print('Updated data: $updatedContact');

    // Return success
    return true;
  }

  /// Get emergency contact by ID
  Future<Map<String, dynamic>?> getEmergencyContactById(
    String contactId,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Get all contacts and find the one with matching ID
    final contacts = await getEmergencyContacts();
    try {
      return contacts.firstWhere((contact) => contact['id'] == contactId);
    } catch (e) {
      return null;
    }
  }

  /// Get emergency contacts by type
  Future<List<Map<String, dynamic>>> getEmergencyContactsByType(
    String type,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final contacts = await getEmergencyContacts();
    return contacts.where((contact) => contact['type'] == type).toList();
  }

  /// Get emergency contacts by category
  Future<List<Map<String, dynamic>>> getEmergencyContactsByCategory(
    String category,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final contacts = await getEmergencyContacts();
    return contacts
        .where((contact) => contact['category'] == category)
        .toList();
  }

  /// Search emergency contacts
  Future<List<Map<String, dynamic>>> searchEmergencyContacts(
    String query,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final contacts = await getEmergencyContacts();
    final lowercaseQuery = query.toLowerCase();

    return contacts.where((contact) {
      final name = contact['name'].toString().toLowerCase();
      final number = contact['number'].toString().toLowerCase();
      final description = contact['description'].toString().toLowerCase();

      return name.contains(lowercaseQuery) ||
          number.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();
  }

  /// Get emergency contact statistics
  Future<Map<String, dynamic>> getEmergencyContactStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final contacts = await getEmergencyContacts();

    return {
      'totalContacts': contacts.length,
      'activeContacts': contacts.where((c) => c['isActive'] == true).length,
      'emergencyContacts': contacts
          .where((c) => c['category'] == 'emergency')
          .length,
      'supportContacts': contacts
          .where((c) => c['category'] == 'support')
          .length,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
}

