import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'thread_loading_screen.dart';
import '../custom_page_route.dart';
import 'search_screen.dart';
import '../services/search_service.dart';

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
          Icon(Icons.history, size: 64, color: Colors.grey),
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
    return ListView.builder(
      itemCount: _searchHistory.length + 1, // +1 for the clear all button
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
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _deleteHistoryItem(index - 1);
          },
          child: Card(
            color: Colors.grey[900],
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                item['query'],
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _formatTimestamp(item['timestamp']),
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: Colors.white70, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  CustomPageRoute(
                    child: ThreadLoadingScreen(query: item['query']),
                  ),
                );
                // Use the SearchService to perform the search
                _searchService.performSearch(context, item['query']);
              },
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
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
