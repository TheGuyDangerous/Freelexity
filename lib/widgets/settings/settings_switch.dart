import 'package:flutter/material.dart';
import '../../theme_provider.dart';

class SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;
  final bool isDarkMode;

  const SettingsSwitch({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.trailing,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
          fontSize: 14,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
      inactiveThumbColor: isDarkMode ? Colors.grey[600] : Colors.grey[400],
      inactiveTrackColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
      secondary: trailing,
    );
  }
}
