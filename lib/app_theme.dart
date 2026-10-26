import 'package:flutter/material.dart';

// These are the colors used across the whole app.
class AppColors {
  // Light blue is the main accent for buttons, sliders, and switches.
  static const Color lightBlue = Color(0xFF5AB9EA);
  // This darker blue is used for blue text on light backgrounds so it stays readable.
  static const Color darkBlue = Color(0xFF1C6EA4);
  static const Color coral = Color(0xFFFF6B4A);
  static const Color mint = Color(0xFF2EC4A0);
  static const Color amber = Color(0xFFF5A524);
  static const Color navy = Color(0xFF0F1B2D);
  static const Color navyCard = Color(0xFF1A2940);
  static const Color offWhite = Color(0xFFFAF7F2);
  static const Color white = Color(0xFFFFFFFF);
}

// This class builds the light and dark themes from the same settings.
class AppTheme {
  // Every card in the app uses this corner radius.
  static const double cardRadius = 20;

  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      background: AppColors.offWhite,
      cardColor: AppColors.white,
    );
  }

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      background: AppColors.navy,
      cardColor: AppColors.navyCard,
    );
  }

  // This shared method keeps the two themes consistent.
  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color cardColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.lightBlue,
      brightness: brightness,
      primary: AppColors.lightBlue,
      // Dark navy text is easier to read on light blue than white text.
      onPrimary: AppColors.navy,
      surface: cardColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      // Buttons are at least 48 pixels tall so they are easy to tap.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lightBlue,
          foregroundColor: AppColors.navy,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      // Text buttons in dialogs use darker blue in light mode so they are easy to read.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brightness == Brightness.light
              ? AppColors.darkBlue
              : AppColors.lightBlue,
          minimumSize: const Size(48, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
