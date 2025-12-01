import 'package:flutter/material.dart';

/// A reusable Google Sign-In button widget that follows Google's branding guidelines.
class GoogleSignInButton extends StatelessWidget {
  /// Callback function when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// The text to display on the button.
  final String text;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                ),
              )
            : _buildGoogleLogo(),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return Image.asset(
      'assets/google.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    );
  }
}
