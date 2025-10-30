import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user.dart' as model;
import '../services/auth_service.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final UserService _userService = UserService();

  fb.User? _firebaseUser;
  model.User? _profile;
  bool _loading = true;

  UserProvider() {
    // Listen to auth state
    _auth.authStateChanges.listen((fb.User? user) async {
      _firebaseUser = user;
      if (user != null) {
        _profile = await _userService.getUserProfile(user.uid);
      } else {
        _profile = null;
      }
      _loading = false;
      notifyListeners();
    });
  }

  bool get isLoading => _loading;
  bool get isAuthenticated => _firebaseUser != null;
  String? get uid => _firebaseUser?.uid;
  String? get role => _profile?.role;
  model.User? get profile => _profile;

  Future<void> refreshProfile() async {
    if (_firebaseUser == null) return;
    _profile = await _userService.getUserProfile(_firebaseUser!.uid);
    notifyListeners();
  }
}