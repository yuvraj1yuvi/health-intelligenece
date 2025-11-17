import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF047857); // Dark emerald
  static const Color secondaryColor = Color(0xFFF59E0B); // Warm amber
  static const Color tertiaryColor = Color(0xFFEC4899); // Vibrant rose
  static const Color surfaceTintColor = Color(0xFFD1FAE5); // Light green tint

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        surfaceTint: surfaceTintColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0, // Flat design
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0, // Flat cards
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        surfaceTintColor: surfaceTintColor.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0, // Flat buttons
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceTintColor.withOpacity(0.1),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: secondaryColor, // Swap for dark theme
        secondary: primaryColor,
        tertiary: tertiaryColor,
        surfaceTint: surfaceTintColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF0F0F0F), // Very dark
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Color(0xFF1A1A1A), // Dark surface
        surfaceTintColor: secondaryColor.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: secondaryColor,
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: secondaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
        filled: true,
        fillColor: Color(0xFF2A2A2A),
      ),
    );
  }
}