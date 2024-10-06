import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.clock, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Your search history will appear here',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
