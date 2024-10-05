import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/web_scraper_service.dart';
import '../services/groq_api_service.dart';
import '../screens/thread_screen.dart';

class SearchService {
  final WebScraperService _webScraperService = WebScraperService();
  final GroqApiService _groqApiService = GroqApiService();
  int _retryCount = 0;
  static const int _maxRetries = 3;

  Future<void> performSearch(BuildContext context, String query) async {
    final prefs = await SharedPreferences.getInstance();
    final braveApiKey = prefs.getString('braveApiKey') ?? '';

    if (braveApiKey.isEmpty) {
      _showErrorDialog(
          context, 'Please enter your Brave Search API key in settings.');
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
        return performSearch(context, query);
      } else {
        _showErrorDialog(
            context, 'Failed to perform search. Please try again.');
        Navigator.of(context).pop(); // Remove ThreadLoadingScreen
      }
    } catch (e) {
      if (_retryCount < _maxRetries) {
        _retryCount++;
        await Future.delayed(Duration(seconds: pow(2, _retryCount).toInt()));
        return performSearch(context, query);
      } else {
        _showErrorDialog(context,
            'An error occurred. Please check your internet connection and try again.');
        Navigator.of(context).pop(); // Remove ThreadLoadingScreen
      }
    } finally {
      _retryCount = 0;
    }
  }

  String _preprocessContent(String content) {
    return content
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .substring(0, min(1000, content.length));
  }

  void _showErrorDialog(BuildContext context, String message) {
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
