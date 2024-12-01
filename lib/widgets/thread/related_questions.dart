import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class RelatedQuestions extends StatelessWidget {
  final List<String> questions;
  final Function(String) onQuestionSelected;

  const RelatedQuestions({
    super.key,
    required this.questions,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (questions.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: theme.colorScheme.outlineVariant,
          thickness: 1,
          height: 32,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Related',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                questions[index],
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(
                Iconsax.arrow_right_3,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                size: 18,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              dense: true,
              onTap: () => onQuestionSelected(questions[index]),
            );
          },
        ),
      ],
    );
  }
}
