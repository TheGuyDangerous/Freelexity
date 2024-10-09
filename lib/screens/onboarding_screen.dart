import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:lottie/lottie.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(
        context,
        backgroundColor: AppTheme.onboardingBackground1,
        contentColor: AppTheme.onboardingText1,
        title: 'Welcome to ${AppConstants.appName}',
        subtitle: 'Discover a new way to search',
        animationPath: 'assets/animations/freelexity-lightgrey.json',
      ),
      _buildPage(
        context,
        backgroundColor: AppTheme.onboardingBackground2,
        contentColor: AppTheme.onboardingText2,
        title: 'Setup your API keys',
        subtitle: 'In the settings page, and start searching',
        animationPath: 'assets/animations/freelexity-lightgrey.json',
      ),
      _buildPage(
        context,
        backgroundColor: AppTheme.onboardingBackground3,
        contentColor: AppTheme.onboardingText1,
        title: 'Powered by AI',
        subtitle: 'Search for anything and everything',
        animationPath: 'assets/animations/freelexity-lightgrey.json',
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
    required Color backgroundColor,
    required Color contentColor,
    required String title,
    required String subtitle,
    required String animationPath,
    bool showButton = false,
  }) {
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
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: contentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: contentColor,
                    ),
                    child: Icon(
                      Iconsax.search_normal,
                      color: backgroundColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
