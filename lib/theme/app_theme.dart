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

  // Updated onboarding colors
  static const Color onboardingBackground1 = Colors.black; // White
  static const Color onboardingBackground2 = Color(0xFFF5F5F5); // Light gray
  static const Color onboardingBackground3 = Color(0xFF1A1A1A); // Dark gray
  static const Color onboardingText1 = Colors.white;
  static const Color onboardingText2 = Color(0xFF333333); // Dark gray for text
  static const Color onboardingText3 =
      Color(0xFF4A4A4A); // Medium gray for text
}
