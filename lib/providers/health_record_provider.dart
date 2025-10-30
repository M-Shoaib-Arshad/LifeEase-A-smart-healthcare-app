import 'package:flutter/material.dart';
import '../models/health_record.dart';

class HealthRecordProvider with ChangeNotifier {
  List<HealthRecord> _records = [];

  List<HealthRecord> get records => _records;

  void setRecords(List<HealthRecord> records) {
    _records = records;
    notifyListeners();
  }

  void addRecord(HealthRecord record) {
    _records.add(record);
    notifyListeners();
  }

  void updateRecord(String id, HealthRecord updatedRecord) {
    final index = _records.indexWhere((rec) => rec.id == id);
    if (index != -1) {
      _records[index] = updatedRecord;
      notifyListeners();
    }
  }

  void removeRecord(String id) {
    _records.removeWhere((rec) => rec.id == id);
    notifyListeners();
  }
}