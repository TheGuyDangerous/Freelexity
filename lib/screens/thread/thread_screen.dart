import 'package:flutter/material.dart';
import 'thread_screen_state.dart';

class ThreadScreen extends StatefulWidget {
  final String query;
  final List<Map<String, dynamic>> searchResults;
  final String summary;

  const ThreadScreen({
    super.key,
    required this.query,
    required this.searchResults,
    required this.summary,
  });

  @override
  ThreadScreenState createState() => ThreadScreenState();
}
