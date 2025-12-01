import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  fb.User? get currentUser => _auth.currentUser;
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  Future<fb.UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred;
  }

  Future<fb.UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user is currently signed in');
    }

    // Re-authenticate user before changing password
    final credential = fb.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Signs in with Google and returns the UserCredential.
  /// Returns null if the user cancels the sign-in flow.
  Future<fb.UserCredential?> signInWithGoogle() async {
    // Trigger the Google authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // User cancelled the sign-in flow
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    return await _auth.signInWithCredential(credential);
  }

  /// Links Google account to the current user.
  /// Throws an exception if no user is signed in.
  Future<fb.UserCredential> linkGoogleAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    // Trigger the Google authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Link the credential to the current user
    return await user.linkWithCredential(credential);
  }

  /// Checks if the current user is signed in with Google.
  bool isSignedInWithGoogle() {
    final user = _auth.currentUser;
    if (user == null) return false;

    for (final provider in user.providerData) {
      if (provider.providerId == 'google.com') {
        return true;
      }
    }
    return false;
  }
}
