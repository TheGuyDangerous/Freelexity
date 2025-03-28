import 'package:flutter/material.dart';

class DisambiguationInfoWidget extends StatelessWidget {
  final Map<String, dynamic> disambiguationInfo;
  
  const DisambiguationInfoWidget({
    super.key,
    required this.disambiguationInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Skip if not disambiguated
    if (!disambiguationInfo.containsKey('wasDisambiguated') || 
        disambiguationInfo['wasDisambiguated'] != true) {
      return SizedBox.shrink();
    }
    
    final String originalQuery = disambiguationInfo['originalQuery'] ?? '';
    final String ambiguityType = disambiguationInfo['ambiguityType'] ?? 'unknown';
    
    String ambiguityTypeDisplay = '';
    IconData ambiguityIcon = Icons.help_outline;
    
    switch (ambiguityType) {
      case 'named_entity':
        ambiguityTypeDisplay = 'Name Ambiguity';
        ambiguityIcon = Icons.person_outline;
        break;
      case 'terminology':
        ambiguityTypeDisplay = 'Vague Terminology';
        ambiguityIcon = Icons.text_fields;
        break;
      case 'acronym':
        ambiguityTypeDisplay = 'Ambiguous Acronym';
        ambiguityIcon = Icons.short_text;
        break;
      case 'homonym':
        ambiguityTypeDisplay = 'Multiple Meanings';
        ambiguityIcon = Icons.double_arrow;
        break;
      case 'missing_context':
        ambiguityTypeDisplay = 'Missing Context';
        ambiguityIcon = Icons.visibility_off;
        break;
      default:
        ambiguityTypeDisplay = 'Query Clarified';
        ambiguityIcon = Icons.help_outline;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            ambiguityIcon,
            color: theme.colorScheme.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ambiguityTypeDisplay,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                if (originalQuery.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Original query: "$originalQuery"',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
} 