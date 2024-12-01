import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:lottie/lottie.dart';
import 'package:iconsax/iconsax.dart';
import '../utils/constants.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(
        context,
        title: 'Welcome to ${AppConstants.appName}',
        subtitle: 'Discover a new way to search',
        animationPath: 'assets/animations/freelexity-lightgrey.json',
        backgroundColor: Color.fromRGBO(17, 20, 25, 1),
        contentColor: Colors.white,
      ),
      _buildPage(
        context,
        title: 'Setup your API keys',
        subtitle: 'In the settings page, and start searching',
        animationPath: 'assets/animations/freelexity-lightgrey.json',
        backgroundColor: Color.fromRGBO(26, 17, 18, 1),
        contentColor: Colors.white,
      ),
      _buildPage(
        context,
        title: 'Powered by AI',
        subtitle: 'Search for anything and everything',
        animationPath: 'assets/animations/freelexity-lightgrey.json',
        backgroundColor: Color.fromRGBO(15, 21, 19, 1),
        contentColor: Colors.white,
        showButton: true,
      ),
    ];

    return Scaffold(
      body: LiquidSwipe(
        pages: pages,
        enableLoop: false,
        fullTransitionValue: 300,
        waveType: WaveType.liquidReveal,
        positionSlideIcon: 0.8,
      ),
    );
  }

  Widget _buildPage(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String animationPath,
    required Color backgroundColor,
    required Color contentColor,
    bool showButton = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: backgroundColor,
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Lottie.asset(
                      animationPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: contentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: contentColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showButton)
              Positioned(
                bottom: 30,
                right: 30,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: contentColor,
                    foregroundColor: backgroundColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Icon(
                    Iconsax.search_normal,
                    color: backgroundColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
