import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    this.status = 'scheduled',
    this.notes,
  });

  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? dateTime,
    String? status,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      // Store as Firestore Timestamp to avoid string parsing issues
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    // dateTime may be a Timestamp (Firestore) or a String (legacy)
    final dt = map['dateTime'];
    DateTime parsed;
    if (dt is Timestamp) {
      parsed = dt.toDate();
    } else if (dt is String) {
      parsed = DateTime.tryParse(dt) ?? DateTime.now();
    } else {
      parsed = DateTime.now();
    }

    return Appointment(
      id: (map['id'] ?? '') as String,
      patientId: (map['patientId'] ?? '') as String,
      doctorId: (map['doctorId'] ?? '') as String,
      dateTime: parsed,
      status: (map['status'] ?? 'scheduled') as String,
      notes: map['notes'] as String?,
    );
  }
}