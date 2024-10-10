import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/date_formatter.dart';
import 'offline_label.dart';
import 'package:iconsax/iconsax.dart';

class HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> searchHistory;
  final Function(int) onDeleteItem;
  final VoidCallback onClearAll;
  final Function(Map<String, dynamic>) onItemTap;

  const HistoryList({
    Key? key,
    required this.searchHistory,
    required this.onDeleteItem,
    required this.onClearAll,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildClearAllButton(context),
        Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: searchHistory.length,
            itemBuilder: (context, index) {
              return _buildHistoryItem(context, searchHistory[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClearAllButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onClearAll,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
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

  Widget _buildHistoryItem(
      BuildContext context, Map<String, dynamic> item, int index) {
    List<String> images = [];
    debugPrint('Processing item: $item'); // Log the entire item

    if (item['images'] != null && item['images'] is List) {
      debugPrint('Images found: ${item['images']}'); // Log the images list
      images = (item['images'] as List)
          .where((img) {
            bool isValid = img is Map<String, dynamic> && img['url'] != null;
            debugPrint(
                'Image $img is valid: $isValid'); // Log each image validity
            return isValid;
          })
          .map((img) => img['url'] as String)
          .take(3)
          .toList();
      debugPrint('Processed images: $images'); // Log the processed images
    } else {
      debugPrint('No images found or invalid image data');
    }

    return Dismissible(
      key: ValueKey(item['timestamp']),
      background: Container(
        color: const Color.fromARGB(132, 244, 67, 54),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Iconsax.trash, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDeleteItem(index);
      },
      child: GestureDetector(
        onTap: () => onItemTap(item),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                    fontSize: 14,
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
                        debugPrint(
                            'Building image thumbnail for ${images[index]}');
                        return _buildImageThumbnail(images[index]);
                      },
                    ),
                  )
                else
                  SizedBox.shrink(
                    child: Text('No images to display'),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTimestamp(item['timestamp'] ?? ''),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            debugPrint('Loading image: $url');
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
            );
          },
          errorWidget: (context, url, error) {
            debugPrint('Error loading image: $url, Error: $error');
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _truncateSummary(String summary) {
    return summary.length > 100 ? '${summary.substring(0, 100)}...' : summary;
  }
}
