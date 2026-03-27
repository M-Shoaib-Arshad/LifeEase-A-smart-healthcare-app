import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// A prominent red SOS floating-action button.
class SosButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SosButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Colors.red,
      elevation: 6,
      icon: const Icon(Icons.emergency, color: AppColors.textLight),
      label: const Text(
        'SOS',
        style: TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
