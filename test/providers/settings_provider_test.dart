import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LifeEase/providers/settings_provider.dart';

void main() {
  group('SettingsProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with default settings', () async {
      final provider = SettingsProvider();
      
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider.language, 'en');
      expect(provider.notificationsEnabled, true);
      expect(provider.appointmentReminders, true);
      expect(provider.healthTips, true);
      expect(provider.messageNotifications, true);
      expect(provider.isLoading, false);
    });

    test('should set language', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setLanguage('es');
      
      expect(provider.language, 'es');
    });

    test('should not change language if already set', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setLanguage('es');
      final firstCallTime = DateTime.now();
      
      await provider.setLanguage('es');
      final secondCallTime = DateTime.now();
      
      // Should return immediately without changing
      expect(secondCallTime.difference(firstCallTime).inMilliseconds < 50, true);
      expect(provider.language, 'es');
    });

    test('should disable notifications', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setNotificationEnabled(false);
      
      expect(provider.notificationsEnabled, false);
    });

    test('should enable notifications', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setNotificationEnabled(false);
      expect(provider.notificationsEnabled, false);
      
      await provider.setNotificationEnabled(true);
      expect(provider.notificationsEnabled, true);
    });

    test('should disable appointment reminders', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setAppointmentReminders(false);
      
      expect(provider.appointmentReminders, false);
    });

    test('should disable health tips', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setHealthTips(false);
      
      expect(provider.healthTips, false);
    });

    test('should disable message notifications', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setMessageNotifications(false);
      
      expect(provider.messageNotifications, false);
    });

    test('should persist settings', () async {
      final provider1 = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider1.setLanguage('ar');
      await provider1.setNotificationEnabled(false);
      await provider1.setAppointmentReminders(false);
      
      // Create new instance to test persistence
      final provider2 = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider2.language, 'ar');
      expect(provider2.notificationsEnabled, false);
      expect(provider2.appointmentReminders, false);
    });

    test('should clear settings to defaults', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Set some custom settings
      await provider.setLanguage('ur');
      await provider.setNotificationEnabled(false);
      await provider.setAppointmentReminders(false);
      await provider.setHealthTips(false);
      
      // Clear settings
      await provider.clearSettings();
      
      // Verify settings are back to defaults
      expect(provider.language, 'en');
      expect(provider.notificationsEnabled, true);
      expect(provider.appointmentReminders, true);
      expect(provider.healthTips, true);
      expect(provider.messageNotifications, true);
    });

    test('should return notification settings map', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setNotificationEnabled(false);
      await provider.setAppointmentReminders(true);
      await provider.setHealthTips(false);
      await provider.setMessageNotifications(true);
      
      final settings = provider.notificationSettings;
      
      expect(settings['enabled'], false);
      expect(settings['appointmentReminders'], true);
      expect(settings['healthTips'], false);
      expect(settings['messageNotifications'], true);
    });
  });
}
