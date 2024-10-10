import 'package:flutter/material.dart';

class OfflineLabel extends StatelessWidget {
  const OfflineLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(28, 36, 31, 1),
        border: Border.all(color: Color.fromRGBO(70, 92, 30, 1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Offline',
        style: TextStyle(
          color: Color.fromRGBO(168, 221, 32, 1),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
