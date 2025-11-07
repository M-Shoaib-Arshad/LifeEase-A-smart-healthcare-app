import 'package:flutter/foundation.dart';
import '../models/notification.dart' as app_notification;
import '../services/notification_service.dart';

/// Provider for managing notification state across the application
/// Handles notification counts, list updates, and user interactions
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<app_notification.Notification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<app_notification.Notification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNotifications => _notifications.isNotEmpty;
  bool get hasUnread => _unreadCount > 0;

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
        _notifications[index] = _notifications[index].copyWith(isRead: true);
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
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();

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

  /// Clear all notifications (for logout)
  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
