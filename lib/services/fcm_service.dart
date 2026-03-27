import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'local_notification_service.dart';

/// Top-level background message handler.
/// Must be a top-level function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await LocalNotificationService.init();
  await LocalNotificationService.showFromRemote(message);
}

/// Service for Firebase Cloud Messaging (FCM).
/// Registers the background handler, requests permissions, manages the FCM
/// token in Firestore, and handles notification-tap navigation.
class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init() async {
    // Register background handler FIRST
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS + Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Display notification when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotificationService.showFromRemote(message);
    });

    // Navigate when notification is tapped while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

    // Navigate when notification is tapped while app is terminated
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpen(initialMessage);
    }

    // Save token to Firestore
    final token = await _fcm.getToken();
    if (token != null) await _saveToken(token);

    // Refresh token whenever FCM rotates it
    _fcm.onTokenRefresh.listen(_saveToken);
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }

  void _handleMessageOpen(RemoteMessage message) {
    LocalNotificationService.navigateFromNotificationData(message.data);
  }

  /// Subscribe to an FCM topic (e.g. for broadcast appointment reminders).
  Future<void> subscribeToTopic(String topic) =>
      _fcm.subscribeToTopic(topic);
}
