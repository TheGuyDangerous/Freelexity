import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../../widgets/thread/loading_shimmer.dart';
import '../../services/search_service.dart';
import 'thread_screen.dart';
import '../../theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThreadLoadingScreen extends StatefulWidget {
  final String query;
  final String? savedThreadPath;
  final Map<String, dynamic>? savedThreadData;

  const ThreadLoadingScreen({
    Key? key,
    required this.query,
    this.savedThreadPath,
    this.savedThreadData,
  }) : super(key: key);

  @override
  State<ThreadLoadingScreen> createState() => _ThreadLoadingScreenState();
}

class _ThreadLoadingScreenState extends State<ThreadLoadingScreen> {
  final SearchService _searchService = SearchService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadThreadOrSearch();
    });
  }

  Future<void> _loadThreadOrSearch() async {
    if (widget.savedThreadData != null) {
      _navigateToThreadScreen(widget.savedThreadData!);
    } else if (widget.savedThreadPath != null) {
      await _loadSavedThread(widget.savedThreadPath!);
    } else {
      await _performSearch();
    }
  }

  Future<void> _loadSavedThread(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final threadData = json.decode(jsonString);
        _navigateToThreadScreen(threadData);
      } else {
        await _performSearch();
      }
    } catch (e) {
      debugPrint('Error loading saved thread: $e');
      await _performSearch();
    }
  }

  Future<void> _performSearch() async {
    final results = await _searchService.performSearch(context, widget.query);
    if (mounted) {
      if (results != null) {
        _navigateToThreadScreen(results);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _navigateToThreadScreen(Map<String, dynamic> data) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ThreadScreen(
          query: data['query'],
          searchResults: List<Map<String, dynamic>>.from(data['searchResults']),
          summary: data['summary'],
          savedSections: data['sections'] as List<dynamic>?,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
            widget.savedThreadPath != null || widget.savedThreadData != null
                ? 'Loading Saved Thread'
                : 'Searching...'),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        child: LoadingShimmer(isDarkMode: themeProvider.isDarkMode),
      ),
    );
  }
}
