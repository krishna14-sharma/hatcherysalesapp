import 'package:flutter/material.dart';

/// Central palette — change these to rebrand the whole app.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF0878C0); // Phoenix logo blue
  static const primaryDark = Color(0xFF00477F); // logo deep navy-blue
  static const accent = Color(0xFF7CC4E4); // logo light aqua
  static const accentLight = Color(0xFFBDEBFF);
  static const success = Color(0xFF15803D);
  static const danger = Color(0xFFDC2626);

  static const background = Color(0xFFF3F8FC);
  static const surface = Colors.white;
  static const border = Color(0xFFDCE7F1);
  static const textPrimary = Color(0xFF1A1A1A); // logo charcoal
  static const textSecondary = Color(0xFF6B7280);

  static const headerGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.danger,
      brightness: Brightness.light,
    );

    final radius = BorderRadius.circular(12);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: AppColors.border,
    );
  }
}
