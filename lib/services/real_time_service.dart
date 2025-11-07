import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';
import '../models/health_record.dart';
import '../models/health_data.dart';

/// Service for managing real-time Firestore data streams
/// Provides live updates for appointments, health records, and health data
class RealTimeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection names
  static const String _appointmentsCol = 'appointments';
  static const String _healthRecordsCol = 'health_records';
  static const String _healthDataCol = 'health_data';
  static const String _usersCol = 'users';

  /// Stream of appointments for a patient
  /// Updates in real-time as appointments are added, modified, or deleted
  Stream<List<Appointment>> getPatientAppointmentsStream(String patientId) {
    return _db
        .collection(_appointmentsCol)
        .where('patientId', isEqualTo: patientId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    });
  }

  /// Stream of appointments for a doctor
  /// Updates in real-time as appointments are scheduled or modified
  Stream<List<Appointment>> getDoctorAppointmentsStream(String doctorId) {
    return _db
        .collection(_appointmentsCol)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    });
  }

  /// Stream of a specific appointment
  /// Useful for tracking status changes of a single appointment
  Stream<Appointment?> getAppointmentStream(String appointmentId) {
    return _db
        .collection(_appointmentsCol)
        .doc(appointmentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Appointment.fromMap(doc.data()!);
    });
  }

  /// Stream of health records for a patient
  /// Provides real-time updates of medical records
  Stream<List<HealthRecord>> getHealthRecordsStream(String patientId) {
    return _db
        .collection(_healthRecordsCol)
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => HealthRecord.fromMap(doc.data()))
          .toList();
    });
  }

  /// Stream of health data for a patient
  /// Used for real-time health tracking dashboard
  Stream<List<HealthData>> getHealthDataStream(
    String patientId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _db
        .collection(_healthDataCol)
        .where('patientId', isEqualTo: patientId);

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: endDate);
    }

    query = query.orderBy('date', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => HealthData.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Stream of upcoming appointments count for a patient
  /// Useful for dashboard badges and notifications
  Stream<int> getUpcomingAppointmentsCount(String patientId) {
    final now = DateTime.now();
    return _db
        .collection(_appointmentsCol)
        .where('patientId', isEqualTo: patientId)
        .where('dateTime', isGreaterThanOrEqualTo: now)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Stream of today's appointments for a doctor
  /// Useful for doctor's daily schedule view
  Stream<List<Appointment>> getTodayAppointmentsStream(String doctorId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _db
        .collection(_appointmentsCol)
        .where('doctorId', isEqualTo: doctorId)
        .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
        .where('dateTime', isLessThanOrEqualTo: endOfDay)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    });
  }

  /// Stream of user profile data
  /// Useful for real-time profile updates across the app
  Stream<Map<String, dynamic>?> getUserProfileStream(String userId) {
    return _db
        .collection(_usersCol)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return doc.data();
    });
  }

  /// Stream of pending appointments for admin/doctor approval
  Stream<List<Appointment>> getPendingAppointmentsStream() {
    return _db
        .collection(_appointmentsCol)
        .where('status', isEqualTo: 'pending')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    });
  }

  /// Stream of appointments filtered by status
  Stream<List<Appointment>> getAppointmentsByStatusStream(
    String userId,
    String status, {
    bool isDoctor = false,
  }) {
    final field = isDoctor ? 'doctorId' : 'patientId';
    return _db
        .collection(_appointmentsCol)
        .where(field, isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    });
  }

  /// Stream of latest health data entry
  /// Useful for quick health status overview
  Stream<HealthData?> getLatestHealthDataStream(String patientId) {
    return _db
        .collection(_healthDataCol)
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return HealthData.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
    });
  }

  /// Dispose method to clean up resources if needed
  /// Currently not needed as Firestore manages connections automatically
  void dispose() {
    // Firestore automatically manages connection lifecycle
    // This method is provided for future extensibility
  }

  /// Check connection status (returns true if Firestore is available)
  Future<bool> checkConnection() async {
    try {
      await _db
          .collection('_connection_test')
          .doc('test')
          .get()
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      return false;
    }
  }
}
