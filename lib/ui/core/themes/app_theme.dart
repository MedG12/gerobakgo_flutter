import 'package:flutter/material.dart';

class AppTheme {
  // Warna Primer
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF483AA0);
  static const Color primaryLight = Color(0xFF7964C1);

  // Warna Netral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static Color grey = Colors.grey[600]!;

  // Warna Feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);

  // Text Theme
  static TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),

    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),

    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),

    labelSmall: TextStyle(fontSize: 12),
    labelMedium: TextStyle(fontSize: 14),
    labelLarge: TextStyle(fontSize: 16),
  );

  // ThemeData Utama
  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    colorScheme: ColorScheme.light(
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
