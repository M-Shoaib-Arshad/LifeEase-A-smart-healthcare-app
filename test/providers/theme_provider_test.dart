import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LifeEase/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with system theme mode', () async {
      final provider = ThemeProvider();
      
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.themeModeString, 'system');
      expect(provider.isLoading, false);
    });

    test('should set theme mode to light', () async {
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setThemeMode(ThemeMode.light);
      
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.themeModeString, 'light');
      expect(provider.isDarkMode, false);
    });

    test('should set theme mode to dark', () async {
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setThemeMode(ThemeMode.dark);
      
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.themeModeString, 'dark');
      expect(provider.isDarkMode, true);
    });

    test('should toggle theme from light to dark', () async {
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, ThemeMode.light);
      
      await provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('should toggle theme from dark to light', () async {
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
      
      await provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
    });

    test('should toggle theme from system to dark', () async {
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider.themeMode, ThemeMode.system);
      
      await provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('should persist theme mode', () async {
      final provider1 = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider1.setThemeMode(ThemeMode.dark);
      
      // Create new instance to test persistence
      final provider2 = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(provider2.themeMode, ThemeMode.dark);
    });

    test('should not change theme mode if already set', () async {
      final provider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await provider.setThemeMode(ThemeMode.dark);
      final firstCallTime = DateTime.now();
      
      await provider.setThemeMode(ThemeMode.dark);
      final secondCallTime = DateTime.now();
      
      // Should return immediately without changing
      expect(secondCallTime.difference(firstCallTime).inMilliseconds < 50, true);
      expect(provider.themeMode, ThemeMode.dark);
    });
  });
}
