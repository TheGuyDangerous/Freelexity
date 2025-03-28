import 'package:flutter/material.dart';
import '../../models/disambiguation_option_model.dart';
import '../../models/ambiguity_detection_model.dart';

class AmbiguityResolutionWidget extends StatelessWidget {
  final AmbiguityDetectionResult ambiguityResult;
  final List<DisambiguationOption> options;
  final Function(DisambiguationOption) onOptionSelected;
  final VoidCallback onContinueWithOriginal;

  const AmbiguityResolutionWidget({
    super.key,
    required this.ambiguityResult,
    required this.options,
    required this.onOptionSelected,
    required this.onContinueWithOriginal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your query could have multiple meanings',
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Did you mean:',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          ...options.map((option) => _buildOptionTile(context, option)),
          const SizedBox(height: 16),
          InkWell(
            onTap: onContinueWithOriginal,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Continue with original search',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, DisambiguationOption option) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => onOptionSelected(option),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option.displayText,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (option.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                option.description,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 