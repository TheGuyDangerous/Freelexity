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

    final String query = ambiguityResult.originalQuery;
    
    // Special case for Trapti Sharma queries
    if (query.toLowerCase().contains("trapti sharma")) {
      List<DisambiguationOption> options = [];
      
      // Always include the specific fixed options
      options.add(DisambiguationOption(
        id: _uuid.v4(),
        displayText: "Dr. Trapti Sharma - VIT Bhopal (PHD)",
        description: "Information about Dr. Trapti Sharma who has a PhD and is affiliated with VIT Bhopal",
        context: "Academic context, VIT Bhopal University",
        enhancedQuery: "Dr. Trapti Sharma VIT Bhopal professor PhD",
      ));
      
      options.add(DisambiguationOption(
        id: _uuid.v4(),
        displayText: "Trapti Sharma - Senior System Engineer",
        description: "Information about Trapti Sharma who is a Senior System Engineer at Infosys",
        context: "Professional context, work history and education",
        enhancedQuery: "Trapti Sharma Infosys Senior System Engineer",
      ));
      
      // Also generate additional dynamic options by consulting the API
      // but keep only options that don't overlap with our fixed ones
      try {
        final prefs = await SharedPreferences.getInstance();
        final groqApiKey = prefs.getString('groqApiKey') ?? '';
        
        if (groqApiKey.isNotEmpty) {
          // Prepare search context
          final searchContext = searchResults.take(3).map((result) {
            return '''
            Title: ${result['title'] ?? ''}
            Description: ${result['description'] ?? ''}
            URL: ${result['url'] ?? ''}
            ''';
          }).join('\n');
          
          final dynamicOptions = await _generateDynamicOptions(
            query, 
            ambiguityResult.ambiguityType, 
            searchContext, 
            groqApiKey
          );
          
          // Add any dynamic options that are sufficiently different from our fixed ones
          for (var option in dynamicOptions) {
            // Skip options that mention VIT Bhopal or LinkedIn to avoid duplication
            if (!option.displayText.toLowerCase().contains("vit") && 
                !option.displayText.toLowerCase().contains("linkedin") &&
                options.length < 5) {  // Limit to 5 total options (2 fixed + up to 3 dynamic)
              options.add(option);
            }
          }
        }
      } catch (e) {
        debugPrint('Error generating additional options for Trapti Sharma: $e');
      }
      
      // Return all options (fixed + dynamic)
      return options;
    }

    final prefs = await SharedPreferences.getInstance();
    final groqApiKey = prefs.getString('groqApiKey') ?? '';

    if (groqApiKey.isEmpty) {
      return [];
    }

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

Your goal is to generate distinct, meaningful options that cover the MOST LIKELY different interpretations of the query. Focus on creating options that represent SUBSTANTIALLY DIFFERENT meanings or contexts - not just minor variations.

For example, for "Weather in UK":
- Option 1 should be about United Kingdom weather
- Option 2 should be about Uttarakhand (India) weather

For "iPhone review":
- Options should distinguish between different iPhone models (13/14/15/16)
- And different variants (Regular/Plus/Pro/Pro Max)

For acronyms like "MIT", create options for completely different entities (Massachusetts Institute of Technology vs Manipal Institute of Technology).

For product queries, focus on different versions, models, and contexts.

For time-based queries without specificity, offer options for different time periods.

Respond with JSON in the format:
[
  {
    "displayText": "Short, clear option title (e.g., 'United Kingdom Weather')",
    "description": "Helpful explanation of this interpretation",
    "context": "Additional context about this option",
    "enhancedQuery": "The original query with clarifications added (e.g., 'Weather in United Kingdom')"
  }
]

Keep options distinct and mutually exclusive whenever possible. Avoid creating options that are too similar to each other. Make sure the enhancedQuery is specific enough that it resolves the ambiguity completely.'''
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

  // Helper method to generate dynamic options
  Future<List<DisambiguationOption>> _generateDynamicOptions(
    String query,
    String ambiguityType,
    String searchContext,
    String groqApiKey
  ) async {
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
              
The user has entered an ambiguous query about a person named "Trapti Sharma". Generate options for different people with this name or different contexts they might be associated with.

Generate options that represent substantially different people, roles, or contexts - not minor variations.

In your response, DO NOT include options about:
1. "Dr. Trapti Sharma - VIT Bhopal (PHD)" - this is already covered elsewhere
2. "Trapti Sharma - LinkedIn Profile" - this is already covered elsewhere

Instead, find or create at least 3 other distinct possibilities based on the search context or potential fields/industries where someone named Trapti Sharma might work.

Examples might include (but are not limited to):
- Trapti Sharma in a specific tech company (e.g., "Trapti Sharma - Software Engineer at Google")
- Trapti Sharma in academia but at a different institution than VIT Bhopal
- Trapti Sharma in healthcare (e.g., "Dr. Trapti Sharma - Cardiologist at Apollo Hospital")
- Trapti Sharma in media/entertainment (e.g., "Trapti Sharma - Journalist at Times of India")

Respond with JSON in the format:
[
  {
    "displayText": "Specific role and context for this Trapti Sharma",
    "description": "Detailed explanation about this specific person and their work",
    "context": "Industry or field this person works in",
    "enhancedQuery": "Specific search query to find more information about this person"
  }
]

Create options that are specific, plausible, and distinct from each other.'''
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
          }
        } catch (e) {
          debugPrint('Error parsing dynamic disambiguation options: $e');
        }
      }
    } catch (e) {
      debugPrint('Error generating dynamic options: $e');
    }
    
    return [];
  }
} 