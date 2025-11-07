import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart' as app_notification;

/// Service for managing in-app notifications and push notifications
/// Handles creating, retrieving, and marking notifications as read
class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _notificationsCollection = 'notifications';

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Create a new notification for a specific user
  Future<String> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'info',
    Map<String, dynamic>? data,
  }) async {
    final notification = app_notification.Notification(
      id: '',
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
      data: data,
    );

    final docRef = await _db.collection(_notificationsCollection).add(
      notification.toMap(),
    );

    // Update with the generated ID
    await docRef.update({'id': docRef.id});

    return docRef.id;
  }

  /// Get all notifications for current user
  Future<List<app_notification.Notification>> getUserNotifications({
    int? limit,
    bool? onlyUnread,
  }) async {
    if (_currentUserId == null) return [];

    Query query = _db
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true);

    if (onlyUnread == true) {
      query = query.where('isRead', isEqualTo: false);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => app_notification.Notification.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Stream of user notifications for real-time updates
  Stream<List<app_notification.Notification>> getUserNotificationsStream({
    bool? onlyUnread,
  }) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    Query query = _db
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(50);

    if (onlyUnread == true) {
      query = query.where('isRead', isEqualTo: false);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => app_notification.Notification.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _db.collection(_notificationsCollection).doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Mark all notifications as read for current user
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    final unreadNotifications = await _db
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in unreadNotifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection(_notificationsCollection).doc(notificationId).delete();
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    if (_currentUserId == null) return 0;

    final snapshot = await _db
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  /// Stream of unread notification count
  Stream<int> getUnreadCountStream() {
    if (_currentUserId == null) {
      return Stream.value(0);
    }

    return _db
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: _currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Send notification for appointment reminder
  Future<void> sendAppointmentReminder({
    required String userId,
    required String doctorName,
    required DateTime appointmentTime,
    required String appointmentId,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Appointment Reminder',
      message: 'You have an appointment with Dr. $doctorName at ${_formatTime(appointmentTime)}',
      type: 'appointment',
      data: {
        'appointmentId': appointmentId,
        'appointmentTime': appointmentTime.toIso8601String(),
      },
    );
  }

  /// Send notification for medication reminder
  Future<void> sendMedicationReminder({
    required String userId,
    required String medicationName,
    required String dosage,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Medication Reminder',
      message: 'Time to take $medicationName - $dosage',
      type: 'medication',
      data: {
        'medication': medicationName,
        'dosage': dosage,
      },
    );
  }

  /// Send notification for appointment status change
  Future<void> sendAppointmentStatusNotification({
    required String userId,
    required String status,
    required String appointmentId,
  }) async {
    String message;
    switch (status) {
      case 'confirmed':
        message = 'Your appointment has been confirmed';
        break;
      case 'cancelled':
        message = 'Your appointment has been cancelled';
        break;
      case 'completed':
        message = 'Your appointment has been completed';
        break;
      default:
        message = 'Your appointment status has been updated to $status';
    }

    await createNotification(
      userId: userId,
      title: 'Appointment Update',
      message: message,
      type: 'appointment',
      data: {
        'appointmentId': appointmentId,
        'status': status,
      },
    );
  }

  /// Format time for display
  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour = hour - 12;
    }
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
