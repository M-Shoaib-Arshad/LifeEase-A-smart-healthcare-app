import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/fcm_service.dart';

/// Dialog widget for requesting notification permissions from the user
/// Shows a user-friendly explanation of why notifications are needed
/// and provides options to enable or skip notifications
class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const NotificationPermissionDialog({
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  /// Show the notification permission dialog
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onPermissionGranted,
    VoidCallback? onPermissionDenied,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NotificationPermissionDialog(
        onPermissionGranted: onPermissionGranted,
        onPermissionDenied: onPermissionDenied,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bell icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Stay Updated',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'Enable notifications to receive important updates about your appointments, medication reminders, and messages from your healthcare providers.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Notification types list
          _buildNotificationTypesList(theme),
        ],
      ),
      actions: [
        // Skip button
        TextButton(
          onPressed: () {
            onPermissionDenied?.call();
            Navigator.of(context).pop(false);
          },
          child: Text(
            'Maybe Later',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),

        // Enable button
        ElevatedButton(
          onPressed: () async {
            final fcmService = FCMService();
            final settings = await fcmService.requestPermission();

            if (context.mounted) {
              if (settings.authorizationStatus ==
                  AuthorizationStatus.authorized) {
                onPermissionGranted?.call();
                Navigator.of(context).pop(true);
              } else {
                onPermissionDenied?.call();
                Navigator.of(context).pop(false);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Enable Notifications'),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }

  Widget _buildNotificationTypesList(ThemeData theme) {
    final notificationTypes = [
      {
        'icon': Icons.calendar_today,
        'text': 'Appointment reminders',
      },
      {
        'icon': Icons.medication,
        'text': 'Medication reminders',
      },
      {
        'icon': Icons.message,
        'text': 'Messages from doctors',
      },
      {
        'icon': Icons.favorite,
        'text': 'Health tips',
      },
    ];

    return Column(
      children: notificationTypes.map((type) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                type['icon'] as IconData,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                type['text'] as String,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
