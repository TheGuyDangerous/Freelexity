import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'thread_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> _searchHistory = [];

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
        title: Text('Library'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _searchHistory.isEmpty
          ? Center(
              child: Text(
                'Your search history will appear here',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                final item = _searchHistory[index];
                return ListTile(
                  title: Text(item['query'],
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    item['timestamp'],
                    style: TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    // Here you would typically open the ThreadScreen with the saved data
                    // For now, we'll just print the summary
                    print(item['summary']);
                  },
                );
              },
            ),
    );
  }
}
