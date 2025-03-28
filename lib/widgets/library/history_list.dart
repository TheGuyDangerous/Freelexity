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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Clear All History'),
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
    
    final bool isSaved = item['isSaved'] == true;

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
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        isSaved ? Iconsax.bookmark : Iconsax.clock,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['query'] ?? 'No query',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSaved) const OfflineLabel(),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _truncateSummary(item['summary'] ?? 'No summary available'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (images.isNotEmpty)
                Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return _buildImageThumbnail(images[index], theme);
                      },
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTimestamp(item['timestamp'] ?? ''),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isSaved ? Iconsax.bookmark_2 : Iconsax.bookmark,
                            size: 20,
                            color: isSaved 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          onPressed: () {
                            // Placeholder for save/bookmark functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isSaved 
                                      ? 'Removed from saved items' 
                                      : 'Added to saved items'
                                ),
                              ),
                            );
                          },
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Iconsax.trash,
                            size: 20,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          onPressed: () => onDeleteItem(index),
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String imageUrl, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 160,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 160,
          height: 120,
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        errorWidget: (context, url, error) => const SizedBox.shrink(),
      ),
    );
  }

  String _truncateSummary(String summary) {
    return summary.length > 100 ? '${summary.substring(0, 100)}...' : summary;
  }
}
