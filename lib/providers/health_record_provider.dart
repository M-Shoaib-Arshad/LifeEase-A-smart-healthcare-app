import 'package:flutter/material.dart';
import '../models/health_record.dart';
import '../services/api_service.dart';

class HealthRecordProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<HealthRecord> _records = [];

  List<HealthRecord> get records => _records;

  Future<void> loadForPatient(String patientId) async {
    final list = await _api.getHealthRecordsForPatient(patientId);
    _records = list;
    notifyListeners();
  }

  void setRecords(List<HealthRecord> records) {
    _records = records;
    notifyListeners();
  }

  Future<String> addRecord(HealthRecord record) async {
    final id = await _api.createHealthRecord(record);
    final saved = HealthRecord(
      id: id,
      patientId: record.patientId,
      date: record.date,
      vitals: record.vitals,
      diagnosis: record.diagnosis,
      prescriptions: record.prescriptions,
    );
    _records.add(saved);
    notifyListeners();
    return id;
  }

  Future<void> updateRecord(String id, HealthRecord updatedRecord) async {
    await _api.updateHealthRecord(updatedRecord);
    final index = _records.indexWhere((rec) => rec.id == id);
    if (index != -1) {
      _records[index] = updatedRecord;
      notifyListeners();
    }
  }

  Future<void> removeRecord(String id) async {
    await _api.deleteHealthRecord(id);
    _records.removeWhere((rec) => rec.id == id);
    notifyListeners();
  }

  void clear() {
    _records.clear();
    notifyListeners();
  }
}