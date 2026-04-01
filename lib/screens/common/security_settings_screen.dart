import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/biometric_service.dart';
import '../../services/security_service.dart';
import '../../utils/app_colors.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  final SecurityService _securityService = SecurityService();
  static const _storage = FlutterSecureStorage();
  static const _biometricEnabledKey = 'biometric_login_enabled';

  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final available = await _biometricService.isAvailable();
    final enabledStr = await _storage.read(key: _biometricEnabledKey);
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabledStr == 'true';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Require biometric confirmation before enabling
      final ok = await _biometricService.authenticate(
        reason: 'Confirm biometrics to enable biometric login',
      );
      if (!ok) return;
    }
    await _storage.write(
        key: _biometricEnabledKey, value: value ? 'true' : 'false');
    if (!value) {
      // Remove saved credentials when biometrics is disabled
      await _storage.delete(key: 'saved_email');
      await _storage.delete(key: 'saved_password');
    }
    await _securityService.logSecurityEvent(
      value ? 'biometric_enabled' : 'biometric_disabled',
      {},
    );
    if (mounted) setState(() => _biometricEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primaryLight.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.security,
                            size: 32, color: AppColors.primaryDark),
                        const SizedBox(height: 8),
                        Text(
                          'Security Settings',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your security preferences',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Biometric Section
                  _buildSectionTitle(context, 'Biometric Authentication'),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.fingerprint,
                                color: theme.colorScheme.primary),
                          ),
                          title: const Text('Biometric Login'),
                          subtitle: Text(
                            _biometricAvailable
                                ? 'Use fingerprint or face ID to sign in'
                                : 'Biometrics not available on this device',
                          ),
                          value: _biometricEnabled && _biometricAvailable,
                          onChanged:
                              _biometricAvailable ? _toggleBiometric : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Auto-Logout Section
                  _buildSectionTitle(context, 'Session Security'),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.timer_outlined,
                            color: theme.colorScheme.primary),
                      ),
                      title: const Text('Auto-Logout'),
                      subtitle: const Text(
                          'Automatically signed out after 30 minutes of inactivity'),
                      trailing: Icon(Icons.check_circle,
                          color: theme.colorScheme.primary),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Data Encryption Section
                  _buildSectionTitle(context, 'Data Protection'),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.lock, color: theme.colorScheme.primary),
                      ),
                      title: const Text('Sensitive Data Encryption'),
                      subtitle: const Text(
                          'Saved login credentials are encrypted with AES-256 before local storage'),
                      trailing: Icon(Icons.check_circle,
                          color: theme.colorScheme.primary),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Audit Log Section
                  _buildSectionTitle(context, 'Audit Trail'),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.history,
                            color: theme.colorScheme.primary),
                      ),
                      title: const Text('Security Audit Log'),
                      subtitle: const Text(
                          'Security events are logged to help protect your account'),
                      trailing: Icon(Icons.check_circle,
                          color: theme.colorScheme.primary),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
