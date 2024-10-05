import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/web_scraper_service.dart';
import '../services/groq_api_service.dart';
import 'thread_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  final WebScraperService _webScraperService = WebScraperService();
  final GroqApiService _groqApiService = GroqApiService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child:
                  _isLoading ? _buildLoadingIndicator() : _buildInitialView(),
            ),
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
          Icon(Icons.search, size: 80, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Where Knowledge Begins',
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
            icon: Icon(Icons.mic, color: Colors.white),
            onPressed: () {
              // Implement voice search functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    final query = _searchController.text;
    final prefs = await SharedPreferences.getInstance();
    final braveApiKey = prefs.getString('braveApiKey') ?? '';

    if (braveApiKey.isEmpty) {
      _showErrorDialog('Please enter your Brave Search API key in settings.');
      setState(() {
        _isLoading = false;
      });
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

        // Process only the top 5 results
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

        // Combine all scraped content
        final combinedContent = scrapedContents.join(' ');

        // Generate summary from combined content
        final summary =
            await _groqApiService.summarizeContent(combinedContent, query);

        setState(() {
          _isLoading = false;
        });

        // Open ThreadScreen
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ThreadScreen(
              query: query,
              searchResults: processedResults,
              summary: summary,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      } else {
        _showErrorDialog('Failed to perform search. Please try again.');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorDialog(
          'An error occurred. Please check your internet connection and try again.');
      setState(() {
        _isLoading = false;
      });
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
