import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/push_notification.dart';

/// Service for handling local notifications
/// Used to display notifications when the app is in the foreground
/// and for scheduling local notifications (e.g., medication reminders)
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Function(PushNotification)? _onNotificationTap;

  // Android notification channel IDs
  static const String _defaultChannelId = 'lifeease_default';
  static const String _appointmentChannelId = 'lifeease_appointments';
  static const String _medicationChannelId = 'lifeease_medications';
  static const String _messageChannelId = 'lifeease_messages';

  /// Initialize the local notification service
  Future<void> initialize({
    Function(PushNotification)? onNotificationTap,
  }) async {
    _onNotificationTap = onNotificationTap;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request separately
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
    );

    // Create Android notification channels
    await _createNotificationChannels();

    debugPrint('Local notification service initialized');
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Default channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _defaultChannelId,
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ),
    );

    // Appointments channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _appointmentChannelId,
        'Appointment Reminders',
        description: 'Notifications for appointment reminders and updates',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        enableVibration: true,
      ),
    );

    // Medications channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _medicationChannelId,
        'Medication Reminders',
        description: 'Notifications for medication reminders',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        enableVibration: true,
      ),
    );

    // Messages channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _messageChannelId,
        'Messages',
        description: 'Notifications for new messages from doctors',
        importance: Importance.high,
      ),
    );

    debugPrint('Android notification channels created');
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  /// Show a notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    PushNotificationType type = PushNotificationType.general,
  }) async {
    final channelId = _getChannelIdForType(type);
    
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelNameForType(type),
      channelDescription: 'LifeEase notification',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );

    debugPrint('Showed local notification: $title');
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    PushNotificationType type = PushNotificationType.general,
  }) async {
    final channelId = _getChannelIdForType(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelNameForType(type),
      channelDescription: 'LifeEase scheduled notification',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint('Scheduled notification for $scheduledTime: $title');
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('Cancelled notification: $id');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Get channel ID based on notification type
  String _getChannelIdForType(PushNotificationType type) {
    switch (type) {
      case PushNotificationType.appointmentReminder:
      case PushNotificationType.appointmentConfirmation:
      case PushNotificationType.appointmentCancellation:
        return _appointmentChannelId;
      case PushNotificationType.medicationReminder:
        return _medicationChannelId;
      case PushNotificationType.newMessage:
        return _messageChannelId;
      default:
        return _defaultChannelId;
    }
  }

  /// Get channel name based on notification type
  String _getChannelNameForType(PushNotificationType type) {
    switch (type) {
      case PushNotificationType.appointmentReminder:
      case PushNotificationType.appointmentConfirmation:
      case PushNotificationType.appointmentCancellation:
        return 'Appointment Reminders';
      case PushNotificationType.medicationReminder:
        return 'Medication Reminders';
      case PushNotificationType.newMessage:
        return 'Messages';
      default:
        return 'General Notifications';
    }
  }

  /// Convert DateTime to TZDateTime for scheduling
  /// Note: In a production app, you should use the timezone package
  /// For simplicity, we're using the local timezone
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // Using the local timezone
    // In production, consider using the timezone package for accurate scheduling
    return dateTime;
  }

  /// Handle iOS foreground notification (legacy callback)
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    debugPrint('iOS foreground notification received: $title');
    // This is called on older iOS versions when app is in foreground
    // Modern iOS versions use the onDidReceiveNotificationResponse callback
  }

  /// Handle notification tap
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    _handleNotificationPayload(response.payload);
  }

  /// Handle notification payload
  void _handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      // Parse the payload from JSON
      final Map<String, dynamic> data = jsonDecode(payload);
      final notification = PushNotification.fromMap(data);
      _onNotificationTap?.call(notification);
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
      // If JSON parsing fails, create a basic notification
      // This handles legacy or malformed payloads gracefully
      _onNotificationTap?.call(PushNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Notification',
        body: payload,
        receivedAt: DateTime.now(),
        type: PushNotificationType.general,
      ));
    }
  }
}

/// Background notification response handler - must be a top-level function
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  debugPrint('Background notification tapped: ${response.payload}');
  // Background handling - limited actions available
  // The app will be launched and the main notification tap handler will be called
}
