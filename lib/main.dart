import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freelexity/screens/splash_screen.dart';
import 'package:freelexity/theme/app_theme.dart';
import 'package:freelexity/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Freelexity',
          theme: themeProvider.isDarkMode
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          home: SplashScreen(),
        );
      },
    );
  }
}
