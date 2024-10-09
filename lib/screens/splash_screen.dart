import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500), // Animation duration
      vsync: this,
    );

    _controller.forward();

    _timer = Timer(Duration(milliseconds: 1500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/splash-light.json',
          controller: _controller,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
