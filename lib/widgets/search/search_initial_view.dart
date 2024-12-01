import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SearchInitialView extends StatelessWidget {
  const SearchInitialView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 350,
            height: 200,
            child: Lottie.asset(
              'assets/animations/freelexity-lightgrey.json',
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
              frameRate: FrameRate(120),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'An Open Source Answer Engine',
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'Raleway',
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
