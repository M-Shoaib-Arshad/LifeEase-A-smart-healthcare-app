import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/emergency_contact.dart';

class EmergencyService {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// Dial emergency services (112 international)
  Future<void> callEmergencyServices() async {
    final uri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Cannot launch phone dialer. Please dial 112 manually.');
    }
  }

  /// Dial a saved emergency contact
  Future<void> callContact(EmergencyContact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception(
          'Cannot launch phone dialer for ${contact.name}. Please dial ${contact.phone} manually.');
    }
  }

  /// Send SMS with current location to all emergency contacts
  Future<void> sendSOSWithLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final contacts = await getEmergencyContacts();
      final mapsUrl =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      final body = 'EMERGENCY: I need help. My location: $mapsUrl';

      for (final c in contacts) {
        final uri = Uri(
          scheme: 'sms',
          path: c.phone,
          queryParameters: {'body': body},
        );
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error sending SOS with location: $e');
      rethrow;
    }
  }

  /// Retrieve all saved emergency contacts for the current user
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('emergency_contacts')
        .get();
    return snap.docs
        .map((d) => EmergencyContact.fromMap(d.data()))
        .toList();
  }

  /// Add a new emergency contact, auto-generating a Firestore document id
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    final ref = _db
        .collection('users')
        .doc(_uid)
        .collection('emergency_contacts')
        .doc();
    await ref.set({...contact.toMap(), 'id': ref.id});
  }

  /// Delete an emergency contact by its Firestore document id
  Future<void> deleteEmergencyContact(String contactId) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('emergency_contacts')
        .doc(contactId)
        .delete();
  }
}
