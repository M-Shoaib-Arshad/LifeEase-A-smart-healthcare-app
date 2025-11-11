import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Role-based access control levels
/// (Moved out of class to comply with Dart: enums must be top-level)
enum UserRole {
  patient,
  doctor,
  admin,
  guest,
}

/// Permission types (top-level enum for same reason)
enum Permission {
  viewPatientRecords,
  editPatientRecords,
  createAppointments,
  cancelAppointments,
  viewDoctorSchedule,
  manageDoctors,
  managePatients,
  viewAnalytics,
  manageContent,
  sendNotifications,
  accessTelemedicine,
}

/// Service for managing security, encryption, and access control
/// Handles secure storage, role-based access, and data protection
class SecurityService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Storage keys
  static const String _userRoleKey = 'user_role';
  // Removed unused keys _userPermissionsKey and _sessionTokenKey to satisfy linter.

  /// Get current user role (null if not set). Falls back to guest if stored value invalid.
  Future<UserRole?> getUserRole() async {
    try {
      final roleString = await _secureStorage.read(key: _userRoleKey);
      if (roleString == null) return null;
      return UserRole.values.firstWhere(
        (role) => role.name == roleString,
        orElse: () => UserRole.guest,
      );
    } catch (e) {
      return null;
    }
  }

  /// Set user role (called after authentication)
  Future<void> setUserRole(UserRole role) async {
    await _secureStorage.write(key: _userRoleKey, value: role.name);
  }

  /// Clear user role (on logout)
  Future<void> clearUserRole() async {
    await _secureStorage.delete(key: _userRoleKey);
  }

  /// Check if user has specific permission
  Future<bool> hasPermission(Permission permission) async {
    final role = await getUserRole();
    if (role == null) return false;

    final permissions = _getRolePermissions(role);
    return permissions.contains(permission);
  }

  /// Get all permissions for a role
  List<Permission> _getRolePermissions(UserRole role) {
    switch (role) {
      case UserRole.admin:
        // Admin has all permissions
        return Permission.values;

      case UserRole.doctor:
        return [
          Permission.viewPatientRecords,
          Permission.editPatientRecords,
          Permission.viewDoctorSchedule,
          Permission.cancelAppointments,
          Permission.accessTelemedicine,
          Permission.sendNotifications,
        ];

      case UserRole.patient:
        return [
          Permission.createAppointments,
          Permission.cancelAppointments,
          Permission.accessTelemedicine,
        ];

      case UserRole.guest:
        return [];
    }
  }

  /// Store sensitive data securely
  Future<void> storeSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Retrieve sensitive data securely
  Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Delete secure data
  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Clear all secure data (on logout)
  Future<void> clearAllSecureData() async {
    await _secureStorage.deleteAll();
  }

  /// Validate session and check if user is authenticated
  Future<bool> isAuthenticated() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // Check if token is still valid
    try {
      final idToken = await user.getIdToken(true);
      return idToken != null;
    } catch (e) {
      return false;
    }
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Check if current user can access patient data.
  /// NOTE: Doctor access currently only checks permission flag; consider adding
  /// a Firestore lookup to verify doctor-patient relationship via appointments.
  Future<bool> canAccessPatientData(String patientId) async {
    final role = await getUserRole();
    final currentUserId = getCurrentUserId();

    if (currentUserId == null) return false;

    // Admin can access all patient data
    if (role == UserRole.admin) return true;

    // Patient can only access their own data
    if (role == UserRole.patient) {
      return currentUserId == patientId;
    }

    // Doctor can access patient data if they have an appointment
    // This would require additional database check
    if (role == UserRole.doctor) {
      return await hasPermission(Permission.viewPatientRecords);
    }

    return false;
  }

  /// Check if current user can access doctor data.
  /// Patients are allowed basic access for booking purposes.
  Future<bool> canAccessDoctorData(String doctorId) async {
    final role = await getUserRole();
    final currentUserId = getCurrentUserId();

    if (currentUserId == null) return false;

    // Admin can access all doctor data
    if (role == UserRole.admin) return true;

    // Doctor can access their own data
    if (role == UserRole.doctor && currentUserId == doctorId) {
      return true;
    }

    // Patients can view basic doctor information (for booking appointments)
    if (role == UserRole.patient) {
      return true; // Public profile only
    }

    return false;
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number format
  bool isValidPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    // Check if it has 10-15 digits (international format)
    return digits.length >= 10 && digits.length <= 15;
  }

  /// Validate password strength
  Map<String, dynamic> validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    final isValid = hasMinLength && hasUppercase && hasLowercase && hasDigit;

    return {
      'isValid': isValid,
      'hasMinLength': hasMinLength,
      'hasUppercase': hasUppercase,
      'hasLowercase': hasLowercase,
      'hasDigit': hasDigit,
      'hasSpecialChar': hasSpecialChar,
      'strength': _calculatePasswordStrength(
        hasMinLength,
        hasUppercase,
        hasLowercase,
        hasDigit,
        hasSpecialChar,
      ),
    };
  }

  /// Calculate password strength (0-100)
  int _calculatePasswordStrength(
    bool hasMinLength,
    bool hasUppercase,
    bool hasLowercase,
    bool hasDigit,
    bool hasSpecialChar,
  ) {
    int strength = 0;
    if (hasMinLength) strength += 20;
    if (hasUppercase) strength += 20;
    if (hasLowercase) strength += 20;
    if (hasDigit) strength += 20;
    if (hasSpecialChar) strength += 20;
    return strength;
  }

  /// Sanitize user input to prevent injection attacks
  String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Encode sensitive data before storage (simple Base64 encoding)
  /// Note: For production, use proper encryption libraries
  String encodeData(String data) {
    return base64Encode(utf8.encode(data));
  }

  /// Decode sensitive data
  String decodeData(String encodedData) {
    return utf8.decode(base64Decode(encodedData));
  }

  /// Check if user session is expired
  Future<bool> isSessionExpired() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return true;

      // Get token to check expiration
      final tokenResult = await user.getIdTokenResult();
      final expirationTime = tokenResult.expirationTime;

      if (expirationTime == null) return true;

      return DateTime.now().isAfter(expirationTime);
    } catch (e) {
      return true;
    }
  }

  /// Refresh authentication token
  Future<bool> refreshAuthToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.getIdToken(true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Log security event (for audit trail)
  Future<void> logSecurityEvent(
      String event, Map<String, dynamic> details) async {
    // In a production app, this would log to a secure backend
    // For now, we'll just print to debug console
    final userId = getCurrentUserId() ?? 'anonymous';
    final timestamp = DateTime.now().toIso8601String();

    // ignore: avoid_print
    print(
        'Security Event [$timestamp]: $event - User: $userId - Details: $details');

    // TODO: Implement proper logging to Firestore or analytics service
  }
}
