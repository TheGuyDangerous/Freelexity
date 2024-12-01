import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../utils/constants.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSharePressed;

  const SearchAppBar({super.key, required this.onSharePressed});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppBar(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        AppConstants.appName,
        style: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Iconsax.export,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: onSharePressed,
        ),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
