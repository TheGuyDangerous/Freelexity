import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/date_formatter.dart';
import 'offline_label.dart';

class HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> searchHistory;
  final Function(int) onDeleteItem;
  final VoidCallback onClearAll;
  final Function(Map<String, dynamic>) onItemTap;

  const HistoryList({
    super.key,
    required this.searchHistory,
    required this.onDeleteItem,
    required this.onClearAll,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _buildClearAllButton(context, theme),
        Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: searchHistory.length,
            itemBuilder: (context, index) {
              return _buildHistoryItem(
                  context, searchHistory[index], index, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClearAllButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: onClearAll,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text('Clear All History'),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> item,
      int index, ThemeData theme) {
    List<String> images = [];
    if (item['images'] != null && item['images'] is List) {
      images = (item['images'] as List)
          .where((img) => img is Map<String, dynamic> && img['url'] != null)
          .map((img) => img['url'] as String)
          .take(3)
          .toList();
    }

    return Dismissible(
      key: ValueKey(item['timestamp']),
      background: Container(
        color: theme.colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: Icon(Iconsax.trash, color: theme.colorScheme.onErrorContainer),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDeleteItem(index);
      },
      child: GestureDetector(
        onTap: () => onItemTap(item),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: theme.colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['query'] ?? 'No query',
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item['isSaved'] == true) const OfflineLabel(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _truncateSummary(item['summary'] ?? 'No summary available'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (images.isNotEmpty)
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return _buildImageThumbnail(images[index], theme);
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  formatTimestamp(item['timestamp'] ?? ''),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String imageUrl, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 60,
            height: 60,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  String _truncateSummary(String summary) {
    return summary.length > 100 ? '${summary.substring(0, 100)}...' : summary;
  }
}
