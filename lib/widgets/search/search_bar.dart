import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool useWhisperModel;
  final Function(String) onSubmitted;
  final VoidCallback onListenPressed;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.isListening,
    required this.useWhisperModel,
    required this.onSubmitted,
    required this.onListenPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.grey
                        : Colors.grey[600]),
                border: InputBorder.none,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            icon: Icon(
              isListening
                  ? Iconsax.stop_circle
                  : (useWhisperModel
                      ? Iconsax.microphone_2
                      : Iconsax.microphone),
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: onListenPressed,
          ),
        ],
      ),
    );
  }
}
