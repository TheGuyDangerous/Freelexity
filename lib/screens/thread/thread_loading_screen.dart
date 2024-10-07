import 'package:flutter/material.dart';
import '../../widgets/thread/loading_shimmer.dart';
import '../../services/search_service.dart';
import 'thread_screen.dart';
import '../../theme_provider.dart';
import 'package:provider/provider.dart';

class ThreadLoadingScreen extends StatefulWidget {
  final String query;

  const ThreadLoadingScreen({Key? key, required this.query}) : super(key: key);

  @override
  _ThreadLoadingScreenState createState() => _ThreadLoadingScreenState();
}

class _ThreadLoadingScreenState extends State<ThreadLoadingScreen> {
  final SearchService _searchService = SearchService();

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    final results = await _searchService.performSearch(context, widget.query);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ThreadScreen(
            query: results['query'],
            searchResults: results['searchResults'],
            summary: results['summary'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('Searching...'),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
      ),
      body: LoadingShimmer(isDarkMode: themeProvider.isDarkMode),
    );
  }
}
