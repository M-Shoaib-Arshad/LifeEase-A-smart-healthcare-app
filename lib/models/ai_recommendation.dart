class AiRecommendation {
  final String id;
  final String patientId;
  final String symptomData; // e.g., JSON string of symptoms
  final String suggestions; // e.g., advice text
  final DateTime generatedAt;

  AiRecommendation({
    required this.id,
    required this.patientId,
    required this.symptomData,
    required this.suggestions,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'symptomData': symptomData,
      'suggestions': suggestions,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory AiRecommendation.fromMap(Map<String, dynamic> map) {
    return AiRecommendation(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      symptomData: map['symptomData'] ?? '',
      suggestions: map['suggestions'] ?? '',
      generatedAt: DateTime.parse(map['generatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}