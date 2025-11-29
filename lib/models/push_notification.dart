/// Model class representing a push notification
/// Used for handling FCM notifications in the app
class PushNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final DateTime receivedAt;
  final PushNotificationType type;

  PushNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    required this.receivedAt,
    required this.type,
  });

  /// Create a PushNotification from FCM RemoteMessage data
  factory PushNotification.fromRemoteMessage(Map<String, dynamic> message) {
    final notification = message['notification'] as Map<String, dynamic>?;
    final data = message['data'] as Map<String, dynamic>?;

    return PushNotification(
      id: message['messageId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification?['title'] ?? data?['title'] ?? 'Notification',
      body: notification?['body'] ?? data?['body'] ?? '',
      imageUrl: notification?['image'] ?? data?['image'],
      data: data,
      receivedAt: DateTime.now(),
      type: _parseNotificationType(data?['type']),
    );
  }

  /// Create a PushNotification from a Map (e.g., from storage)
  factory PushNotification.fromMap(Map<String, dynamic> map) {
    return PushNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      imageUrl: map['imageUrl'],
      data: map['data'] as Map<String, dynamic>?,
      receivedAt: map['receivedAt'] != null
          ? DateTime.parse(map['receivedAt'])
          : DateTime.now(),
      type: _parseNotificationType(map['type']),
    );
  }

  /// Convert to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'receivedAt': receivedAt.toIso8601String(),
      'type': type.name,
    };
  }

  /// Parse notification type from string
  static PushNotificationType _parseNotificationType(String? typeString) {
    if (typeString == null) return PushNotificationType.general;

    switch (typeString.toLowerCase()) {
      case 'appointment_reminder':
        return PushNotificationType.appointmentReminder;
      case 'appointment_confirmation':
        return PushNotificationType.appointmentConfirmation;
      case 'appointment_cancellation':
        return PushNotificationType.appointmentCancellation;
      case 'new_message':
        return PushNotificationType.newMessage;
      case 'prescription_ready':
        return PushNotificationType.prescriptionReady;
      case 'health_tip':
        return PushNotificationType.healthTip;
      case 'medication_reminder':
        return PushNotificationType.medicationReminder;
      default:
        return PushNotificationType.general;
    }
  }

  /// Get the route path for navigation based on notification type
  String? getNavigationRoute() {
    switch (type) {
      case PushNotificationType.appointmentReminder:
      case PushNotificationType.appointmentConfirmation:
      case PushNotificationType.appointmentCancellation:
        return '/patient/appointment-history';
      case PushNotificationType.newMessage:
        // Could be expanded to include conversation ID in future
        return '/support';
      case PushNotificationType.prescriptionReady:
        return '/patient/medical-records';
      case PushNotificationType.healthTip:
        return '/patient/health-tracker-dashboard';
      case PushNotificationType.medicationReminder:
        return '/patient/medication-reminder-setup';
      case PushNotificationType.general:
        return null;
    }
  }

  @override
  String toString() {
    return 'PushNotification(id: $id, title: $title, body: $body, type: $type)';
  }
}

/// Types of push notifications supported by the app
enum PushNotificationType {
  /// Appointment reminder (1 hour before, 1 day before)
  appointmentReminder,

  /// Appointment confirmation
  appointmentConfirmation,

  /// Appointment cancellation
  appointmentCancellation,

  /// New message from doctor
  newMessage,

  /// Prescription ready
  prescriptionReady,

  /// Weekly health tips
  healthTip,

  /// Medication reminder
  medicationReminder,

  /// General notification
  general,
}
