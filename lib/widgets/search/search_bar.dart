import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomSearchBar extends StatefulWidget {
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
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    // Check initial text state
    _hasText = widget.controller.text.isNotEmpty;
    // Add listener to track text changes
    widget.controller.addListener(_updateTextState);
  }

  void _updateTextState() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTextState);
    super.dispose();
  }

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
              controller: widget.controller,
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
              onSubmitted: widget.onSubmitted,
            ),
          ),
          // Show send button if there's text, otherwise show mic button
          if (_hasText)
            IconButton(
              icon: Icon(
                Iconsax.send_1,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => widget.onSubmitted(widget.controller.text),
            )
          else
            IconButton(
              icon: Icon(
                widget.isListening
                    ? Iconsax.stop_circle
                    : (widget.useWhisperModel
                        ? Iconsax.microphone_2
                        : Iconsax.microphone),
                color: theme.colorScheme.onSurface,
              ),
              onPressed: widget.onListenPressed,
            ),
        ],
      ),
    );
  }
}
