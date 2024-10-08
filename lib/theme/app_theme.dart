import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Raleway'),
      bodyMedium: TextStyle(fontFamily: 'Raleway'),
      titleLarge: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
      titleMedium:
          TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
      titleSmall: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[900],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
  );

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'Raleway'),
      bodyMedium: TextStyle(fontFamily: 'Raleway'),
      titleLarge: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
      titleMedium:
          TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
      titleSmall: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
    ).apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[100],
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
  );
}
