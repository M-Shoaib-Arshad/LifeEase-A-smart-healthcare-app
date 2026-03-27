import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../routes/app_routes.dart';

/// Service for displaying local notifications from FCM RemoteMessages.
/// Handles foreground notifications and notification tap navigation.
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'lifeease_default_channel',
    'LifeEase Notifications',
    description: 'This channel is used for LifeEase appointment and medication reminders.',
    importance: Importance.high,
  );

  /// Initialize the local notification plugin and create the Android channel.
  static Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create high-importance channel for Android 8+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// Display a local notification from an FCM [message].
  /// Call this from the foreground listener and the background handler.
  static Future<void> showFromRemote(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@drawable/ic_notification',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  // Called when the user taps a local notification.
  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      navigateFromNotificationData(data);
    } catch (e) {
      debugPrint('LocalNotificationService: failed to parse notification payload: $e');
    }
  }

  /// Navigate to the relevant screen based on notification [data].
  /// Shared by both local notification taps and FCM message-open events.
  static void navigateFromNotificationData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    switch (type) {
      case 'appointment':
        router.go('/patient/appointment-history');
        break;
      case 'medication':
        router.go('/patient/medication-reminder-setup');
        break;
      default:
        break;
    }
  }
}
