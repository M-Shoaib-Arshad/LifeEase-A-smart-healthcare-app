class HealthRecord {
  final String id;
  final String patientId;
  final DateTime date;
  final Map<String, dynamic> vitals; // e.g., {'bloodPressure': '120/80', 'heartRate': 72}
  final String? diagnosis;
  final String? prescriptions; // Comma-separated or JSON

  HealthRecord({
    required this.id,
    required this.patientId,
    required this.date,
    required this.vitals,
    this.diagnosis,
    this.prescriptions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'date': date.toIso8601String(),
      'vitals': vitals,
      'diagnosis': diagnosis,
      'prescriptions': prescriptions,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      vitals: Map<String, dynamic>.from(map['vitals'] ?? {}),
      diagnosis: map['diagnosis'],
      prescriptions: map['prescriptions'],
    );
  }
}