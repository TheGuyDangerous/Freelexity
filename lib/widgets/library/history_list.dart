import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../screens/thread/thread_loading_screen.dart';
import '../../custom_page_route.dart';

class HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> searchHistory;
  final Function(int) onDeleteItem;
  final VoidCallback onClearAll;
  final Function(String) onItemTap;

  const HistoryList({
    Key? key,
    required this.searchHistory,
    required this.onDeleteItem,
    required this.onClearAll,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: searchHistory.length + 1,
      separatorBuilder: (context, index) {
        if (index == 0) return SizedBox.shrink();
        return Divider(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[200],
          height: 1,
          thickness: 0.5,
        );
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildClearAllButton(context);
        }
        final item = searchHistory[index - 1];
        return _buildHistoryItem(context, item, index - 1);
      },
    );
  }

  Widget _buildClearAllButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: onClearAll,
        child: Text('Clear All History'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
      BuildContext context, Map<String, dynamic> item, int index) {
    return Dismissible(
      key: Key(item['timestamp']),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Iconsax.trash, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete History Item'),
            content: Text('Are you sure you want to delete this history item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          onDeleteItem(index);
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            CustomPageRoute(
              child: ThreadLoadingScreen(query: item['query']),
            ),
          );
          onItemTap(item['query']);
        },
        child: Card(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[100], // Make the container transparent
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['query'],
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
                SizedBox(height: 8),
                Text(
                  item['summary'] != null
                      ? _truncateSummary(item['summary'])
                      : 'No summary available',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon:
                          Icon(Iconsax.trash, color: Colors.white70, size: 20),
                      onPressed: () => onDeleteItem(index),
                    ),
                    Icon(Iconsax.arrow_right_3,
                        color: Colors.white70, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final date = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  String _truncateSummary(String summary) {
    return summary.length > 100 ? summary.substring(0, 100) + '...' : summary;
  }
}
