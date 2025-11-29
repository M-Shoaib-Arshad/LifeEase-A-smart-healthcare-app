import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/push_notification.dart';
import 'local_notification_service.dart';

/// Service for handling Firebase Cloud Messaging (FCM)
/// Manages device token registration, background/foreground notification handling
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalNotificationService _localNotifications = LocalNotificationService();

  String? _fcmToken;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Callback for handling notification tap
  Function(PushNotification)? onNotificationTap;

  /// Stream controller for notification events
  final StreamController<PushNotification> _notificationController =
      StreamController<PushNotification>.broadcast();

  /// Stream of received notifications
  Stream<PushNotification> get notificationStream => _notificationController.stream;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize FCM service
  /// Should be called during app initialization after Firebase.initializeApp()
  Future<void> initialize() async {
    try {
      // Initialize local notifications first
      await _localNotifications.initialize(
        onNotificationTap: _handleNotificationTap,
      );

      // Request permission for notifications
      await requestPermission();

      // Get and store FCM token
      await _getAndStoreToken();

      // Listen for token refresh
      _listenForTokenRefresh();

      // Handle foreground notifications
      _handleForegroundNotifications();

      // Handle notification taps when app was terminated
      await _handleTerminatedNotification();

      // Handle notification taps when app was in background
      _handleBackgroundNotificationTap();

      debugPrint('FCM Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FCM Service: $e');
    }
  }

  /// Request notification permission from the user
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Notification permission status: ${settings.authorizationStatus}');

    return settings;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Get the FCM token and store it in Firestore
  Future<void> _getAndStoreToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        debugPrint('FCM Token: $_fcmToken');
        await _saveTokenToFirestore(_fcmToken!);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Listen for token refresh events
  void _listenForTokenRefresh() {
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refreshed: $newToken');
      _fcmToken = newToken;
      await _saveTokenToFirestore(newToken);
    });
  }

  /// Save FCM token to Firestore for the current user
  Future<void> _saveTokenToFirestore(String token) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('Cannot save FCM token: No user logged in');
      return;
    }

    try {
      await _db.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastFcmTokenUpdate': FieldValue.serverTimestamp(),
      });
      debugPrint('FCM token saved to Firestore');
    } catch (e) {
      // If document doesn't exist or field update fails, try setting it
      try {
        await _db.collection('users').doc(userId).set({
          'fcmTokens': [token],
          'lastFcmTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('FCM token set in Firestore');
      } catch (setError) {
        debugPrint('Error saving FCM token: $setError');
      }
    }
  }

  /// Remove FCM token from Firestore (call on logout)
  Future<void> removeTokenFromFirestore() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || _fcmToken == null) return;

    try {
      await _db.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([_fcmToken]),
      });
      debugPrint('FCM token removed from Firestore');
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  /// Handle foreground notifications
  void _handleForegroundNotifications() {
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground notification: ${message.notification?.title}');

      final pushNotification = _createPushNotification(message);
      _notificationController.add(pushNotification);

      // Show local notification when app is in foreground
      _localNotifications.showNotification(
        id: pushNotification.id.hashCode,
        title: pushNotification.title,
        body: pushNotification.body,
        payload: pushNotification.toMap().toString(),
        type: pushNotification.type,
      );
    });
  }

  /// Handle notification tap when app was terminated
  Future<void> _handleTerminatedNotification() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      final pushNotification = _createPushNotification(initialMessage);
      // Delay to ensure app is fully initialized
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationTap(pushNotification);
      });
    }
  }

  /// Handle notification tap when app was in background
  void _handleBackgroundNotificationTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from background via notification');
      final pushNotification = _createPushNotification(message);
      _handleNotificationTap(pushNotification);
    });
  }

  /// Handle notification tap navigation
  void _handleNotificationTap(PushNotification notification) {
    debugPrint('Notification tapped: ${notification.title}');
    onNotificationTap?.call(notification);
  }

  /// Create PushNotification from RemoteMessage
  PushNotification _createPushNotification(RemoteMessage message) {
    return PushNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? message.data['title'] ?? 'Notification',
      body: message.notification?.body ?? message.data['body'] ?? '',
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl ??
          message.data['image'],
      data: message.data,
      receivedAt: DateTime.now(),
      type: _parseNotificationType(message.data['type']),
    );
  }

  /// Parse notification type from string
  PushNotificationType _parseNotificationType(String? typeString) {
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

  /// Subscribe to a topic for receiving notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _foregroundSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    _notificationController.close();
  }
}

/// Background message handler - must be a top-level function
/// This function is called when the app is in the background or terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: Firebase.initializeApp() should already be called in main.dart
  // before this handler is set up
  debugPrint('Handling background message: ${message.messageId}');

  // Background messages are automatically displayed by FCM on Android
  // For iOS, the notification will be shown by the system

  // If you need to perform additional background processing:
  // - Save notification to local storage
  // - Update app badge count
  // - etc.
}
