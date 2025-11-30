import 'package:flutter/material.dart';

/// Centralized color palette for the LifeEase healthcare app.
/// Based on the design specification with primary, background, accent, text, and border colors.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================
  // PRIMARY COLORS
  // ============================================
  
  /// Light primary color - #A8D8EA
  static const Color primaryLight = Color(0xFFA8D8EA);
  
  /// Primary color - #4FC3F7
  static const Color primary = Color(0xFF4FC3F7);
  
  /// Dark primary color - #0288D1
  static const Color primaryDark = Color(0xFF0288D1);

  // ============================================
  // BACKGROUND COLORS
  // ============================================
  
  /// Main background color - #B8E4F0
  static const Color bgMain = Color(0xFFB8E4F0);
  
  /// Card background color - #FFFFFF
  static const Color bgCard = Color(0xFFFFFFFF);
  
  /// Dark background color - #1A1A1A
  static const Color bgDark = Color(0xFF1A1A1A);

  // ============================================
  // ACCENT COLORS
  // ============================================
  
  /// Pink accent - #F3E5F5
  static const Color accentPink = Color(0xFFF3E5F5);
  
  /// Coral accent - #FF6B6B
  static const Color accentCoral = Color(0xFFFF6B6B);
  
  /// Mint accent - #80CBC4
  static const Color accentMint = Color(0xFF80CBC4);
  
  /// Purple accent - #9575CD
  static const Color accentPurple = Color(0xFF9575CD);

  // ============================================
  // TEXT COLORS
  // ============================================
  
  /// Primary text color - #000000
  static const Color textPrimary = Color(0xFF000000);
  
  /// Secondary text color - #666666
  static const Color textSecondary = Color(0xFF666666);
  
  /// Light text color - #FFFFFF
  static const Color textLight = Color(0xFFFFFFFF);

  // ============================================
  // BORDER COLORS
  // ============================================
  
  /// Light border color - #E0E0E0
  static const Color borderLight = Color(0xFFE0E0E0);

  // ============================================
  // SEMANTIC COLORS (for status indicators)
  // ============================================
  
  /// Success/positive color
  static const Color success = Color(0xFF80CBC4); // Using accent mint
  
  /// Error/danger color
  static const Color error = Color(0xFFFF6B6B); // Using accent coral
  
  /// Warning color
  static const Color warning = Color(0xFFFFB74D);
  
  /// Info color
  static const Color info = Color(0xFF4FC3F7); // Using primary

  // ============================================
  // GRADIENT COLORS
  // ============================================
  
  /// Primary gradient for headers and buttons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Light gradient for backgrounds
  static const LinearGradient lightGradient = LinearGradient(
    colors: [primaryLight, bgMain],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Purple accent gradient
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [accentPurple, Color(0xFF7E57C2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // DARK THEME COLORS
  // ============================================
  
  /// Dark theme surface color
  static const Color darkSurface = Color(0xFF2D2D2D);
  
  /// Dark theme card color
  static const Color darkCard = Color(0xFF3D3D3D);
  
  /// Dark theme text primary
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  
  /// Dark theme text secondary
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  /// Darker coral for gradients - #E53935
  static const Color accentCoralDark = Color(0xFFE53935);

  // ============================================
  // MATERIAL COLOR SWATCH
  // ============================================
  
  /// Material color swatch based on primary color
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF4FC3F7,
    <int, Color>{
      50: Color(0xFFE1F5FE),
      100: Color(0xFFB3E5FC),
      200: Color(0xFF81D4FA),
      300: Color(0xFF4FC3F7),
      400: Color(0xFF29B6F6),
      500: Color(0xFF03A9F4),
      600: Color(0xFF039BE5),
      700: Color(0xFF0288D1),
      800: Color(0xFF0277BD),
      900: Color(0xFF01579B),
    },
  );
}
