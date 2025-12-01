import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: AppColors.primarySwatch,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryLight,
    secondary: AppColors.accentPurple,
    secondaryContainer: AppColors.accentPink,
    tertiary: AppColors.accentMint,
    tertiaryContainer: AppColors.accentMint,
    surface: AppColors.bgCard,
    error: AppColors.accentCoral,
    onPrimary: AppColors.textLight,
    onSecondary: AppColors.textLight,
    onSurface: AppColors.textPrimary,
    onError: AppColors.textLight,
  ),
  scaffoldBackgroundColor: AppColors.bgMain,
  cardColor: AppColors.bgCard,
  dividerColor: AppColors.borderLight,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.bgCard,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryDark,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.bgCard,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accentCoral),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accentCoral, width: 2),
    ),
    prefixIconColor: AppColors.primary,
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    hintStyle: const TextStyle(color: AppColors.textSecondary),
  ),
  cardTheme: CardThemeData(
    color: AppColors.bgCard,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textLight,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.bgCard,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
  ),
  iconTheme: const IconThemeData(
    color: AppColors.primary,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimary),
    displayMedium: TextStyle(color: AppColors.textPrimary),
    displaySmall: TextStyle(color: AppColors.textPrimary),
    headlineLarge: TextStyle(color: AppColors.textPrimary),
    headlineMedium: TextStyle(color: AppColors.textPrimary),
    headlineSmall: TextStyle(color: AppColors.textPrimary),
    titleLarge: TextStyle(color: AppColors.textPrimary),
    titleMedium: TextStyle(color: AppColors.textPrimary),
    titleSmall: TextStyle(color: AppColors.textPrimary),
    bodyLarge: TextStyle(color: AppColors.textPrimary),
    bodyMedium: TextStyle(color: AppColors.textPrimary),
    bodySmall: TextStyle(color: AppColors.textSecondary),
    labelLarge: TextStyle(color: AppColors.textPrimary),
    labelMedium: TextStyle(color: AppColors.textSecondary),
    labelSmall: TextStyle(color: AppColors.textSecondary),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.bgDark,
    contentTextStyle: TextStyle(color: AppColors.textLight),
    actionTextColor: AppColors.primaryLight,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.primaryLight,
    labelStyle: const TextStyle(color: AppColors.primaryDark),
    secondaryLabelStyle: const TextStyle(color: AppColors.textLight),
    selectedColor: AppColors.primary,
    disabledColor: AppColors.borderLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.primaryLight,
    circularTrackColor: AppColors.primaryLight,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.borderLight;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }
      return AppColors.borderLight;
    }),
  ),
);

final ThemeData darkTheme = ThemeData(
  primarySwatch: AppColors.primarySwatch,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.accentPurple,
    secondaryContainer: AppColors.accentPurple,
    tertiary: AppColors.accentMint,
    tertiaryContainer: AppColors.accentMint,
    surface: AppColors.darkSurface,
    error: AppColors.accentCoral,
    onPrimary: AppColors.textLight,
    onSecondary: AppColors.textLight,
    onSurface: AppColors.darkTextPrimary,
    onError: AppColors.textLight,
  ),
  scaffoldBackgroundColor: AppColors.bgDark,
  cardColor: AppColors.darkCard,
  dividerColor: AppColors.darkSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    titleTextStyle: TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkCard,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkSurface),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkSurface),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accentCoral),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accentCoral, width: 2),
    ),
    prefixIconColor: AppColors.primary,
    labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
    hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkCard,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textLight,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkSurface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.darkTextSecondary,
  ),
  iconTheme: const IconThemeData(
    color: AppColors.primary,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.darkTextPrimary),
    displayMedium: TextStyle(color: AppColors.darkTextPrimary),
    displaySmall: TextStyle(color: AppColors.darkTextPrimary),
    headlineLarge: TextStyle(color: AppColors.darkTextPrimary),
    headlineMedium: TextStyle(color: AppColors.darkTextPrimary),
    headlineSmall: TextStyle(color: AppColors.darkTextPrimary),
    titleLarge: TextStyle(color: AppColors.darkTextPrimary),
    titleMedium: TextStyle(color: AppColors.darkTextPrimary),
    titleSmall: TextStyle(color: AppColors.darkTextPrimary),
    bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
    bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
    bodySmall: TextStyle(color: AppColors.darkTextSecondary),
    labelLarge: TextStyle(color: AppColors.darkTextPrimary),
    labelMedium: TextStyle(color: AppColors.darkTextSecondary),
    labelSmall: TextStyle(color: AppColors.darkTextSecondary),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.darkCard,
    contentTextStyle: TextStyle(color: AppColors.darkTextPrimary),
    actionTextColor: AppColors.primary,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.darkCard,
    labelStyle: const TextStyle(color: AppColors.darkTextPrimary),
    secondaryLabelStyle: const TextStyle(color: AppColors.textLight),
    selectedColor: AppColors.primary,
    disabledColor: AppColors.darkSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.darkSurface,
    circularTrackColor: AppColors.darkSurface,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.darkSurface;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryDark;
      }
      return AppColors.darkSurface;
    }),
  ),
);
