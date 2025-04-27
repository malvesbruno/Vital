import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Color backgroundColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color textColor;
  final String imagePath;
  final int price;
  final int requiredLevel;
  bool owned;

  AppTheme({
    required this.name,
    required this.backgroundColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.textColor,
    required this.imagePath,
    required this.price,
    required this.requiredLevel,
    this.owned = false,
  });

  ThemeData toThemeData() {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark, // ou Brightness.light dependendo do seu app
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
        surface: primaryColor,
        onPrimary: textColor,
        onSecondary: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: textColor),
        bodyLarge: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor),
      ),
      iconTheme: IconThemeData(
        color: secondaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: textColor,
        ),
      ),
      cardColor: primaryColor,
    );
  }
}
