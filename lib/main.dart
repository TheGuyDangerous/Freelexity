import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/splash_screen.dart';
import './screens/onboarding_screen.dart';
import './screens/home/home_screen.dart';
import 'theme/theme_provider.dart';
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
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: AppConstants.appName,
          theme: themeProvider.theme,
          home: const SplashScreen(),
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}
