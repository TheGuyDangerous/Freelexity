import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FollowUpInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const FollowUpInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Ask follow-up...',
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey
                      : Colors.grey[600],
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => onSubmitted(controller.text),
            ),
          ),
          IconButton(
            icon: Icon(
              Iconsax.send_1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () => onSubmitted(controller.text),
          ),
        ],
      ),
    );
  }
}
