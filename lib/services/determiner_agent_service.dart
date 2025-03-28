import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ambiguity_detection_model.dart';

class DeterminerAgentService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const double _defaultAmbiguityThreshold = 0.6;

  Future<AmbiguityDetectionResult> detectAmbiguity(String query) async {
    if (query.trim().isEmpty) {
      return AmbiguityDetectionResult(
        isAmbiguous: false,
        confidenceScore: 0.0,
        ambiguityType: 'none',
        originalQuery: query,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final groqApiKey = prefs.getString('groqApiKey') ?? '';
    final ambiguityThreshold = prefs.getDouble('ambiguityThreshold') ?? _defaultAmbiguityThreshold;
    final enableAmbiguityDetection = prefs.getBool('enableAmbiguityDetection') ?? true;

    // Skip ambiguity detection if disabled in settings
    if (!enableAmbiguityDetection) {
      return AmbiguityDetectionResult(
        isAmbiguous: false,
        confidenceScore: 0.0,
        ambiguityType: 'disabled',
        originalQuery: query,
      );
    }

    if (groqApiKey.isEmpty) {
      return AmbiguityDetectionResult(
        isAmbiguous: false,
        confidenceScore: 0.0,
        ambiguityType: 'api_key_missing',
        originalQuery: query,
      );
    }

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
              'content': '''You are an Ambiguity Determiner Agent. Your task is to analyze a user query and determine if it is ambiguous. 
              Respond with JSON only in the format: {"isAmbiguous": boolean, "confidenceScore": float, "ambiguityType": string}
              
              Ambiguity types:
              - "named_entity": For ambiguous named entities (e.g., "Apple" could be a company or fruit)
              - "terminology": For vague or unclear terminology
              - "acronym": For ambiguous acronyms or abbreviations
              - "homonym": For words with multiple meanings
              - "missing_context": For queries that lack sufficient context
              - "none": For non-ambiguous queries
              
              The confidence score should range from 0.0 to 1.0, where 1.0 means completely ambiguous.'''
            },
            {'role': 'user', 'content': query},
          ],
          'max_tokens': 100,
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        try {
          final jsonResponse = jsonDecode(aiResponse);
          
          final bool isAmbiguous = jsonResponse['isAmbiguous'] ?? false;
          final double confidenceScore = jsonResponse['confidenceScore'] is int 
              ? (jsonResponse['confidenceScore'] as int).toDouble() 
              : jsonResponse['confidenceScore'] ?? 0.0;
          final String ambiguityType = jsonResponse['ambiguityType'] ?? 'none';
          
          // Apply threshold check
          final bool exceedsThreshold = confidenceScore >= ambiguityThreshold;
          
          return AmbiguityDetectionResult(
            isAmbiguous: isAmbiguous && exceedsThreshold,
            confidenceScore: confidenceScore,
            ambiguityType: ambiguityType,
            originalQuery: query,
          );
        } catch (e) {
          debugPrint('Error parsing AI response: $e');
          debugPrint('Response was: $aiResponse');
          return AmbiguityDetectionResult(
            isAmbiguous: false,
            confidenceScore: 0.0,
            ambiguityType: 'parsing_error',
            originalQuery: query,
          );
        }
      } else {
        debugPrint('API call failed with status code: ${response.statusCode}');
        return AmbiguityDetectionResult(
          isAmbiguous: false,
          confidenceScore: 0.0,
          ambiguityType: 'api_error',
          originalQuery: query,
        );
      }
    } catch (e) {
      debugPrint('Error in ambiguity detection: $e');
      return AmbiguityDetectionResult(
        isAmbiguous: false,
        confidenceScore: 0.0,
        ambiguityType: 'service_error',
        originalQuery: query,
      );
    }
  }
} 