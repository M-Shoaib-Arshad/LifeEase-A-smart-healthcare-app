import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class NotificationSettingsWidget extends StatelessWidget {
  const NotificationSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Manage your notification preferences',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),

          // Master Switch
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SwitchListTile(
              title: const Text(
                'Enable Notifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Turn all notifications on or off'),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications,
                  color: theme.colorScheme.primary,
                ),
              ),
              value: settingsProvider.notificationsEnabled,
              onChanged: (value) {
                settingsProvider.setNotificationEnabled(value);
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notification Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Appointment Reminders
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: const Text('Appointment Reminders'),
              subtitle: const Text('Get notified before appointments'),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.secondary,
                ),
              ),
              value: settingsProvider.appointmentReminders,
              onChanged: settingsProvider.notificationsEnabled
                  ? (value) {
                      settingsProvider.setAppointmentReminders(value);
                    }
                  : null,
            ),
          ),

          // Message Notifications
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: const Text('Message Notifications'),
              subtitle: const Text('Alerts for new messages from doctors'),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.message,
                  color: theme.colorScheme.secondary,
                ),
              ),
              value: settingsProvider.messageNotifications,
              onChanged: settingsProvider.notificationsEnabled
                  ? (value) {
                      settingsProvider.setMessageNotifications(value);
                    }
                  : null,
            ),
          ),

          // Health Tips
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: const Text('Health Tips'),
              subtitle: const Text('Weekly health and wellness tips'),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: theme.colorScheme.secondary,
                ),
              ),
              value: settingsProvider.healthTips,
              onChanged: settingsProvider.notificationsEnabled
                  ? (value) {
                      settingsProvider.setHealthTips(value);
                    }
                  : null,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
