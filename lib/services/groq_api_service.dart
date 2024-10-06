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
      throw Exception(
          'Groq API key is not set. Please add it in the settings.');
    }

    try {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ??
            'Summary not found in response';
      } else if (response.statusCode == 401) {
        throw Exception(
            'Invalid API key. Please check your Groq API key in the settings.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception(
            'Failed to summarize content: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error summarizing content: $e');
    }
  }

  Future<bool> validateApiKey(String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'mixtral-8x7b-32768',
          'messages': [
            {'role': 'user', 'content': 'Hello'}
          ],
          'max_tokens': 5,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
