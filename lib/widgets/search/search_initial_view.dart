import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class SearchInitialView extends StatelessWidget {
  const SearchInitialView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 350,
            height: 200,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Lottie.asset(
                key: ValueKey<bool>(themeProvider.isDarkMode),
                themeProvider.isDarkMode
                    ? 'assets/animations/freelexity-lightgrey.json'
                    : 'assets/animations/freelexity-lightgrey.json',
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
                frameRate: FrameRate(120),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'An Open Source Answer Engine',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 18,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
