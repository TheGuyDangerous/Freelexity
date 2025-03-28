import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:convert';
import 'dart:io';
import '../../widgets/library/history_list.dart';
import '../../widgets/library/empty_state.dart';
import '../../widgets/library/incognito_message.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'library_screen.dart';
import '../thread/thread_screen.dart';
import '../thread/thread_loading_screen.dart';

const int maxHistoryItems = 50;

class LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> _searchHistory = [];
  List<Map<String, dynamic>> _filteredHistory = [];
  bool _isIncognitoMode = false;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
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
        
        _filteredHistory = List.from(_searchHistory);
      });
    } else {
      setState(() {
        _searchHistory = [];
        _filteredHistory = [];
      });
    }
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredHistory = List.from(_searchHistory);
      });
      return;
    }

    setState(() {
      _filteredHistory = _searchHistory
          .where((item) => 
              item['query'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _onDeleteItem(int index) async {
    final item = _filteredHistory[index];
    final originalIndex = _searchHistory.indexWhere((original) => 
        original['query'] == item['query'] && 
        original['timestamp'] == item['timestamp']);
    
    if (originalIndex != -1) {
      setState(() {
        _searchHistory.removeAt(originalIndex);
        _filteredHistory.removeAt(index);
      });
      await _saveSearchHistory();
    }
  }

  Future<void> _onClearAll() async {
    setState(() {
      _searchHistory.clear();
      _filteredHistory.clear();
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

  void _showFilterOptions() {
    // Placeholder for filter functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter options coming soon')),
    );
  }

  void _showExportImportOptions() {
    // Placeholder for export/import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export/Import options coming soon')),
    );
  }

  void _showStats() {
    // Placeholder for stats functionality
    final totalSaved = _searchHistory.where((item) => item['isSaved'] == true).length;
    final totalHistory = _searchHistory.length - totalSaved;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Library Statistics', 
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            _buildStatRow('Total Items', '${_searchHistory.length}'),
            _buildStatRow('Saved Threads', '$totalSaved'),
            _buildStatRow('History Items', '$totalHistory'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (!_showSearch) ...[
                    Text(
                      'Library',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Iconsax.chart),
                      onPressed: _showStats,
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.search_normal),
                      onPressed: () => setState(() => _showSearch = true),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.export_1),
                      onPressed: _showExportImportOptions,
                    ),
                  ] else ...[
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search saved arguments...',
                          border: InputBorder.none,
                          prefixIcon: const Icon(Iconsax.search_normal),
                          suffixIcon: IconButton(
                            icon: const Icon(Iconsax.close_circle),
                            onPressed: () {
                              _searchController.clear();
                              _filterSearchResults('');
                              setState(() => _showSearch = false);
                            },
                          ),
                        ),
                        onChanged: _filterSearchResults,
                      ),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Iconsax.filter),
                    onPressed: _showFilterOptions,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: _isIncognitoMode
                    ? const IncognitoMessage()
                    : _filteredHistory.isEmpty
                        ? const EmptyState()
                        : HistoryList(
                            searchHistory: _filteredHistory,
                            onDeleteItem: _onDeleteItem,
                            onClearAll: _onClearAll,
                            onItemTap: _handleItemTap,
                          ),
              ),
            ),
          ],
        ),
      ),
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
          if (mounted) {
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
          }
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
}

