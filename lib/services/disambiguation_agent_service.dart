import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/disambiguation_option_model.dart';
import '../models/ambiguity_detection_model.dart';

class DisambiguationAgentService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const int _maxOptions = 5;
  final _uuid = Uuid();

  Future<List<DisambiguationOption>> generateOptions(
      AmbiguityDetectionResult ambiguityResult, List<Map<String, dynamic>> searchResults) async {
    if (!ambiguityResult.isAmbiguous) {
      return [];
    }

    final prefs = await SharedPreferences.getInstance();
    final groqApiKey = prefs.getString('groqApiKey') ?? '';

    if (groqApiKey.isEmpty) {
      return [];
    }

    final String query = ambiguityResult.originalQuery;
    final String ambiguityType = ambiguityResult.ambiguityType;
    
    // Prepare context from search results
    final searchContext = searchResults.take(3).map((result) {
      return '''
      Title: ${result['title'] ?? ''}
      Description: ${result['description'] ?? ''}
      URL: ${result['url'] ?? ''}
      ''';
    }).join('\n');

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a Disambiguation Agent. Your task is to generate options to disambiguate an ambiguous query.
              
              The user has entered an ambiguous query of type: "$ambiguityType"
              
              Analyze the search results context and generate 2-$_maxOptions distinct possible interpretations of what the user might be looking for.
              
              Respond with JSON in the format:
              [
                {
                  "displayText": "short display text",
                  "description": "more detailed explanation",
                  "context": "which context this applies to",
                  "enhancedQuery": "modified query with clarifications"
                }
              ]
              
              Make the options distinct and cover different possible interpretations.
              For enhancedQuery, expand the original query with clarifying terms based on the context.'''
            },
            {
              'role': 'user',
              'content': '''Query: $query
              
              Search Context:
              $searchContext'''
            },
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        try {
          // Extract JSON array from response
          final String jsonContent = aiResponse.trim();
          final jsonResponse = jsonDecode(jsonContent);
          
          if (jsonResponse is List) {
            return jsonResponse.map<DisambiguationOption>((option) {
              return DisambiguationOption(
                id: _uuid.v4(),
                displayText: option['displayText'] ?? 'Unknown option',
                description: option['description'] ?? '',
                context: option['context'] ?? '',
                enhancedQuery: option['enhancedQuery'] ?? query,
              );
            }).toList();
          } else {
            debugPrint('Invalid response format: $jsonResponse');
            return [];
          }
        } catch (e) {
          debugPrint('Error parsing disambiguation options: $e');
          debugPrint('Response was: $aiResponse');
          return [];
        }
      } else {
        debugPrint('API call failed with status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error generating disambiguation options: $e');
      return [];
    }
  }
} 