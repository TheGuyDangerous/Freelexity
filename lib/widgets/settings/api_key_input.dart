import 'package:flutter/material.dart';

class ApiKeyInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final VoidCallback onChanged;

  const ApiKeyInput({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        title: TextField(
          controller: controller,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            border: InputBorder.none,
          ),
          onChanged: (_) => onChanged(),
        ),
      ),
    );
  }
}
