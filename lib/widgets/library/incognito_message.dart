import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class IncognitoMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.shield_tick,
              size: 64,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.grey[600]),
          SizedBox(height: 16),
          Text(
            'Incognito Mode Active',
            style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Your search history is not being saved',
            style: TextStyle(
                color:
                    themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14),
          ),
        ],
      ),
    );
  }
}
