import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class RelatedQuestions extends StatelessWidget {
  final List<String> questions;

  const RelatedQuestions({Key? key, required this.questions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (questions.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[300],
          thickness: 1,
          height: 32,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Related',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                questions[index],
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(
                Iconsax.arrow_right_3,
                color:
                    themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                size: 18,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              dense: true,
              onTap: () {
                // Implement navigation to new search with this question
              },
            );
          },
        ),
      ],
    );
  }
}
