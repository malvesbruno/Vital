import 'package:flutter/material.dart';


//Modelo de tema
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
  final bool exclusive;
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
    required this.exclusive,
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'backgroundColor': backgroundColor,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      'textColor': textColor,
      'imagePath': imagePath,
      'price': price,
      'requiredLevel': requiredLevel,
      'exclusive': exclusive,
      'owned': owned,
    };
  }

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      name: json['name'],
      backgroundColor: json['backgroundColor'],
      primaryColor: json['primaryColor'],
      secondaryColor: json['secondaryColor'],
      accentColor: json['accentColor'],
      textColor: json['textColor'],
      imagePath: json['imagePath'],
      price: json['price'],
      requiredLevel: json['requiredLevel'],
      exclusive: json['exclusive'],
      owned: json['owned']
    );
  }
  
}
