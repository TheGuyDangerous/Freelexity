import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../widgets/library/history_list.dart';
import '../../widgets/library/empty_state.dart';
import '../../widgets/library/incognito_message.dart';
import '../../services/search_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import 'library_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const int MAX_HISTORY_ITEMS = 50;

class LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> _searchHistory = [];
  final SearchService _searchService = SearchService();
  bool _isIncognitoMode = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _isIncognitoMode = prefs.getBool('incognitoMode') ?? false;
    if (!_isIncognitoMode) {
      final history = prefs.getStringList('search_history') ?? [];
      setState(() {
        _searchHistory = history
            .map((item) => json.decode(item) as Map<String, dynamic>)
            .toList();
      });
    } else {
      setState(() {
        _searchHistory = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Library',
            style:
                TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        foregroundColor: themeProvider.isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          if (_searchHistory.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: _clearAllHistory,
            ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: _isIncognitoMode
            ? IncognitoMessage()
            : _searchHistory.isEmpty
                ? EmptyState()
                : HistoryList(
                    searchHistory: _searchHistory,
                    onDeleteItem: _deleteHistoryItem,
                    onClearAll: _clearAllHistory,
                    onItemTap: (query) =>
                        _searchService.performSearch(context, query),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All History'),
        content: Text('Are you sure you want to clear all search history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _searchHistory.clear();
      });
      await _saveSearchHistory();
    }
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (_searchHistory.length > MAX_HISTORY_ITEMS) {
      _searchHistory = _searchHistory.sublist(0, MAX_HISTORY_ITEMS);
    }
    final history = _searchHistory.map((item) => json.encode(item)).toList();
    await prefs.setStringList('search_history', history);
  }

  void _onRefresh() async {
    await _loadSearchHistory();
    _refreshController.refreshCompleted();
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

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _exportSearchHistory() async {
    final String historyJson = jsonEncode(_searchHistory);
    // Implement file writing logic here, or use a package like path_provider to save the file
    // For now, we'll just print the JSON
    print(historyJson);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Search history exported')),
    );
  }
}
