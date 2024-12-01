import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class FollowUpInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const FollowUpInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[350],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Ask follow-up...',
                hintStyle: TextStyle(
                  color: themeProvider.isDarkMode
                      ? Colors.white70
                      : Colors.black45,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => onSubmitted(controller.text),
            ),
          ),
          IconButton(
            icon: Icon(
              Iconsax.send_1,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => onSubmitted(controller.text),
          ),
        ],
      ),
    );
  }
}
