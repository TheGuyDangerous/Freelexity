import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.clock,
              size: 64,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.grey[600]),
          SizedBox(height: 16),
          Text(
            'Your search history will appear here',
            style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 16),
          ),
        ],
      ),
    );
  }
}
