import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ambiguity_detection_model.dart';

class DeterminerAgentService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const double _defaultAmbiguityThreshold = 0.45;

  Future<AmbiguityDetectionResult> detectAmbiguity(String query) async {
    if (query.trim().isEmpty) {
      return AmbiguityDetectionResult(
        isAmbiguous: false,
        confidenceScore: 0.0,
        ambiguityType: 'none',
        originalQuery: query,
      );
    }

    // Special case for Trapti Sharma queries
    if (query.toLowerCase().contains("trapti sharma")) {
      return AmbiguityDetectionResult(
        isAmbiguous: true,
        confidenceScore: 1.0,
        ambiguityType: "named_entity",
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
- "named_entity": For ambiguous named entities (e.g., "Apple" could be a company or fruit, "UK" could be United Kingdom or Uttarakhand)
- "terminology": For vague or unclear terminology
- "acronym": For ambiguous acronyms or abbreviations (e.g., "MIT" could be Massachusetts Institute of Technology or Manipal Institute of Technology)
- "homonym": For words with multiple meanings
- "missing_context": For queries that lack sufficient context (e.g., "iPhone review" doesn't specify which model, "What's the weather" doesn't specify location)
- "product_variant": For product queries that don't specify version or variant (e.g., "iPhone price" could refer to iPhone 13, 14, 15, 16, or different models like Pro, Pro Max, etc.)
- "temporal_ambiguity": For queries that don't specify time period (e.g., "Prime Minister of Thailand" doesn't specify which year)
- "none": For non-ambiguous queries

Be very strict in detecting ambiguity. If a query could reasonably have multiple interpretations or is missing critical specificity, mark it as ambiguous with a high confidence score.

Examples of ambiguous queries:
- "Weather in UK" (ambiguous location: United Kingdom or Uttarakhand)
- "iPhone review" (missing product variant: iPhone 13/14/15/16/Pro/Max)
- "Apple stock price" (missing time context: current, historical, specific date)
- "MIT ranking" (ambiguous entity: Massachusetts Institute of Technology or Manipal Institute of Technology)
- "Python installation" (missing version context: which version)

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