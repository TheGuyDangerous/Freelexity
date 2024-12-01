import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SummaryCard extends StatelessWidget {
  final String summary;
  final Function(String) onSpeakPressed;
  final bool isSpeaking;

  const SummaryCard({
    super.key,
    required this.summary,
    required this.onSpeakPressed,
    required this.isSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.magic_star,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Answer',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    isSpeaking ? Iconsax.volume_slash : Iconsax.volume_high,
                    size: 20,
                  ),
                  onPressed: () => onSpeakPressed(summary),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              summary,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
