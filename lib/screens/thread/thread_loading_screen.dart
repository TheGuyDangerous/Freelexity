import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/thread/loading_shimmer.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class ThreadLoadingScreen extends StatelessWidget {
  final String query;

  const ThreadLoadingScreen({Key? key, required this.query}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('Thread', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                query,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            LoadingShimmer(isDarkMode: themeProvider.isDarkMode),
          ],
        ),
      ),
    );
  }
}
