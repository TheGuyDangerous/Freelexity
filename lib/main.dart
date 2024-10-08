import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
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
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: _checkFirstLaunch(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  final bool isFirstLaunch = snapshot.data ?? true;
                  return isFirstLaunch
                      ? const OnboardingScreen()
                      : const HomeScreen();
                }
              },
            ),
        '/home': (context) => const HomeScreen(),
      },
    );
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(AppConstants.kFirstLaunchKey) ?? true;
    if (isFirstLaunch) {
      await prefs.setBool(AppConstants.kFirstLaunchKey, false);
    }
    return isFirstLaunch;
  }
}
