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

const int maxHistoryItems = 50;

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
    if (_searchHistory.length > maxHistoryItems) {
      _searchHistory = _searchHistory.sublist(0, maxHistoryItems);
    }
    final history = _searchHistory.map((item) => json.encode(item)).toList();
    await prefs.setStringList('search_history', history);
  }

  void _onRefresh() async {
    await _loadSearchHistory();
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
