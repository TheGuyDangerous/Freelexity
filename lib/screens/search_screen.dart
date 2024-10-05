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
import 'package:iconsax/iconsax.dart'; // Add this import

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WebScraperService _webScraperService = WebScraperService();
  final GroqApiService _groqApiService = GroqApiService();
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
          fontSize: 24,
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
          Icon(Iconsax.search_normal,
              size: 80, color: Colors.white), // Updated icon
          SizedBox(height: 16),
          Text(
            'An Open Source Answer Engine',
            style: TextStyle(
              fontSize: 16,
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
    final query = _searchController.text;

    // Open ThreadLoadingScreen immediately
    Navigator.of(context).push(
      CustomPageRoute(
        child: ThreadLoadingScreen(query: query),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final braveApiKey = prefs.getString('braveApiKey') ?? '';

    if (braveApiKey.isEmpty) {
      _showErrorDialog('Please enter your Brave Search API key in settings.');
      Navigator.of(context).pop(); // Remove ThreadLoadingScreen
      return;
    }

    final url =
        Uri.parse('https://api.search.brave.com/res/v1/web/search?q=$query');

    try {
      final response = await http.get(
        url,
        headers: {'X-Subscription-Token': braveApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = List<Map<String, dynamic>>.from(data['web']['results']);

        List<String> scrapedContents = [];
        List<Map<String, dynamic>> processedResults = [];
        for (var i = 0; i < min(5, results.length); i++) {
          var result = results[i];
          try {
            final scrapedContent =
                await _webScraperService.scrapeContent(result['url']);
            result['scrapedContent'] = scrapedContent;
            scrapedContents.add(_preprocessContent(scrapedContent));
            processedResults.add(result);
          } catch (e) {
            print('Error processing content for ${result['url']}: $e');
          }
        }

        final combinedContent = scrapedContents.join(' ');
        final summary =
            await _groqApiService.summarizeContent(combinedContent, query);

        // Replace ThreadLoadingScreen with actual ThreadScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ThreadScreen(
              query: query,
              searchResults: processedResults,
              summary: summary,
            ),
          ),
        );
      } else if (response.statusCode == 429 && _retryCount < _maxRetries) {
        // Rate limit exceeded, retry after a delay
        _retryCount++;
        await Future.delayed(Duration(seconds: pow(2, _retryCount).toInt()));
        return _performSearch();
      } else {
        _showErrorDialog('Failed to perform search. Please try again.');
        Navigator.of(context).pop(); // Remove ThreadLoadingScreen
      }
    } catch (e) {
      if (_retryCount < _maxRetries) {
        _retryCount++;
        await Future.delayed(Duration(seconds: pow(2, _retryCount).toInt()));
        return _performSearch();
      } else {
        _showErrorDialog(
            'An error occurred. Please check your internet connection and try again.');
        Navigator.of(context).pop(); // Remove ThreadLoadingScreen
      }
    } finally {
      _retryCount = 0;
    }
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
