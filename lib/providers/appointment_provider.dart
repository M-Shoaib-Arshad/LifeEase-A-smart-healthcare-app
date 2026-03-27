import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final CacheService _cache = CacheService();
  final List<Appointment> _appointments = [];

  List<Appointment> get appointments => List.unmodifiable(_appointments);

  Future<void> loadForPatient(String patientId) async {
    try {
      final list = await _api.getAppointmentsForPatient(patientId);
      _appointments
        ..clear()
        ..addAll(list);
      // Persist to cache for offline access
      await _cache.cacheAppointments(
          list.map((a) => a.toMap()).toList());
    } catch (e) {
      debugPrint('AppointmentProvider.loadForPatient: offline fallback – $e');
      // Fall back to locally cached data when offline / network error
      final cached = _cache.getCachedAppointments();
      _appointments
        ..clear()
        ..addAll(cached.map(Appointment.fromMap));
    }
    notifyListeners();
  }

  Future<void> loadForDoctor(String doctorId) async {
    try {
      final list = await _api.getAppointmentsForDoctor(doctorId);
      _appointments
        ..clear()
        ..addAll(list);
      await _cache.cacheAppointments(
          list.map((a) => a.toMap()).toList());
    } catch (e) {
      debugPrint('AppointmentProvider.loadForDoctor: offline fallback – $e');
      final cached = _cache.getCachedAppointments();
      _appointments
        ..clear()
        ..addAll(cached.map(Appointment.fromMap));
    }
    notifyListeners();
  }

  Future<String> add(Appointment appt) async {
    final id = await _api.createAppointment(appt);
    final saved = appt.copyWith(id: id);
    _appointments.add(saved);
    // Refresh the cache with the updated list
    await _cache.cacheAppointments(
        _appointments.map((a) => a.toMap()).toList());
    notifyListeners();
    return id;
  }

  Future<void> update(Appointment appt) async {
    await _api.updateAppointment(appt);
    final i = _appointments.indexWhere((a) => a.id == appt.id);
    if (i != -1) {
      _appointments[i] = appt;
      await _cache.cacheAppointments(
          _appointments.map((a) => a.toMap()).toList());
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    await _api.deleteAppointment(id);
    _appointments.removeWhere((a) => a.id == id);
    await _cache.cacheAppointments(
        _appointments.map((a) => a.toMap()).toList());
    notifyListeners();
  }

  void clear() {
    _appointments.clear();
    notifyListeners();
  }
}