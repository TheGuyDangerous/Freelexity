import '../models/disambiguation_option_model.dart';

class QueryEnhancementService {
  String enhanceQuery(String originalQuery, DisambiguationOption selectedOption) {
    // If the enhanced query is empty or the same as the original, use fallback logic
    if (selectedOption.enhancedQuery.isEmpty || 
        selectedOption.enhancedQuery == originalQuery) {
      return _fallbackEnhancement(originalQuery, selectedOption);
    }
    
    return selectedOption.enhancedQuery;
  }
  
  String _fallbackEnhancement(String originalQuery, DisambiguationOption option) {
    final String context = option.context.trim();
    
    // If context is empty, simply append the display text
    if (context.isEmpty) {
      return '$originalQuery ${option.displayText}';
    }
    
    // Extract keywords from context
    final List<String> keywords = _extractKeywords(context);
    
    // Add most relevant keywords to the query
    if (keywords.isEmpty) {
      return '$originalQuery ${option.displayText}';
    } else {
      final topKeywords = keywords.take(3).join(' ');
      return '$originalQuery $topKeywords';
    }
  }
  
  List<String> _extractKeywords(String context) {
    // Replace punctuation with spaces first
    String cleanedText = context
        .replaceAll(',', ' ')
        .replaceAll('.', ' ')
        .replaceAll(';', ' ')
        .replaceAll(':', ' ')
        .replaceAll('!', ' ')
        .replaceAll('?', ' ')
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .replaceAll('{', ' ')
        .replaceAll('}', ' ')
        .replaceAll('[', ' ')
        .replaceAll(']', ' ')
        .replaceAll('<', ' ')
        .replaceAll('>', ' ')
        .replaceAll('"', ' ')
        .replaceAll("'", ' ');
    
    // Split by whitespace
    final List<String> allWords = cleanedText.split(' ');
    
    // Filter and process words
    final List<String> filteredWords = [];
    for (final word in allWords) {
      final String trimmedWord = word.trim();
      if (trimmedWord.isNotEmpty) {
        final String lowerWord = trimmedWord.toLowerCase();
        if (lowerWord.length > 3 && !_stopWords.contains(lowerWord)) {
          filteredWords.add(lowerWord);
        }
      }
    }
    
    // Count word frequency
    final Map<String, int> wordCounts = {};
    for (final word in filteredWords) {
      wordCounts[word] = (wordCounts[word] ?? 0) + 1;
    }
    
    // Sort by frequency
    final List<String> sortedWords = wordCounts.keys.toList();
    sortedWords.sort((a, b) => wordCounts[b]! - wordCounts[a]!);
    
    return sortedWords;
  }
  
  // Common English stop words
  static const Set<String> _stopWords = {
    'the', 'and', 'for', 'with', 'that', 'this', 'are', 'was', 'were', 'have', 'has',
    'had', 'not', 'but', 'what', 'when', 'where', 'how', 'who', 'which', 'from', 'they',
    'them', 'their', 'there', 'here', 'about', 'into', 'over', 'after', 'before', 'between',
  };
}