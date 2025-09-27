import 'package:flutter/material.dart';
import '../../repos/emergency_contacts/emergency_contacts_repository.dart';

/// Emergency Contacts Provider
class EmergencyContactsProvider extends ChangeNotifier {
  final EmergencyContactsRepository _repository;

  EmergencyContactsProvider({required EmergencyContactsRepository repository})
      : _repository = repository;

  // State variables
  List<Map<String, dynamic>> _emergencyContacts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Map<String, dynamic>> get emergencyContacts => _emergencyContacts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Load emergency contacts
  Future<void> loadEmergencyContacts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _emergencyContacts = await _repository.getEmergencyContacts();
    } catch (e) {
      _errorMessage = 'Failed to load emergency contacts: $e';
      print('Error loading emergency contacts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add custom emergency contact
  Future<bool> addEmergencyContact(Map<String, dynamic> contact) async {
    try {
      final success = await _repository.addEmergencyContact(contact);
      if (success) {
        await loadEmergencyContacts(); // Reload the list
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to add emergency contact: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove emergency contact
  Future<bool> removeEmergencyContact(String contactId) async {
    try {
      final success = await _repository.removeEmergencyContact(contactId);
      if (success) {
        await loadEmergencyContacts(); // Reload the list
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to remove emergency contact: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update emergency contact
  Future<bool> updateEmergencyContact(String contactId, Map<String, dynamic> updatedContact) async {
    try {
      final success = await _repository.updateEmergencyContact(contactId, updatedContact);
      if (success) {
        await loadEmergencyContacts(); // Reload the list
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update emergency contact: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get emergency contact by type
  Map<String, dynamic>? getEmergencyContactByType(String type) {
    try {
      return _emergencyContacts.firstWhere(
        (contact) => contact['type'].toLowerCase() == type.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get emergency contacts by category
  List<Map<String, dynamic>> getEmergencyContactsByCategory(String category) {
    return _emergencyContacts.where(
      (contact) => contact['category'] == category,
    ).toList();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Refresh emergency contacts
  Future<void> refresh() async {
    await loadEmergencyContacts();
  }
}

