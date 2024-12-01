import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class ApiKeyInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;

  const ApiKeyInput({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading:
            Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black54),
        title: TextField(
          controller: controller,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
