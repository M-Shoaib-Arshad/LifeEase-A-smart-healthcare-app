import 'package:flutter/material.dart';

/// A divider widget with text in the middle, typically used to separate
/// social authentication options from email/password login.
class SocialAuthDivider extends StatelessWidget {
  /// The text to display in the middle of the divider.
  final String text;

  const SocialAuthDivider({
    super.key,
    this.text = 'Or continue with',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
