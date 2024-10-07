import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class SummaryCard extends StatelessWidget {
  final String summary;
  final Function(String) onSpeakPressed;
  final bool isSpeaking;

  const SummaryCard({
    Key? key,
    required this.summary,
    required this.onSpeakPressed,
    required this.isSpeaking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[100],
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Answer',
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSpeaking ? Iconsax.volume_slash : Iconsax.volume_high,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                    size: 20,
                  ),
                  onPressed: () => onSpeakPressed(summary),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              summary,
              style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
