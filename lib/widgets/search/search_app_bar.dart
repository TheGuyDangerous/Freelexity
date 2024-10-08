import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class SearchAppBar extends StatelessWidget {
  final VoidCallback onSharePressed;

  const SearchAppBar({super.key, required this.onSharePressed});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      height: 100,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 48),
          Text(
            "Freelexity",
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Iconsax.export,
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black),
              onPressed: onSharePressed,
            ),
          ),
        ],
      ),
    );
  }
}
