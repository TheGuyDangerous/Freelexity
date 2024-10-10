import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../screens/thread/thread_loading_screen.dart';
import '../../custom_page_route.dart';
import '../../utils/date_formatter.dart';
import 'offline_label.dart';

class HistoryList extends StatefulWidget {
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
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  late List<Map<String, dynamic>> _searchHistory;

  @override
  void initState() {
    super.initState();
    _searchHistory = List.from(widget.searchHistory);
  }

  @override
  void didUpdateWidget(HistoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchHistory != oldWidget.searchHistory) {
      setState(() {
        _searchHistory = List.from(widget.searchHistory);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildClearAllButton(context),
        Expanded(
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: ValueKey(_searchHistory[index]['timestamp']),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  setState(() {
                    _searchHistory.removeAt(index);
                  });
                  widget.onDeleteItem(index);
                },
                confirmDismiss: (DismissDirection direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text(
                            "Are you sure you want to delete this item?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("CANCEL"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("DELETE"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: _buildHistoryItem(context, _searchHistory[index], index),
              );
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
          onPressed: widget.onClearAll,
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
    return GestureDetector(
      onTap: () => widget.onItemTap(item),
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
    );
  }

  String _truncateSummary(String summary) {
    return summary.length > 100 ? '${summary.substring(0, 100)}...' : summary;
  }
}
