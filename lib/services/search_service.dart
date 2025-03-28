import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/web_scraper_service.dart';
import '../services/groq_api_service.dart';
import '../services/google_search_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchService {
  final WebScraperService _webScraperService = WebScraperService();
  final GroqApiService _groqApiService = GroqApiService();
  final GoogleSearchService _googleSearchService = GoogleSearchService();
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // New method to get basic search results without full processing
  // Used for disambiguation purposes
  Future<List<Map<String, dynamic>>> getBasicSearchResults(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final prefs = await SharedPreferences.getInstance();
    final useGoogleSearch = prefs.getBool('useGoogleSearch') ?? false;
    final braveApiKey = prefs.getString('braveApiKey') ?? '';

    if (!useGoogleSearch && braveApiKey.isEmpty) {
      return [];
    }

    try {
      if (useGoogleSearch) {
        try {
          return await _googleSearchService.search(query);
        } catch (e) {
          debugPrint('Error getting basic search results: $e');
          return [];
        }
      } else {
        final url = Uri.parse(
            'https://api.search.brave.com/res/v1/web/search?q=$query');
        final response = await http.get(
          url,
          headers: {'X-Subscription-Token': braveApiKey},
        );

        if (response.statusCode != 200) {
          return [];
        }

        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['web']['results']);
      }
    } catch (e) {
      debugPrint('Error getting basic search results: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> performSearch(
      BuildContext context, String query) async {
    if (query.trim().isEmpty) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final useGoogleSearch = prefs.getBool('useGoogleSearch') ?? false;
    final braveApiKey = prefs.getString('braveApiKey') ?? '';

    if (!useGoogleSearch && braveApiKey.isEmpty) {
      _showErrorToast(
          'Please enter your API keys first or enable Google Search in settings.');
      return null;
    }

    try {
      List<Map<String, dynamic>> searchResults;

      if (useGoogleSearch) {
        try {
          searchResults = await _googleSearchService.search(query);
        } catch (e) {
          if (context.mounted) {
            _handleApiError(context,
                'Failed to perform Google search. Please try again later.');
          }
          return null;
        }
      } else {
        final url = Uri.parse(
            'https://api.search.brave.com/res/v1/web/search?q=$query');
        final response = await http.get(
          url,
          headers: {'X-Subscription-Token': braveApiKey},
        );

        if (response.statusCode != 200) {
          if (response.statusCode == 429 && _retryCount < _maxRetries) {
            _retryCount++;
            await Future.delayed(
                Duration(seconds: pow(2, _retryCount).toInt()));
            if (!context.mounted) return null;
            return performSearch(context, query);
          }
          if (context.mounted) {
            _handleApiError(
                context, 'Failed to perform search. Please try again.');
          }
          return null;
        }

        final data = json.decode(response.body);
        searchResults = List<Map<String, dynamic>>.from(data['web']['results']);
      }

      final processedResults = await Future.wait(
        searchResults.take(5).map((result) async {
          try {
            final scrapedContent =
                await _webScraperService.scrapeContent(result['url']);
            result['scrapedContent'] = _preprocessContent(scrapedContent);
            return result;
          } catch (e) {
            debugPrint('Error processing content for ${result['url']}: $e');
            return result;
          }
        }),
      );

      final combinedContent = processedResults
          .map((result) => result['scrapedContent'] ?? '')
          .join(' ');

      final summary =
          await _groqApiService.summarizeContent(combinedContent, query);

      return {
        'query': query,
        'searchResults': processedResults,
        'summary': summary,
      };
    } catch (e) {
      if (context.mounted) {
        _handleApiError(context,
            'An error occurred. Please check your internet connection and try again.');
      }
      return null;
    }
  }

  String _preprocessContent(String content) {
    final trimmedContent = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    final maxLength = trimmedContent.length < 500 ? trimmedContent.length : 500;
    return trimmedContent.substring(0, maxLength);
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _handleApiError(BuildContext context, String message) {
    Navigator.of(context).pop(); // Remove loading screen
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Future<bool> validateBraveApiKey(String apiKey) async {
    final url =
        Uri.parse('https://api.search.brave.com/res/v1/web/search?q=test');
    try {
      final response = await http.get(
        url,
        headers: {'X-Subscription-Token': apiKey},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error validating Brave API key: $e');
      return false;
    }
  }
}
