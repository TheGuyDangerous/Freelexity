import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GroqApiService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<String> summarizeContent(String content, String userQuery) async {
    final prefs = await SharedPreferences.getInstance();
    final groqApiKey = prefs.getString('groqApiKey') ?? '';

    if (groqApiKey.isEmpty) {
      print('Groq API key is not set');
      return 'Groq API key is not set. Please add it in the settings.';
    }

    try {
      print('Sending request to Groq API...');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey',
        },
        body: jsonEncode({
          'model': 'mixtral-8x7b-32768',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Summarize the following content concisely, focusing on the user query.'
            },
            {'role': 'user', 'content': 'Query: $userQuery\nContent: $content'},
          ],
          'max_tokens': 1000,
          'temperature': 0.2,
        }),
      );

      print('Groq API response status code: ${response.statusCode}');
      print('Groq API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ??
            'Summary not found in response';
      } else if (response.statusCode == 429) {
        return 'Rate limit exceeded. Please try again later.';
      } else {
        return 'Failed to summarize content: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('Error summarizing content: $e');
      return 'Error summarizing content: $e';
    }
  }
}
