import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/web_scraper_service.dart';
import '../services/groq_api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _summary = '';
  final WebScraperService _webScraperService = WebScraperService();
  final GroqApiService _groqApiService = GroqApiService();

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _summary = '';
    });

    final prefs = await SharedPreferences.getInstance();
    final braveApiKey = prefs.getString('braveApiKey') ?? '';

    if (braveApiKey.isEmpty) {
      _showErrorDialog('Please enter your Brave Search API key in settings.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final query = _searchController.text;
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
        for (var i = 0; i < min(5, results.length); i++) {
          var result = results[i];
          try {
            final scrapedContent =
                await _webScraperService.scrapeContent(result['url']);
            result['scrapedContent'] = scrapedContent;
            scrapedContents.add(_preprocessContent(scrapedContent));
          } catch (e) {
            print('Error processing content for ${result['url']}: $e');
            result['scrapedContent'] = 'Unable to process content: $e';
          }
        }

        // Combine all scraped content
        final combinedContent = scrapedContents.join(' ');

        // Generate summary from combined content
        final summary =
            await _groqApiService.summarizeContent(combinedContent, query);

        setState(() {
          _searchResults = results;
          _summary = summary;
          _isLoading = false;
        });
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
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Enter your search query',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _performSearch,
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    if (_summary.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_summary),
                      ),
                      const Divider(),
                    ],
                    ..._searchResults.map((result) => ListTile(
                          title: Text(result['title'] ?? ''),
                          subtitle: Text(result['description'] ?? ''),
                          onTap: () => _launchURL(result['url']),
                        )),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}
