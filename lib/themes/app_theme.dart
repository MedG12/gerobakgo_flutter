import 'package:flutter/material.dart';

class AppTheme {
  // Warna Primer
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF483AA0);
  static const Color primaryLight = Color(0xFF7964C1);

  // Warna Netral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);

  // Warna Feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);

  // Text Theme
  static TextTheme textTheme = const TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(fontSize: 16),
  );

  // ThemeData Utama
  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: primaryLight,
      surface: white,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
      ),
    ),
  );
}
