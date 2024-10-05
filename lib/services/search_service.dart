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
      Navigator.of(context).pop();
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

        // Limit to top 5 results and process them in parallel
        final processedResults = await Future.wait(
          results.take(5).map((result) async {
            try {
              final scrapedContent =
                  await _webScraperService.scrapeContent(result['url']);
              result['scrapedContent'] = _preprocessContent(scrapedContent);
              return result;
            } catch (e) {
              print('Error processing content for ${result['url']}: $e');
              return result;
            }
          }),
        );

        final combinedContent = processedResults
            .map((result) => result['scrapedContent'] ?? '')
            .join(' ');

        final summary =
            await _groqApiService.summarizeContent(combinedContent, query);

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
        _retryCount++;
        await Future.delayed(Duration(seconds: pow(2, _retryCount).toInt()));
        return performSearch(context, query);
      } else {
        _showErrorDialog(
            context, 'Failed to perform search. Please try again.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (_retryCount < _maxRetries) {
        _retryCount++;
        await Future.delayed(Duration(seconds: pow(2, _retryCount).toInt()));
        return performSearch(context, query);
      } else {
        _showErrorDialog(context,
            'An error occurred. Please check your internet connection and try again.');
        Navigator.of(context).pop();
      }
    } finally {
      _retryCount = 0;
    }
  }

  String _preprocessContent(String content) {
    return content
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .substring(0, min(500, content.length)); // Reduced to 500 characters
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
