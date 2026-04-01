import 'package:local_auth/local_auth.dart';

class BiometricService {
  final _auth = LocalAuthentication();

  Future<bool> isAvailable() => _auth.canCheckBiometrics;

  Future<bool> authenticate(
      {String reason = 'Authenticate to access LifeEase'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // fall back to PIN
          stickyAuth: true,
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('BiometricService.authenticate error: $e');
      return false;
    }
  }
}
