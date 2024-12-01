import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../../widgets/library/history_list.dart';
import '../../widgets/library/empty_state.dart';
import '../../widgets/library/incognito_message.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import 'library_screen.dart';
import '../thread/thread_screen.dart';
import '../thread/thread_loading_screen.dart';

const int maxHistoryItems = 50;

class LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> _searchHistory = [];
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
      final savedThreads = prefs.getStringList('saved_threads') ?? [];
      final searchHistory = prefs.getStringList('search_history') ?? [];
      debugPrint('Loaded saved_threads from SharedPreferences: $savedThreads');
      debugPrint(
          'Loaded search_history from SharedPreferences: $searchHistory');

      setState(() {
        _searchHistory = [
          ...savedThreads.map((item) {
            try {
              final data = json.decode(item) as Map<String, dynamic>;
              data['isSaved'] = true;
              debugPrint('Loaded saved thread: $data');
              return data;
            } catch (e) {
              debugPrint('Error decoding saved thread: $e');
              return null;
            }
          }).whereType<Map<String, dynamic>>(),
          ...searchHistory.map((item) {
            try {
              final data = json.decode(item) as Map<String, dynamic>;
              data['isSaved'] = false;
              debugPrint('Loaded search history item: $data');
              return data;
            } catch (e) {
              debugPrint('Error decoding search history item: $e');
              return null;
            }
          }).whereType<Map<String, dynamic>>(),
        ];

        // Remove duplicates based on query and timestamp
        _searchHistory =
            _searchHistory.fold<List<Map<String, dynamic>>>([], (list, item) {
          if (!list.any((element) =>
              element['query'] == item['query'] &&
              element['timestamp'] == item['timestamp'])) {
            list.add(item);
          }
          return list;
        });

        // Sort the combined list by timestamp
        _searchHistory.sort((a, b) => DateTime.parse(b['timestamp'])
            .compareTo(DateTime.parse(a['timestamp'])));
      });
    } else {
      setState(() {
        _searchHistory = [];
      });
    }
  }

  Future<void> _onDeleteItem(int index) async {
    setState(() {
      _searchHistory.removeAt(index);
    });
    await _saveSearchHistory();
  }

  Future<void> _onClearAll() async {
    setState(() {
      _searchHistory.clear();
    });
    await _saveSearchHistory();
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (_searchHistory.length > maxHistoryItems) {
      _searchHistory = _searchHistory.sublist(0, maxHistoryItems);
    }
    final savedThreads =
        _searchHistory.where((item) => item['isSaved'] == true).toList();
    final searchHistory =
        _searchHistory.where((item) => item['isSaved'] != true).toList();

    await prefs.setStringList('saved_threads',
        savedThreads.map((item) => json.encode(item)).toList());
    await prefs.setStringList('search_history',
        searchHistory.map((item) => json.encode(item)).toList());
  }

  void _onRefresh() async {
    await _loadSearchHistory();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor:
              themeProvider.isDarkMode ? Colors.black : Colors.grey[100],
          appBar: AppBar(
            backgroundColor:
                themeProvider.isDarkMode ? Colors.black : Colors.grey[100],
            title: Text(
              'Library',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
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
                        onDeleteItem: _onDeleteItem,
                        onClearAll: _onClearAll,
                        onItemTap: _handleItemTap,
                      ),
          ),
        );
      },
    );
  }

  void _handleItemTap(Map<String, dynamic> item) async {
    final savedThreadPath = item['path'] as String?;
    debugPrint('Tapped item with savedThreadPath: $savedThreadPath');

    if (savedThreadPath != null) {
      final file = File(savedThreadPath);
      if (await file.exists()) {
        try {
          final jsonString = await file.readAsString();
          final threadData = json.decode(jsonString);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ThreadScreen(
                query: threadData['query'],
                searchResults: List<Map<String, dynamic>>.from(
                    threadData['searchResults']),
                summary: threadData['summary'],
                savedSections: threadData['sections'] != null
                    ? List<Map<String, dynamic>>.from(threadData['sections'])
                    : null,
              ),
            ),
          );
        } catch (e) {
          debugPrint('Error loading saved thread: $e');
          _performNewSearch(item['query']);
        }
      } else {
        debugPrint('Saved thread file does not exist: $savedThreadPath');
        _performNewSearch(item['query']);
      }
    } else {
      debugPrint('No saved thread path found');
      _performNewSearch(item['query']);
    }
  }

  void _performNewSearch(String query) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThreadLoadingScreen(query: query),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
