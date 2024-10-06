import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class IncognitoMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.shield_tick, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Incognito Mode Active',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Your search history is not being saved',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
