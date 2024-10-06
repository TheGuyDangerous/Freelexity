import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WhisperService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/audio/transcriptions';

  Future<String> transcribeAudio(List<int> audioBytes) async {
    final prefs = await SharedPreferences.getInstance();
    final groqApiKey = prefs.getString('groqApiKey') ?? '';

    if (groqApiKey.isEmpty) {
      throw Exception('Groq API key is not set');
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $groqApiKey',
      });

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        audioBytes,
        filename: 'audio.m4a',
      ));

      request.fields['model'] = 'whisper-large-v3';
      request.fields['response_format'] = 'json';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['text'] ?? '';
      } else {
        throw Exception(
            'Failed to transcribe audio: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Error transcribing audio: $e');
    }
  }
}
