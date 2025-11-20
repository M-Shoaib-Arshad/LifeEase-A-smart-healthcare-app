import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _appointmentRemindersKey = 'appointment_reminders';
  static const String _healthTipsKey = 'health_tips';
  static const String _messageNotificationsKey = 'message_notifications';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load theme mode from local storage
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }

  // Save theme mode to local storage
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  // Load language from local storage
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  // Save language to local storage
  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // Load notification settings from local storage
  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_notificationsKey) ?? true,
      'appointmentReminders': prefs.getBool(_appointmentRemindersKey) ?? true,
      'healthTips': prefs.getBool(_healthTipsKey) ?? true,
      'messageNotifications': prefs.getBool(_messageNotificationsKey) ?? true,
    };
  }

  // Save notification settings to local storage
  Future<void> setNotificationSettings(Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, settings['enabled'] ?? true);
    await prefs.setBool(_appointmentRemindersKey, settings['appointmentReminders'] ?? true);
    await prefs.setBool(_healthTipsKey, settings['healthTips'] ?? true);
    await prefs.setBool(_messageNotificationsKey, settings['messageNotifications'] ?? true);
  }

  // Sync settings to Firestore for backup and cross-device sync
  Future<void> syncSettingsToFirestore(String userId, Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('user_settings').doc(userId).set({
        'themeMode': settings['themeMode'],
        'language': settings['language'],
        'notifications': settings['notifications'],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail if Firestore sync fails - local settings still work
      print('Failed to sync settings to Firestore: $e');
    }
  }

  // Load settings from Firestore
  Future<Map<String, dynamic>?> loadSettingsFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('user_settings').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('Failed to load settings from Firestore: $e');
    }
    return null;
  }

  // Clear all settings (for logout)
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_notificationsKey);
    await prefs.remove(_appointmentRemindersKey);
    await prefs.remove(_healthTipsKey);
    await prefs.remove(_messageNotificationsKey);
  }
}
