import 'package:flutter/material.dart';
import 'thread_screen_state.dart';

class ThreadScreen extends StatefulWidget {
  final String query;
  final List<Map<String, dynamic>> searchResults;
  final String summary;
  final List<dynamic>? savedSections;

  const ThreadScreen({
    Key? key,
    required this.query,
    required this.searchResults,
    required this.summary,
    this.savedSections,
  }) : super(key: key);

  @override
  ThreadScreenState createState() => ThreadScreenState();
}
