import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color backgroundColor = Color(0xFFF4F4F2);
  static const Color textColor = Color(0xFF333333);
  static const Color whiteColor = Colors.white;
  static const Color accentColor = Color(0xFF3498DB);

  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: whiteColor,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}