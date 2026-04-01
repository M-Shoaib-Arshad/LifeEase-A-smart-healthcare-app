import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user.dart' as model;
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/cache_service.dart';
import 'settings_provider.dart';
import 'theme_provider.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();
  final CacheService _cache = CacheService();

  fb.User? _firebaseUser;
  model.User? _profile;
  bool _loading = true;

  SettingsProvider? _settingsProvider;
  ThemeProvider? _themeProvider;

  UserProvider() {
    // Listen to auth state
    _auth.authStateChanges.listen((fb.User? user) async {
      _firebaseUser = user;
      if (user != null) {
        try {
          _profile = await _userService.getUserProfile(user.uid);
          // Cache the profile for offline access
          if (_profile != null) {
            await _cache.cacheUserProfile(_profile!.toMap());
          }
        } catch (e) {
          debugPrint('UserProvider: offline fallback for profile – $e');
          // Fall back to cached profile when offline
          final cached = _cache.getCachedUserProfile();
          if (cached != null) {
            _profile = model.User.fromMap(cached);
          }
        }
        // Capture provider references before async gap to avoid race condition
        final settingsProvider = _settingsProvider;
        final themeProvider = _themeProvider;
        // Sync settings to Firestore on login
        if (settingsProvider != null) {
          try {
            await settingsProvider.syncSettings(
              user.uid,
              themeMode: themeProvider?.themeModeString ?? 'system',
            );
          } catch (e) {
            debugPrint('Failed to sync settings after login: $e');
          }
        }
      } else {
        _profile = null;
      }
      _loading = false;
      notifyListeners();
    });
  }

  /// Called by [ChangeNotifierProxyProvider2] whenever upstream providers update.
  void updateProviders(SettingsProvider settingsProvider, ThemeProvider themeProvider) {
    _settingsProvider = settingsProvider;
    _themeProvider = themeProvider;
  }

  bool get isLoading => _loading;
  bool get isAuthenticated => _firebaseUser != null;
  String? get uid => _firebaseUser?.uid;
  String? get role => _profile?.role;
  model.User? get profile => _profile;

  Future<void> refreshProfile() async {
    if (_firebaseUser == null) return;
    try {
      _profile = await _userService.getUserProfile(_firebaseUser!.uid);
      if (_profile != null) {
        await _cache.cacheUserProfile(_profile!.toMap());
      }
    } catch (e) {
      debugPrint('UserProvider.refreshProfile: offline fallback – $e');
      final cached = _cache.getCachedUserProfile();
      if (cached != null) {
        _profile = model.User.fromMap(cached);
      }
    }
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    String? address,
  }) async {
    if (_firebaseUser == null) {
      throw Exception('No user is currently signed in');
    }

    await _userService.updateUserProfile(
      uid: _firebaseUser!.uid,
      name: name,
      phone: phone,
      dateOfBirth: dateOfBirth,
      address: address,
    );

    // Refresh profile to get updated data
    await refreshProfile();
  }

  Future<void> logout() async {
    await _auth.signOut();
    // Clear all cached data so stale data is not shown on next login
    await _cache.clearAll();
    _firebaseUser = null;
    _profile = null;
    notifyListeners();
  }
}