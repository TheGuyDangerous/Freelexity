import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class WebScraperService {
  Future<String> scrapeContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = parse(response.body);
        return _extractMainContent(document);
      } else {
        throw Exception('Failed to load page');
      }
    } catch (e) {
      throw Exception('Error scraping content: $e');
    }
  }

  String _extractMainContent(Document document) {
    // This is a basic implementation. You might need to adjust it based on the structure of the websites you're scraping.
    final body = document.body;
    if (body == null) return '';

    // Remove script and style elements
    body
        .querySelectorAll('script, style')
        .forEach((element) => element.remove());

    // Try to find main content (this might need to be adjusted based on common website structures)
    final mainContent = body.querySelector('main') ??
        body.querySelector('article') ??
        body.querySelector('#content') ??
        body;

    return mainContent.text;
  }
}
