import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color calmBlue = Color(0xFF4A90E2);
  static const Color navy = Color(0xFF16324F);

  // Secondary Colors
  static const Color iceBlue = Color(0xFFEAF6FF);
  static const Color fogGray = Color(0xFFD8DDE6);
  static const Color coolGraphite = Color(0xFF5C677D);

  // Accent Colors
  static const Color seaGreen = Color(0xFF53D1B6);

  // Additional Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: calmBlue,
        secondary: seaGreen,
        surface: white,
        background: iceBlue,
        error: Colors.red,
        onPrimary: white,
        onSecondary: white,
        onSurface: navy,
        onBackground: navy,
        onError: white,
      ),
      scaffoldBackgroundColor: iceBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: calmBlue,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fogGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fogGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: calmBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: calmBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: calmBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: navy,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: navy,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: navy,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: coolGraphite,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: coolGraphite,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: coolGraphite,
        ),
      ),
    );
  }
}