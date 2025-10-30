import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';
import '../models/health_record.dart';

class ApiService {
  final _db = FirebaseFirestore.instance;

  // Collections
  static const String appointmentsCol = 'appointments';
  static const String healthRecordsCol = 'health_records';

  // Appointments
  Future<String> createAppointment(Appointment appt) async {
    final doc = _db.collection(appointmentsCol).doc(appt.id.isEmpty ? null : appt.id);
    final ref = doc.id.isEmpty ? _db.collection(appointmentsCol).doc() : doc;
    await ref.set(appt.copyWith(id: ref.id).toMap());
    return ref.id;
  }

  Future<void> updateAppointment(Appointment appt) async {
    await _db.collection(appointmentsCol).doc(appt.id).update(appt.toMap());
  }

  Future<void> deleteAppointment(String id) async {
    await _db.collection(appointmentsCol).doc(id).delete();
  }

  Future<List<Appointment>> getAppointmentsForPatient(String patientId) async {
    final q = await _db
        .collection(appointmentsCol)
        .where('patientId', isEqualTo: patientId)
        .orderBy('dateTime', descending: false)
        .get();
    return q.docs.map((d) => Appointment.fromMap(d.data())).toList();
  }

  Future<List<Appointment>> getAppointmentsForDoctor(String doctorId) async {
    final q = await _db
        .collection(appointmentsCol)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('dateTime', descending: false)
        .get();
    return q.docs.map((d) => Appointment.fromMap(d.data())).toList();
  }

  // Health Records
  Future<String> createHealthRecord(HealthRecord record) async {
    final doc = _db.collection(healthRecordsCol).doc(record.id.isEmpty ? null : record.id);
    final ref = doc.id.isEmpty ? _db.collection(healthRecordsCol).doc() : doc;
    await ref.set(record.copyWith(id: ref.id).toMap());
    return ref.id;
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    await _db.collection(healthRecordsCol).doc(record.id).update(record.toMap());
  }

  Future<void> deleteHealthRecord(String id) async {
    await _db.collection(healthRecordsCol).doc(id).delete();
  }

  Future<List<HealthRecord>> getHealthRecordsForPatient(String patientId) async {
    final q = await _db
        .collection(healthRecordsCol)
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .get();
    return q.docs.map((d) => HealthRecord.fromMap(d.data())).toList();
  }
}

extension _AppointmentCopy on Appointment {
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
}

extension _HealthRecordCopy on HealthRecord {
  HealthRecord copyWith({
    String? id,
    String? patientId,
    DateTime? date,
    Map<String, dynamic>? vitals,
    String? diagnosis,
    String? prescriptions,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      vitals: vitals ?? this.vitals,
      diagnosis: diagnosis ?? this.diagnosis,
      prescriptions: prescriptions ?? this.prescriptions,
    );
  }
}