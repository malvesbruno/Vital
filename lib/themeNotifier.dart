import 'package:flutter/material.dart';
import '../models/ColorsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  AppTheme _currentTheme;

  ThemeNotifier(this._currentTheme);

  AppTheme get currentTheme => _currentTheme;

  set currentTheme(AppTheme newTheme) {
    _currentTheme = newTheme;
    _saveThemeName(newTheme.name); // Salva no shared_prefs
    notifyListeners();
  }

  void _saveThemeName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentTheme', name);
  }
}