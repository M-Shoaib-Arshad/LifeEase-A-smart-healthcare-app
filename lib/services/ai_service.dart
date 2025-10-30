import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ai_recommendation.dart';
import '../models/user.dart';
import '../models/health_data.dart';

/// AI Service for handling chatbot interactions and health recommendations
/// Implements SRS UC-06 and FR-07 requirements:
/// - Symptom-based triage
/// - Doctor recommendations based on budget/health data
/// - Compliance logging for audit trails
/// - User consent management
class AiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  static const String aiRecommendationsCol = 'ai_recommendations';
  static const String aiInteractionsCol = 'ai_interactions';
  static const String userConsentsCol = 'user_consents';

  // AI API Configuration (placeholder for OpenAI or similar)
  // In production, these would come from environment variables
  static const String _aiApiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _defaultModel = 'gpt-3.5-turbo';

  /// Standard medical disclaimer for non-emergency advice
  static const String medicalDisclaimer = '''
IMPORTANT MEDICAL DISCLAIMER:
This is not a substitute for professional medical advice, diagnosis, or treatment. 
Always seek the advice of your physician or other qualified health provider with any 
questions you may have regarding a medical condition. 

IF YOU THINK YOU MAY HAVE A MEDICAL EMERGENCY, CALL YOUR DOCTOR OR 911 IMMEDIATELY. 
Do not rely solely on this AI-generated information.
''';

  /// Query AI for symptom-based triage
  /// Returns AI-generated advice based on symptoms
  Future<String> querySymptoms({
    required String patientId,
    required List<String> symptoms,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      // Log the interaction for compliance
      await _logInteraction(
        patientId: patientId,
        interactionType: 'symptom_query',
        inputData: {
          'symptoms': symptoms,
          'context': additionalContext,
        },
      );

      // Build prompt for AI
      final prompt = _buildSymptomTriagePrompt(symptoms, additionalContext);

      // Call AI API (placeholder - in production, use actual API)
      final aiResponse = await _callAiApi(prompt);

      // Log the response
      await _logInteraction(
        patientId: patientId,
        interactionType: 'symptom_response',
        inputData: {'response': aiResponse},
      );

      // Prepend disclaimer to response
      return '$medicalDisclaimer\n\nBased on your symptoms:\n$aiResponse';
    } catch (e) {
      // Log error
      await _logInteraction(
        patientId: patientId,
        interactionType: 'error',
        inputData: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Generate doctor recommendations based on budget and health data
  Future<Map<String, dynamic>> recommendDoctors({
    required String patientId,
    required String condition,
    double? budget,
    Map<String, dynamic>? healthData,
    String? location,
  }) async {
    try {
      // Log the interaction
      await _logInteraction(
        patientId: patientId,
        interactionType: 'doctor_recommendation',
        inputData: {
          'condition': condition,
          'budget': budget,
          'location': location,
        },
      );

      // Build prompt for doctor recommendation
      final prompt = _buildDoctorRecommendationPrompt(
        condition: condition,
        budget: budget,
        healthData: healthData,
        location: location,
      );

      // Call AI API
      final aiResponse = await _callAiApi(prompt);

      // Parse and structure the response
      final recommendation = {
        'condition': condition,
        'recommendations': aiResponse,
        'budget': budget,
        'location': location,
        'disclaimer': medicalDisclaimer,
        'generatedAt': DateTime.now().toIso8601String(),
      };

      return recommendation;
    } catch (e) {
      await _logInteraction(
        patientId: patientId,
        interactionType: 'error',
        inputData: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Save AI recommendation with user consent
  Future<String> saveRecommendation({
    required String patientId,
    required String symptomData,
    required String suggestions,
    required bool userConsent,
  }) async {
    // Check user consent
    if (!userConsent) {
      throw Exception('User consent required to save recommendation');
    }

    // Verify consent is on record
    final hasConsent = await _verifyUserConsent(patientId);
    if (!hasConsent) {
      throw Exception('User consent not found in records');
    }

    // Create recommendation
    final recommendation = AiRecommendation(
      id: '', // Will be set by Firestore
      patientId: patientId,
      symptomData: symptomData,
      suggestions: suggestions,
      generatedAt: DateTime.now(),
    );

    // Save to Firestore
    final docRef = await _db.collection(aiRecommendationsCol).add(recommendation.toMap());

    // Log the save action
    await _logInteraction(
      patientId: patientId,
      interactionType: 'recommendation_saved',
      inputData: {
        'recommendationId': docRef.id,
      },
    );

    return docRef.id;
  }

  /// Retrieve saved recommendations for a patient
  Future<List<AiRecommendation>> getPatientRecommendations(String patientId) async {
    try {
      final querySnapshot = await _db
          .collection(aiRecommendationsCol)
          .where('patientId', isEqualTo: patientId)
          .orderBy('generatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AiRecommendation.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      await _logInteraction(
        patientId: patientId,
        interactionType: 'error',
        inputData: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Record user consent for AI recommendations
  Future<void> recordUserConsent({
    required String patientId,
    required bool consentGiven,
    String? consentType,
  }) async {
    await _db.collection(userConsentsCol).doc(patientId).set({
      'patientId': patientId,
      'consentGiven': consentGiven,
      'consentType': consentType ?? 'ai_recommendations',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Verify if user has given consent
  Future<bool> _verifyUserConsent(String patientId) async {
    try {
      final doc = await _db.collection(userConsentsCol).doc(patientId).get();
      if (!doc.exists) return false;
      
      final data = doc.data();
      return data?['consentGiven'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Log AI interaction for compliance and audit trails
  /// Implements FR-07 requirement for audit logging
  Future<void> _logInteraction({
    required String patientId,
    required String interactionType,
    required Map<String, dynamic> inputData,
  }) async {
    try {
      await _db.collection(aiInteractionsCol).add({
        'patientId': patientId,
        'interactionType': interactionType,
        'inputData': inputData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silent fail for logging to not block main functionality
      // In production, this should be sent to error monitoring service
      print('Failed to log AI interaction: $e');
    }
  }

  /// Build prompt for symptom triage
  String _buildSymptomTriagePrompt(
    List<String> symptoms,
    Map<String, dynamic>? context,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('You are a medical AI assistant. Provide triage advice for the following symptoms:');
    buffer.writeln('\nSymptoms:');
    for (final symptom in symptoms) {
      buffer.writeln('- $symptom');
    }

    if (context != null && context.isNotEmpty) {
      buffer.writeln('\nAdditional Context:');
      context.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }

    buffer.writeln('\nProvide:');
    buffer.writeln('1. Possible conditions');
    buffer.writeln('2. Urgency level (routine, urgent, emergency)');
    buffer.writeln('3. Recommended next steps');
    buffer.writeln('4. When to seek immediate medical attention');

    return buffer.toString();
  }

  /// Build prompt for doctor recommendations
  String _buildDoctorRecommendationPrompt({
    required String condition,
    double? budget,
    Map<String, dynamic>? healthData,
    String? location,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('You are a healthcare advisor. Recommend appropriate medical specialists for:');
    buffer.writeln('\nCondition: $condition');

    if (budget != null) {
      buffer.writeln('Budget: \$$budget');
    }

    if (location != null) {
      buffer.writeln('Location: $location');
    }

    if (healthData != null && healthData.isNotEmpty) {
      buffer.writeln('\nPatient Health Data:');
      healthData.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }

    buffer.writeln('\nProvide:');
    buffer.writeln('1. Recommended specialist types (e.g., cardiologist, neurologist)');
    buffer.writeln('2. Priority level for consultation');
    buffer.writeln('3. What to prepare for the appointment');
    buffer.writeln('4. Estimated consultation approach');

    return buffer.toString();
  }

  /// Call AI API (placeholder implementation)
  /// In production, this would make actual HTTP calls to OpenAI or similar
  Future<String> _callAiApi(String prompt) async {
    // TODO: Implement actual API call to OpenAI or similar service
    // For now, return a placeholder response
    
    // In production, this would be:
    // final response = await http.post(
    //   Uri.parse(_aiApiEndpoint),
    //   headers: {
    //     'Authorization': 'Bearer $apiKey',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode({
    //     'model': _defaultModel,
    //     'messages': [
    //       {'role': 'system', 'content': 'You are a medical AI assistant.'},
    //       {'role': 'user', 'content': prompt},
    //     ],
    //   }),
    // );

    // Placeholder response
    await Future.delayed(const Duration(milliseconds: 500));
    return 'AI-generated response based on the provided information. '
        'Please consult with a healthcare professional for proper diagnosis and treatment.';
  }

  /// Generate chatbot response for general health queries
  Future<String> generateChatbotResponse({
    required String patientId,
    required String query,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      // Log the interaction
      await _logInteraction(
        patientId: patientId,
        interactionType: 'chatbot_query',
        inputData: {
          'query': query,
          'hasHistory': conversationHistory != null && conversationHistory.isNotEmpty,
        },
      );

      // Build conversation context
      final buffer = StringBuffer();
      buffer.writeln('You are a healthcare AI assistant. Respond to the following query:');
      
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        buffer.writeln('\nConversation History:');
        for (final message in conversationHistory) {
          buffer.writeln('${message['role']}: ${message['content']}');
        }
      }
      
      buffer.writeln('\nCurrent Query: $query');

      // Call AI API
      final aiResponse = await _callAiApi(buffer.toString());

      // Log response
      await _logInteraction(
        patientId: patientId,
        interactionType: 'chatbot_response',
        inputData: {'response': aiResponse},
      );

      return '$aiResponse\n\n$medicalDisclaimer';
    } catch (e) {
      await _logInteraction(
        patientId: patientId,
        interactionType: 'error',
        inputData: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Get interaction history for audit purposes
  Future<List<Map<String, dynamic>>> getInteractionHistory({
    required String patientId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      Query query = _db
          .collection(aiInteractionsCol)
          .where('patientId', isEqualTo: patientId)
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a specific recommendation
  Future<void> deleteRecommendation(String recommendationId) async {
    await _db.collection(aiRecommendationsCol).doc(recommendationId).delete();
  }

  /// Get medical disclaimer text
  String getDisclaimer() {
    return medicalDisclaimer;
  }

  /// Check if emergency keywords are present in symptoms
  bool containsEmergencyKeywords(List<String> symptoms) {
    final emergencyKeywords = [
      'chest pain',
      'difficulty breathing',
      'severe bleeding',
      'unconscious',
      'seizure',
      'stroke',
      'heart attack',
      'severe head injury',
      'poisoning',
      'overdose',
      'suicidal',
      'cannot breathe',
      'choking',
    ];

    final symptomsLower = symptoms.map((s) => s.toLowerCase()).join(' ');
    return emergencyKeywords.any((keyword) => symptomsLower.contains(keyword));
  }

  /// Get emergency action advice
  String getEmergencyAdvice() {
    return '''
🚨 EMERGENCY DETECTED 🚨

CALL EMERGENCY SERVICES IMMEDIATELY (911 or your local emergency number)

Do not wait for an appointment or online consultation.
Seek immediate medical attention at the nearest emergency room.

While waiting for help:
- Stay calm
- Do not drive yourself if possible
- Have someone stay with you
- Follow any first aid instructions given by emergency dispatcher

$medicalDisclaimer
''';
  }
}
