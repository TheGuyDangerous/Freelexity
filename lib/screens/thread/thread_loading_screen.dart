import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../../widgets/thread/loading_shimmer.dart';
import '../../services/search_service.dart';
import '../../services/determiner_agent_service.dart';
import '../../services/disambiguation_agent_service.dart';
import '../../services/query_enhancement_service.dart';
import '../../models/ambiguity_detection_model.dart';
import '../../models/disambiguation_option_model.dart';
import '../../widgets/search/ambiguity_resolution_widget.dart';
import 'thread_screen.dart';

class ThreadLoadingScreen extends StatefulWidget {
  final String query;
  final String? savedThreadPath;
  final Map<String, dynamic>? savedThreadData;

  const ThreadLoadingScreen({
    super.key,
    required this.query,
    this.savedThreadPath,
    this.savedThreadData,
  });

  @override
  State<ThreadLoadingScreen> createState() => _ThreadLoadingScreenState();
}

class _ThreadLoadingScreenState extends State<ThreadLoadingScreen> {
  final SearchService _searchService = SearchService();
  final DeterminerAgentService _determinerAgentService = DeterminerAgentService();
  final DisambiguationAgentService _disambiguationAgentService = DisambiguationAgentService();
  final QueryEnhancementService _queryEnhancementService = QueryEnhancementService();
  
  bool _isLoading = true;
  bool _isDisambiguating = false;
  AmbiguityDetectionResult? _ambiguityResult;
  List<DisambiguationOption> _disambiguationOptions = [];
  List<Map<String, dynamic>> _preliminarySearchResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadThreadOrSearch();
    });
  }

  Future<void> _loadThreadOrSearch() async {
    if (widget.savedThreadData != null) {
      _navigateToThreadScreen(widget.savedThreadData!);
    } else if (widget.savedThreadPath != null) {
      await _loadSavedThread(widget.savedThreadPath!);
    } else {
      await _checkAmbiguity();
    }
  }

  Future<void> _loadSavedThread(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final threadData = json.decode(jsonString);
        _navigateToThreadScreen(threadData);
      } else {
        await _checkAmbiguity();
      }
    } catch (e) {
      debugPrint('Error loading saved thread: $e');
      await _checkAmbiguity();
    }
  }

  Future<void> _checkAmbiguity() async {
    setState(() {
      _isLoading = true;
    });
    
    // Get preliminary search results to help with disambiguation
    _preliminarySearchResults = await _searchService.getBasicSearchResults(widget.query);
    
    // Check if query is ambiguous
    final ambiguityResult = await _determinerAgentService.detectAmbiguity(widget.query);
    
    if (!mounted) return;
    
    setState(() {
      _ambiguityResult = ambiguityResult;
    });
    
    if (ambiguityResult.isAmbiguous) {
      await _handleAmbiguousQuery(ambiguityResult);
    } else {
      await _performSearch(widget.query);
    }
  }

  Future<void> _handleAmbiguousQuery(AmbiguityDetectionResult ambiguityResult) async {
    // Generate disambiguation options
    final options = await _disambiguationAgentService.generateOptions(
      ambiguityResult, 
      _preliminarySearchResults
    );
    
    if (!mounted) return;
    
    if (options.isEmpty) {
      // If no options could be generated, proceed with original query
      await _performSearch(widget.query);
      return;
    }
    
    setState(() {
      _isDisambiguating = true;
      _disambiguationOptions = options;
      _isLoading = false;
    });
    
    // Show disambiguation UI (handled in build method)
  }

  void _onDisambiguationOptionSelected(DisambiguationOption option) {
    final enhancedQuery = _queryEnhancementService.enhanceQuery(widget.query, option);
    
    setState(() {
      _isDisambiguating = false;
      _isLoading = true;
    });
    
    _performSearch(enhancedQuery);
  }

  void _continueWithOriginalQuery() {
    setState(() {
      _isDisambiguating = false;
      _isLoading = true;
    });
    
    _performSearch(widget.query);
  }

  Future<void> _performSearch(String query) async {
    final results = await _searchService.performSearch(context, query);
    if (mounted) {
      if (results != null) {
        _navigateToThreadScreen(results);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _navigateToThreadScreen(Map<String, dynamic> data) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ThreadScreen(
          query: data['query'],
          searchResults: List<Map<String, dynamic>>.from(data['searchResults']),
          summary: data['summary'],
          savedSections: data['sections'] as List<dynamic>?,
          disambiguationInfo: _ambiguityResult?.isAmbiguous == true ? {
            'wasDisambiguated': true,
            'ambiguityType': _ambiguityResult!.ambiguityType,
            'originalQuery': _ambiguityResult!.originalQuery,
          } : null,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          _isDisambiguating 
              ? 'Clarify Your Search'
              : (widget.savedThreadPath != null || widget.savedThreadData != null
                  ? 'Loading Saved Thread'
                  : 'Searching...'),
          style: theme.textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isDisambiguating
          ? AmbiguityResolutionWidget(
              ambiguityResult: _ambiguityResult!,
              options: _disambiguationOptions,
              onOptionSelected: _onDisambiguationOptionSelected,
              onContinueWithOriginal: _continueWithOriginalQuery,
            )
          : SingleChildScrollView(
              child: LoadingShimmer(isDarkMode: theme.brightness == Brightness.dark),
            ),
    );
  }
}
