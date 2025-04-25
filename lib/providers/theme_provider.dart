import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Par défaut, le thème est clair
  ThemeMode _themeMode = ThemeMode.light;

  // Getter pour récupérer le thème actuel
  ThemeMode get themeMode => _themeMode;

  // Méthode pour basculer entre le mode sombre et clair
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notifie les écouteurs du changement
  }
}