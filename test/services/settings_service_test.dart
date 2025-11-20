import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LifeEase/services/settings_service.dart';

void main() {
  group('SettingsService', () {
    late SettingsService settingsService;

    setUp(() {
      settingsService = SettingsService();
      // Initialize shared preferences with mock values
      SharedPreferences.setMockInitialValues({});
    });

    group('Theme Settings', () {
      test('should return default theme mode as system', () async {
        final themeMode = await settingsService.getThemeMode();
        expect(themeMode, 'system');
      });

      test('should save and retrieve theme mode', () async {
        await settingsService.setThemeMode('dark');
        final themeMode = await settingsService.getThemeMode();
        expect(themeMode, 'dark');
      });

      test('should save and retrieve light theme mode', () async {
        await settingsService.setThemeMode('light');
        final themeMode = await settingsService.getThemeMode();
        expect(themeMode, 'light');
      });
    });

    group('Language Settings', () {
      test('should return default language as English', () async {
        final language = await settingsService.getLanguage();
        expect(language, 'en');
      });

      test('should save and retrieve language', () async {
        await settingsService.setLanguage('es');
        final language = await settingsService.getLanguage();
        expect(language, 'es');
      });

      test('should save and retrieve Arabic language', () async {
        await settingsService.setLanguage('ar');
        final language = await settingsService.getLanguage();
        expect(language, 'ar');
      });
    });

    group('Notification Settings', () {
      test('should return default notification settings', () async {
        final settings = await settingsService.getNotificationSettings();
        expect(settings['enabled'], true);
        expect(settings['appointmentReminders'], true);
        expect(settings['healthTips'], true);
        expect(settings['messageNotifications'], true);
      });

      test('should save and retrieve notification settings', () async {
        final testSettings = {
          'enabled': false,
          'appointmentReminders': true,
          'healthTips': false,
          'messageNotifications': true,
        };
        
        await settingsService.setNotificationSettings(testSettings);
        final settings = await settingsService.getNotificationSettings();
        
        expect(settings['enabled'], false);
        expect(settings['appointmentReminders'], true);
        expect(settings['healthTips'], false);
        expect(settings['messageNotifications'], true);
      });

      test('should handle partial notification settings', () async {
        final testSettings = {
          'enabled': false,
        };
        
        await settingsService.setNotificationSettings(testSettings);
        final settings = await settingsService.getNotificationSettings();
        
        expect(settings['enabled'], false);
        // Other settings should default to true
        expect(settings['appointmentReminders'], true);
        expect(settings['healthTips'], true);
        expect(settings['messageNotifications'], true);
      });
    });

    group('Clear Settings', () {
      test('should clear all settings', () async {
        // Set some settings
        await settingsService.setThemeMode('dark');
        await settingsService.setLanguage('es');
        await settingsService.setNotificationSettings({
          'enabled': false,
          'appointmentReminders': false,
          'healthTips': false,
          'messageNotifications': false,
        });

        // Clear settings
        await settingsService.clearSettings();

        // Verify settings are back to defaults
        final themeMode = await settingsService.getThemeMode();
        final language = await settingsService.getLanguage();
        final notificationSettings = await settingsService.getNotificationSettings();

        expect(themeMode, 'system');
        expect(language, 'en');
        expect(notificationSettings['enabled'], true);
        expect(notificationSettings['appointmentReminders'], true);
        expect(notificationSettings['healthTips'], true);
        expect(notificationSettings['messageNotifications'], true);
      });
    });
  });
}
