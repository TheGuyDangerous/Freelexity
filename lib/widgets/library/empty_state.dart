import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.clock,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'Your search history will appear here',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
