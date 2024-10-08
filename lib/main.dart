import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/splash_screen.dart';
import '../theme/app_theme.dart';
import '../theme_provider.dart';
import './utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: AppConstants.appName,
          theme: themeProvider.isDarkMode
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          home: SplashScreen(),
        );
      },
    );
  }
}
