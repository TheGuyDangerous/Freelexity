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
        return 'Failed to load page: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error scraping content: $e';
    }
  }

  String _extractMainContent(Document document) {
    final body = document.body;
    if (body == null) return 'No content found';

    body
        .querySelectorAll('script, style, nav, footer, header')
        .forEach((element) => element.remove());

    final mainContent = body.querySelector('main') ??
        body.querySelector('article') ??
        body.querySelector('#content') ??
        body;

    final paragraphs = mainContent.querySelectorAll('p');
    if (paragraphs.isNotEmpty) {
      return paragraphs.map((p) => p.text).join('\n\n');
    }

    return mainContent.text.trim();
  }
}
