import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification.dart' as app_notification;
import '../models/push_notification.dart';
import '../services/notification_service.dart';

/// Provider for managing notification state across the application
/// Handles notification counts, list updates, user interactions,
/// and push notification integration
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<app_notification.Notification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  bool _pushNotificationsInitialized = false;
  bool _pushNotificationsEnabled = false;
  StreamSubscription<PushNotification>? _pushNotificationSubscription;

  // Getters
  List<app_notification.Notification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNotifications => _notifications.isNotEmpty;
  bool get hasUnread => _unreadCount > 0;
  bool get pushNotificationsInitialized => _pushNotificationsInitialized;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  /// Initialize push notifications
  /// Should be called after user login
  Future<void> initializePushNotifications({
    Function(PushNotification)? onNotificationTap,
  }) async {
    if (_pushNotificationsInitialized) return;

    try {
      await _notificationService.initializePushNotifications(
        onNotificationTap: onNotificationTap,
      );

      // Listen to push notification stream
      _pushNotificationSubscription = _notificationService
          .fcmService
          .notificationStream
          .listen(_handlePushNotification);

      _pushNotificationsInitialized = true;
      _pushNotificationsEnabled = await _notificationService.arePushNotificationsEnabled();
      notifyListeners();

      debugPrint('Push notifications initialized in provider');
    } catch (e) {
      debugPrint('Error initializing push notifications: $e');
      _error = 'Failed to initialize push notifications';
      notifyListeners();
    }
  }

  /// Handle incoming push notification
  void _handlePushNotification(PushNotification notification) {
    debugPrint('Push notification received: ${notification.title}');
    // Refresh notifications to include the new one
    refreshNotifications();
  }

  /// Request push notification permission
  Future<bool> requestPushNotificationPermission() async {
    try {
      _pushNotificationsEnabled = await _notificationService.requestPushNotificationPermission();
      notifyListeners();
      return _pushNotificationsEnabled;
    } catch (e) {
      debugPrint('Error requesting push notification permission: $e');
      return false;
    }
  }

  /// Check if push notifications are enabled
  Future<void> checkPushNotificationStatus() async {
    _pushNotificationsEnabled = await _notificationService.arePushNotificationsEnabled();
    notifyListeners();
  }

  /// Subscribe to a notification topic
  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }

  /// Unsubscribe from a notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }

  /// Schedule a local notification (e.g., for medication reminders)
  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    PushNotificationType type = PushNotificationType.general,
  }) async {
    await _notificationService.scheduleLocalNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      type: type,
    );
  }

  /// Cancel a scheduled notification
  Future<void> cancelScheduledNotification(int id) async {
    await _notificationService.cancelScheduledNotification(id);
  }

  /// Load initial notifications
  Future<void> loadNotifications({bool onlyUnread = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getUserNotifications(
        onlyUnread: onlyUnread,
        limit: 50,
      );
      await _updateUnreadCount();
    } catch (e) {
      _error = 'Failed to load notifications: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  /// Mark a specific notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = app_notification.Notification(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          createdAt: _notifications[index].createdAt,
          data: _notifications[index].data,
        );
      }

      await _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark notification as read: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      // Update local state
      _notifications = _notifications.map((n) {
        return app_notification.Notification(
          id: n.id,
          userId: n.userId,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
          data: n.data,
        );
      }).toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark all notifications as read: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      await _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete notification: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update unread notification count
  Future<void> _updateUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
    } catch (e) {
      // Silently fail, keep previous count
      debugPrint('Failed to update unread count: $e');
    }
  }

  /// Get notifications by type
  List<app_notification.Notification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<app_notification.Notification> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Get recent notifications (last 10)
  List<app_notification.Notification> get recentNotifications {
    return _notifications.take(10).toList();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Subscribe to real-time notification updates
  void subscribeToNotifications() {
    _notificationService.getUserNotificationsStream().listen(
      (notifications) {
        _notifications = notifications;
        _updateUnreadCount();
        notifyListeners();
      },
      onError: (error) {
        _error = 'Real-time update error: ${error.toString()}';
        notifyListeners();
      },
    );
  }

  /// Subscribe to unread count updates
  void subscribeToUnreadCount() {
    _notificationService.getUnreadCountStream().listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Unread count stream error: $error');
      },
    );
  }

  /// Clear all notifications and cleanup push notifications (for logout)
  Future<void> clear() async {
    // Cleanup push notification resources
    await _notificationService.cleanupPushNotifications();
    await _notificationService.cancelAllScheduledNotifications();
    
    _pushNotificationSubscription?.cancel();
    _pushNotificationSubscription = null;
    
    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
    _error = null;
    _pushNotificationsInitialized = false;
    _pushNotificationsEnabled = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _pushNotificationSubscription?.cancel();
    super.dispose();
  }
}
