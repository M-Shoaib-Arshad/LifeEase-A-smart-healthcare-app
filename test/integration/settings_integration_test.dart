import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LifeEase/providers/settings_provider.dart';
import 'package:LifeEase/providers/theme_provider.dart';

/// Integration test for settings flow
/// Tests the complete flow of changing settings and verifying persistence
void main() {
  group('Settings Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should persist theme changes across provider instances', (WidgetTester tester) async {
      // Create initial provider and set theme
      final provider1 = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider1.setThemeMode(ThemeMode.dark);
      expect(provider1.themeMode, ThemeMode.dark);

      // Create new provider instance and verify persistence
      final provider2 = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider2.themeMode, ThemeMode.dark);
    });

    testWidgets('should persist language changes across provider instances', (WidgetTester tester) async {
      // Create initial provider and set language
      final provider1 = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider1.setLanguage('es');
      expect(provider1.language, 'es');

      // Create new provider instance and verify persistence
      final provider2 = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider2.language, 'es');
    });

    testWidgets('should persist notification settings across provider instances', (WidgetTester tester) async {
      // Create initial provider and set notifications
      final provider1 = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider1.setNotificationEnabled(false);
      await provider1.setAppointmentReminders(true);
      await provider1.setHealthTips(false);
      
      expect(provider1.notificationsEnabled, false);
      expect(provider1.appointmentReminders, true);
      expect(provider1.healthTips, false);

      // Create new provider instance and verify persistence
      final provider2 = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider2.notificationsEnabled, false);
      expect(provider2.appointmentReminders, true);
      expect(provider2.healthTips, false);
    });

    testWidgets('should clear all settings on logout', (WidgetTester tester) async {
      // Set up custom settings
      final themeProvider = ThemeProvider();
      final settingsProvider = SettingsProvider();
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      await themeProvider.setThemeMode(ThemeMode.dark);
      await settingsProvider.setLanguage('ar');
      await settingsProvider.setNotificationEnabled(false);
      
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(settingsProvider.language, 'ar');
      expect(settingsProvider.notificationsEnabled, false);

      // Clear settings (simulating logout)
      await settingsProvider.clearSettings();

      // Verify settings are cleared
      expect(settingsProvider.language, 'en');
      expect(settingsProvider.notificationsEnabled, true);
    });

    testWidgets('should handle multiple rapid setting changes', (WidgetTester tester) async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Rapidly change settings
      await provider.setLanguage('es');
      await provider.setLanguage('ar');
      await provider.setLanguage('ur');
      await provider.setLanguage('en');
      
      expect(provider.language, 'en');

      // Verify final state persists
      final newProvider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(newProvider.language, 'en');
    });

    testWidgets('should handle theme toggle multiple times', (WidgetTester tester) async {
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Start with system
      expect(provider.themeMode, ThemeMode.system);
      
      // Toggle to dark
      await provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
      
      // Toggle to light
      await provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
      
      // Toggle to dark again
      await provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
    });

    testWidgets('should maintain independent notification settings', (WidgetTester tester) async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Disable master switch but keep individual settings enabled
      await provider.setNotificationEnabled(false);
      await provider.setAppointmentReminders(true);
      await provider.setHealthTips(true);
      await provider.setMessageNotifications(true);
      
      expect(provider.notificationsEnabled, false);
      expect(provider.appointmentReminders, true);
      expect(provider.healthTips, true);
      expect(provider.messageNotifications, true);

      // Verify persistence
      final newProvider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(newProvider.notificationsEnabled, false);
      expect(newProvider.appointmentReminders, true);
      expect(newProvider.healthTips, true);
      expect(newProvider.messageNotifications, true);
    });

    testWidgets('should handle all supported languages', (WidgetTester tester) async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      final supportedLanguages = ['en', 'es', 'ar', 'ur', 'hi'];
      
      for (final lang in supportedLanguages) {
        await provider.setLanguage(lang);
        expect(provider.language, lang);
        
        // Verify persistence for each language
        final testProvider = SettingsProvider();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(testProvider.language, lang);
      }
    });

    testWidgets('should handle all theme modes', (WidgetTester tester) async {
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      final themeModes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
      
      for (final mode in themeModes) {
        await provider.setThemeMode(mode);
        expect(provider.themeMode, mode);
        
        // Verify persistence for each mode
        final testProvider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(testProvider.themeMode, mode);
      }
    });

    testWidgets('should correctly report theme mode string', (WidgetTester tester) async {
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeModeString, 'light');
      expect(provider.isDarkMode, false);
      
      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeModeString, 'dark');
      expect(provider.isDarkMode, true);
      
      await provider.setThemeMode(ThemeMode.system);
      expect(provider.themeModeString, 'system');
      expect(provider.isDarkMode, false);
    });
  });
}
