import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class IncognitoMessage extends StatelessWidget {
  const IncognitoMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.shield_tick,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'Incognito Mode Active',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your search history is not being saved',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
