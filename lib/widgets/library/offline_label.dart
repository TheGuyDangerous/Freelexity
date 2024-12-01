import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class OfflineLabel extends StatelessWidget {
  const OfflineLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Color.fromRGBO(28, 36, 31, 1)
            : Color.fromRGBO(245, 245, 220, 1),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Color.fromRGBO(70, 92, 30, 1)
              : Color.fromRGBO(192, 192, 168, 1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Offline',
        style: TextStyle(
          color: themeProvider.isDarkMode
              ? Color.fromRGBO(168, 221, 32, 1)
              : Color.fromRGBO(28, 36, 31, 1),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
