import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'dart:math';
import 'package:flutter/material.dart';

class GoogleSearchService {
  static const String _baseUrl = 'https://www.google.com/search';
  static const int _maxRetries = 3;
  static const Duration _minDelayBetweenRequests = Duration(seconds: 2);
  DateTime? _lastRequestTime;

  final List<String> _userAgents = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/122.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15',
  ];

  String _getRandomUserAgent() {
    final random = Random();
    return _userAgents[random.nextInt(_userAgents.length)];
  }

  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minDelayBetweenRequests) {
        await Future.delayed(_minDelayBetweenRequests - timeSinceLastRequest);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  Future<List<Map<String, String?>>> searchImages(String query,
      {int maxResults = 5}) async {
    debugPrint('Starting image search for query: $query');
    await _enforceRateLimit();
    final url = Uri.parse('$_baseUrl?q=${Uri.encodeComponent(query)}&tbm=isch');
    debugPrint('Image search URL: $url');

    try {
      final response = await _makeRequest(url);
      debugPrint('Got response from Google Images. Length: ${response.length}');
      final document = parse(response);
      final imageResults = <Map<String, String?>>[];

      // Try multiple selectors to find image containers
      final imageContainers = document.querySelectorAll(
          'div.isv-r, div.eA0Zlc, div[jscontroller="Um3BXb"], div.F0uyec');
      debugPrint('Found ${imageContainers.length} image containers');

      for (var container in imageContainers) {
        try {
          // Extract image URL from data attributes or img tags
          String? imageUrl;

          // Try multiple selectors for image elements
          final imgElement = container.querySelector(
              'img.rg_i, img.YQ4gaf, img[jsname="Q4LuWd"], img.mNsIhb');

          if (imgElement != null) {
            imageUrl = imgElement.attributes['src'] ??
                imgElement.attributes['data-src'] ??
                imgElement.attributes['data-iurl'];

            // If still no URL found, try data-src attribute
            if (imageUrl == null || imageUrl.startsWith('data:')) {
              imageUrl = imgElement.attributes['data-iurl'] ??
                  imgElement.attributes['data-src'];
            }
          }

          // Try alternate method if image URL not found
          if (imageUrl == null) {
            final aElement = container.querySelector('a');
            if (aElement != null) {
              final onclickAttr = aElement.attributes['onclick'] ?? '';
              final urlMatch =
                  RegExp(r'imgurl=([^&]+)').firstMatch(onclickAttr);
              if (urlMatch != null) {
                imageUrl = Uri.decodeComponent(urlMatch.group(1)!);
              }
            }
          }

          debugPrint('Found image URL: $imageUrl');

          if (imageUrl != null &&
              !imageUrl.contains('gstatic.com') &&
              !imageUrl.contains('favicon')) {
            // Extract website name from URL
            String websiteName;
            try {
              final uri = Uri.parse(imageUrl);
              websiteName = uri.host.replaceFirst('www.', '');
              // Get the domain without subdomain
              final parts = websiteName.split('.');
              if (parts.length > 2) {
                websiteName = parts.sublist(parts.length - 2).join('.');
              }
            } catch (e) {
              debugPrint('Error extracting website name: $e');
              websiteName = 'Unknown';
            }

            final imageData = {
              'url': imageUrl,
              'websiteName': websiteName,
              'favicon':
                  'https://www.google.com/s2/favicons?domain=$websiteName&sz=64',
            };
            debugPrint('Adding image data: $imageData');
            imageResults.add(imageData);

            if (imageResults.length >= maxResults) {
              debugPrint('Reached maximum results ($maxResults)');
              break;
            }
          }
        } catch (e) {
          debugPrint('Error processing image container: $e');
          continue;
        }
      }

      debugPrint('Final image results count: ${imageResults.length}');
      return imageResults;
    } catch (e) {
      debugPrint('Error fetching images: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> search(String query,
      {int maxResults = 5}) async {
    debugPrint('Starting web search for query: $query');
    await _enforceRateLimit();
    final searchResults = <Map<String, dynamic>>[];
    int currentPage = 0;
    int resultsFound = 0;

    while (resultsFound < maxResults && currentPage < 2) {
      final start = currentPage * 10;
      final url = Uri.parse(
          '$_baseUrl?q=${Uri.encodeComponent(query)}&start=$start&num=10');
      debugPrint('Searching page $currentPage, URL: $url');

      try {
        final response = await _makeRequest(url);
        final document = parse(response);

        final results = document.querySelectorAll('div.g');
        debugPrint(
            'Found ${results.length} search results on page $currentPage');

        for (var result in results) {
          if (resultsFound >= maxResults) break;

          final searchResult = _extractSearchResult(result);
          if (searchResult != null) {
            searchResults.add(searchResult);
            resultsFound++;
          }
        }

        final nextButton = document.querySelector('a#pnnext');
        if (nextButton == null) {
          debugPrint('No next page button found');
          break;
        }

        currentPage++;
        await _enforceRateLimit();
      } catch (e) {
        debugPrint('Error on page $currentPage: $e');
        break;
      }
    }

    // Fetch images and add them to the first search result
    try {
      debugPrint('Fetching images for search results');
      final imageResults = await searchImages(query);
      debugPrint('Got ${imageResults.length} image results');

      if (searchResults.isNotEmpty && imageResults.isNotEmpty) {
        searchResults.first['images'] = imageResults;
        debugPrint(
            'Added ${imageResults.length} images to first search result');
      } else {
        debugPrint(
            'Could not add images: searchResults.isEmpty=${searchResults.isEmpty}, imageResults.isEmpty=${imageResults.isEmpty}');
      }
    } catch (e) {
      debugPrint('Error adding images to search results: $e');
    }

    return searchResults;
  }

  Future<String> _makeRequest(Uri url) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        final response = await http.get(
          url,
          headers: {
            'User-Agent': _getRandomUserAgent(),
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'none',
            'Sec-Fetch-User': '?1',
            'Cache-Control': 'max-age=0',
          },
        );

        if (response.statusCode == 200) {
          return response.body;
        } else if (response.statusCode == 429 || response.statusCode == 403) {
          retryCount++;
          await Future.delayed(Duration(seconds: pow(2, retryCount).toInt()));
          continue;
        } else {
          throw Exception('Failed to perform search: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= _maxRetries) {
          throw Exception(
              'Failed to perform search after $_maxRetries retries: $e');
        }
        await Future.delayed(Duration(seconds: pow(2, retryCount).toInt()));
      }
    }
    throw Exception('Failed to perform search after $_maxRetries retries');
  }

  Map<String, dynamic>? _extractSearchResult(var result) {
    final titleElement = result.querySelector('h3');
    final linkElement = result.querySelector('a');
    final snippetElement = result.querySelector('div.VwiC3b');
    final dateElement = result.querySelector('span.MUxGbd.wuQ4Ob.WZ8Tjf');

    if (titleElement != null && linkElement != null) {
      final href = linkElement.attributes['href'];
      if (href != null && href.startsWith('http')) {
        final url = href.split('&sa=')[0];
        final domain = Uri.parse(url).host.replaceFirst('www.', '');
        final date = dateElement?.text ?? '';

        return {
          'title': titleElement.text,
          'url': url,
          'description': snippetElement?.text ?? '',
          'meta': {
            'title': titleElement.text,
            'description': snippetElement?.text ?? '',
            'date': date,
          },
          'favicon': 'https://www.google.com/s2/favicons?domain=$domain&sz=64',
          'language': 'en',
          'family_friendly': true,
        };
      }
    }
    return null;
  }
}
