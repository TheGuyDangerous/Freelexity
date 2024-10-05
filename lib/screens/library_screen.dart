import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'thread_loading_screen.dart';
import '../custom_page_route.dart';
import '../services/search_service.dart';
import 'package:iconsax/iconsax.dart'; // Add this import
import 'package:intl/intl.dart'; // Add this import for date formatting

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> _searchHistory = [];
  final SearchService _searchService = SearchService();

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history') ?? [];
    setState(() {
      _searchHistory = history
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Library', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _searchHistory.isEmpty ? _buildEmptyState() : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.clock, size: 64, color: Colors.grey), // Updated icon
          SizedBox(height: 16),
          Text(
            'Your search history will appear here',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      itemCount: _searchHistory.length + 1,
      separatorBuilder: (context, index) {
        if (index == 0)
          return SizedBox.shrink(); // No divider above the clear all button
        return Divider(color: Colors.grey[800], height: 1, thickness: 0.5);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildClearAllButton();
        }
        final item = _searchHistory[index - 1];
        return Dismissible(
          key: Key(item['timestamp']),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16),
            child: Icon(Iconsax.trash, color: Colors.white), // Updated icon
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _deleteHistoryItem(index - 1);
          },
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                CustomPageRoute(
                  child: ThreadLoadingScreen(query: item['query']),
                ),
              );
              _searchService.performSearch(context, item['query']);
            },
            child: Card(
              color:
                  Colors.black, // Changed from Colors.grey[900] to Colors.black
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                            item['query'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTimestamp(item['timestamp']),
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      item['summary'] != null
                          ? _truncateSummary(item['summary'])
                          : 'No summary available',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Iconsax.trash,
                              color: Colors.white70, size: 20), // Updated icon
                          onPressed: () {
                            _deleteHistoryItem(index - 1);
                          },
                        ),
                        Icon(Iconsax.arrow_right_3,
                            color: Colors.white70, size: 20), // Updated icon
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClearAllButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _clearAllHistory,
        child: Text('Clear All History'),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Colors.grey[800], // Changed from Colors.red to a greyish color
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _deleteHistoryItem(int index) async {
    setState(() {
      _searchHistory.removeAt(index);
    });
    await _saveSearchHistory();
  }

  void _clearAllHistory() async {
    setState(() {
      _searchHistory.clear();
    });
    await _saveSearchHistory();
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = _searchHistory.map((item) => json.encode(item)).toList();
    await prefs.setStringList('search_history', history);
  }

  String _formatTimestamp(String timestamp) {
    final date = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(date); // Today, show only time
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date); // Weekday name
    } else {
      return DateFormat.yMMMd().format(date); // Month Day, Year
    }
  }

  String _truncateSummary(String summary) {
    return summary.length > 100 ? summary.substring(0, 100) + '...' : summary;
  }
}
