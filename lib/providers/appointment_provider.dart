import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final List<Appointment> _appointments = [];

  List<Appointment> get appointments => List.unmodifiable(_appointments);

  Future<void> loadForPatient(String patientId) async {
    final list = await _api.getAppointmentsForPatient(patientId);
    _appointments
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  Future<void> loadForDoctor(String doctorId) async {
    final list = await _api.getAppointmentsForDoctor(doctorId);
    _appointments
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  Future<String> add(Appointment appt) async {
    final id = await _api.createAppointment(appt);
    final saved = appt.copyWith(id: id);
    _appointments.add(saved);
    notifyListeners();
    return id;
  }

  Future<void> update(Appointment appt) async {
    await _api.updateAppointment(appt);
    final i = _appointments.indexWhere((a) => a.id == appt.id);
    if (i != -1) {
      _appointments[i] = appt;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    await _api.deleteAppointment(id);
    _appointments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void clear() {
    _appointments.clear();
    notifyListeners();
  }
}