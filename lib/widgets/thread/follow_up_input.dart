import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FollowUpInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final bool? isDarkMode;

  const FollowUpInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use provided isDarkMode or infer from theme
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Ask follow-up...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => onSubmitted(controller.text),
            ),
          ),
          IconButton(
            icon: Icon(
              Iconsax.send_1,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => onSubmitted(controller.text),
          ),
        ],
      ),
    );
  }
}
