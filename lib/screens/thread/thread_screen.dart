import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'thread_screen_state.dart';
import '../../widgets/thread/loading_shimmer.dart';
import '../../services/search_service.dart';

class ThreadScreen extends StatefulWidget {
  final String query;
  final List<Map<String, dynamic>> searchResults;
  final String summary;

  const ThreadScreen({
    Key? key,
    required this.query,
    required this.searchResults,
    required this.summary,
  }) : super(key: key);

  @override
  ThreadScreenState createState() => ThreadScreenState();
}
