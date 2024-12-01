import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  Color _seedColor = Colors.blue;

  bool get isDarkMode => _isDarkMode;
  Color get seedColor => _seedColor;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  ThemeData get theme => _seedColor == Colors.black
      ? ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            color: Colors.grey[900],
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black,
          ),
          dialogTheme: DialogTheme(
            backgroundColor: Colors.grey[900],
          ),
        )
      : ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _seedColor,
            brightness: _isDarkMode ? Brightness.dark : Brightness.light,
          ),
        );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void updateSeedColor(Color newSeedColor) {
    _seedColor = newSeedColor;
    _saveSeedColorToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    final seedColorValue = prefs.getInt('seedColor');
    if (seedColorValue != null) {
      _seedColor = Color(seedColorValue);
    }
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _saveSeedColorToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', _seedColor.value);
  }

  static ThemeProvider of(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false);
  }
}
