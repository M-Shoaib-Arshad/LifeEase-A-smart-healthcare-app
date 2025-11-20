import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  String _language = 'en';
  Map<String, bool> _notificationSettings = {
    'enabled': true,
    'appointmentReminders': true,
    'healthTips': true,
    'messageNotifications': true,
  };
  bool _isLoading = true;

  SettingsProvider() {
    _loadSettings();
  }

  String get language => _language;
  Map<String, bool> get notificationSettings => _notificationSettings;
  bool get isLoading => _isLoading;
  bool get notificationsEnabled => _notificationSettings['enabled'] ?? true;
  bool get appointmentReminders => _notificationSettings['appointmentReminders'] ?? true;
  bool get healthTips => _notificationSettings['healthTips'] ?? true;
  bool get messageNotifications => _notificationSettings['messageNotifications'] ?? true;

  Future<void> _loadSettings() async {
    _language = await _settingsService.getLanguage();
    _notificationSettings = await _settingsService.getNotificationSettings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_language == language) return;
    
    _language = language;
    notifyListeners();
    
    await _settingsService.setLanguage(language);
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    _notificationSettings['enabled'] = enabled;
    notifyListeners();
    
    await _settingsService.setNotificationSettings(_notificationSettings);
  }

  Future<void> setAppointmentReminders(bool enabled) async {
    _notificationSettings['appointmentReminders'] = enabled;
    notifyListeners();
    
    await _settingsService.setNotificationSettings(_notificationSettings);
  }

  Future<void> setHealthTips(bool enabled) async {
    _notificationSettings['healthTips'] = enabled;
    notifyListeners();
    
    await _settingsService.setNotificationSettings(_notificationSettings);
  }

  Future<void> setMessageNotifications(bool enabled) async {
    _notificationSettings['messageNotifications'] = enabled;
    notifyListeners();
    
    await _settingsService.setNotificationSettings(_notificationSettings);
  }

  Future<void> syncSettings(String userId) async {
    await _settingsService.syncSettingsToFirestore(userId, {
      'themeMode': '', // This will be handled by ThemeProvider
      'language': _language,
      'notifications': _notificationSettings,
    });
  }

  Future<void> clearSettings() async {
    _language = 'en';
    _notificationSettings = {
      'enabled': true,
      'appointmentReminders': true,
      'healthTips': true,
      'messageNotifications': true,
    };
    notifyListeners();
    
    await _settingsService.clearSettings();
  }
}
