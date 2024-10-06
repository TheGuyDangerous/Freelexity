import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/web_scraper_service.dart';
import '../services/groq_api_service.dart';
import 'thread_screen.dart';
import 'thread_loading_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../custom_page_route.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart'; // Add this import
import '../services/search_service.dart'; // Add this import

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WebScraperService _webScraperService = WebScraperService();
  final GroqApiService _groqApiService = GroqApiService();
  final SearchService _searchService = SearchService(); // Add this line
  late stt.SpeechToText _speech;
  bool _isListening = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildInitialView()),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: _buildSearchBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 100,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        "Freelexity",
        style: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250, // Increased from 200
            height: 250, // Increased from 200
            child: Lottie.asset(
              'assets/loading_animation.json',
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ),
          SizedBox(height: 24), // Increased from 16
          Text(
            'An Open Source Answer Engine',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 18, // Increased from 16
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          IconButton(
            icon: Icon(_isListening ? Iconsax.microphone_2 : Iconsax.microphone,
                color: Colors.white), // Updated icons
            onPressed: _listen,
          ),
        ],
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() {
            _searchController.text = result.recognizedWords;
            if (result.finalResult) {
              _isListening = false;
              _performSearch();
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      // Don't perform search if the query is empty
      return;
    }

    // Open ThreadLoadingScreen immediately
    Navigator.of(context).push(
      CustomPageRoute(
        child: ThreadLoadingScreen(query: _searchController.text),
      ),
    );

    // Perform the search using SearchService
    await _searchService.performSearch(context, _searchController.text);
  }

  String _preprocessContent(String content) {
    // Remove extra whitespace and limit to first 1000 characters
    return content
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .substring(0, min(1000, content.length));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
