import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool useWhisperModel;
  final Function(String) onSubmitted;
  final VoidCallback onListenPressed;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.isListening,
    required this.useWhisperModel,
    required this.onSubmitted,
    required this.onListenPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 4,
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            icon: Icon(
              isListening
                  ? Iconsax.stop_circle
                  : (useWhisperModel
                      ? Iconsax.microphone_2
                      : Iconsax.microphone),
              color: theme.colorScheme.onSurface,
            ),
            onPressed: onListenPressed,
          ),
        ],
      ),
    );
  }
}
