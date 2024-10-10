import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import '../../widgets/thread/summary_card.dart';
import '../../widgets/thread/sources_section.dart';
import '../../widgets/thread/image_section.dart';
import '../../widgets/thread/related_questions.dart';
import '../../widgets/thread/follow_up_input.dart';
import '../../services/search_service.dart';
import 'thread_screen.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../utils/constants.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ThreadScreenState extends State<ThreadScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _followUpController = TextEditingController();
  List<ThreadSection> _threadSections = []; // Changed from final to non-final
  bool _isIncognitoMode = false;
  bool _isSpeaking = false;
  late FlutterTts _flutterTts;
  bool _isLoading = false;
  final SearchService _searchService = SearchService();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadIncognitoMode();
    _initializeTts();
    if (widget.savedSections != null) {
      _loadSavedSections();
    } else {
      _addInitialSection();
      _loadData();
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _loadIncognitoMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isIncognitoMode = prefs.getBool('incognitoMode') ?? false;
    });
    if (!_isIncognitoMode) {
      _saveToHistory();
    }
  }

  Future<void> _saveToHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history') ?? [];
    final threadData = json.encode({
      'query': widget.query,
      'summary': widget.summary,
      'timestamp': DateTime.now().toIso8601String(),
    });
    history.insert(0, threadData);
    await prefs.setStringList('search_history', history);
  }

  Future<void> _loadData() async {
    await Future.wait([
      _fetchRelatedQuestions(),
      _fetchImages(),
    ]);
  }

  Future<void> _fetchRelatedQuestions([String? query, String? summary]) async {
    final prefs = await SharedPreferences.getInstance();
    final groqApiKey = prefs.getString('groqApiKey') ?? '';

    if (groqApiKey.isEmpty) {
      debugPrint('Groq API key is not set');
      return;
    }

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey',
        },
        body: jsonEncode({
          'model': 'mixtral-8x7b-32768',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Generate 4 brief, related questions based on the given query and summary. Each question should be no longer than 10 words.'
            },
            {
              'role': 'user',
              'content':
                  'Query: ${query ?? widget.query}\n\nSummary: ${summary ?? widget.summary}\n\nGenerate 4 short, related questions:'
            },
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        final questions =
            content.split('\n').where((q) => q.trim().isNotEmpty).toList();
        setState(() {
          _threadSections.last.relatedQuestions = questions
              .map((q) => q.replaceAll(RegExp(r'^\d+\.\s*'), ''))
              .toList();
        });
      } else {
        debugPrint('Failed to fetch related questions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching related questions: $e');
    }
  }

  Future<void> _fetchImages([String? query]) async {
    final prefs = await SharedPreferences.getInstance();
    final braveApiKey = prefs.getString('braveApiKey') ?? '';

    if (braveApiKey.isEmpty) {
      debugPrint('Brave API key is not set');
      return;
    }

    final url = Uri.parse(
        'https://api.search.brave.com/res/v1/images/search?q=${Uri.encodeComponent(query ?? widget.query)}&count=5');

    try {
      final response = await http.get(
        url,
        headers: {'X-Subscription-Token': braveApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = List<Map<String, dynamic>>.from(data['results']);
        setState(() {
          _threadSections.last.images = results
              .map((result) {
                final imageUrl = result['thumbnail']['src'] as String?;
                debugPrint('Image URL: $imageUrl');
                return {
                  'url': imageUrl,
                  'websiteName': result['source'] as String? ?? 'Unknown',
                  'favicon': result['favicon'] as String?,
                };
              })
              .where((imageData) =>
                  imageData['url'] != null && imageData['url']!.isNotEmpty)
              .toList();
        });
      } else {
        debugPrint('Failed to fetch images: ${response.statusCode}');
        setState(() {
          _threadSections.last.images = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching images: $e');
      setState(() {
        _threadSections.last.images = [];
      });
    }
  }

  Future<void> _toggleSpeech(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(text);
      _flutterTts.setCompletionHandler(() {
        setState(() => _isSpeaking = false);
      });
    }
  }

  Future<void> _downloadThread() async {
    try {
      final threadData = {
        'query': widget.query,
        'summary': widget.summary,
        'searchResults': widget.searchResults,
        'sections': _threadSections
            .map((section) => {
                  'query': section.query,
                  'summary': section.summary,
                  'searchResults': section.searchResults,
                  'relatedQuestions': section.relatedQuestions,
                  'images': section.images,
                })
            .toList(),
      };

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'thread_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(json.encode(threadData));
      debugPrint('Thread saved to file: ${file.path}');

      // Save the file path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedThreads = prefs.getStringList('saved_threads') ?? [];
      final searchHistory = prefs.getStringList('search_history') ?? [];

      // Create the new thread entry
      final newThreadEntry = json.encode({
        'query': widget.query,
        'summary': widget.summary,
        'path': file.path,
        'timestamp': DateTime.now().toIso8601String(),
        'isSaved': true,
      });

      // Remove any existing entries with the same query from both lists
      savedThreads.removeWhere((item) {
        final decoded = json.decode(item);
        return decoded['query'] == widget.query;
      });
      searchHistory.removeWhere((item) {
        final decoded = json.decode(item);
        return decoded['query'] == widget.query;
      });

      // Add the new thread entry to the saved threads list
      savedThreads.insert(0, newThreadEntry);

      // Save the updated lists
      await prefs.setStringList('saved_threads', savedThreads);
      await prefs.setStringList('search_history', searchHistory);

      debugPrint('Updated saved_threads in SharedPreferences: $savedThreads');
      debugPrint('Updated search_history in SharedPreferences: $searchHistory');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thread saved successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error saving thread: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save thread')),
        );
      }
    }
  }

  void _addInitialSection() {
    _threadSections.add(ThreadSection(
      query: widget.query,
      summary: widget.summary,
      searchResults: widget.searchResults,
    ));
  }

  void _addFollowUpSection(String question) {
    setState(() {
      _threadSections.add(ThreadSection(query: question));
      _isLoading = true;
    });
    _performSearch(question);
  }

  Future<void> _performSearch(String query) async {
    try {
      final result = await _searchService.performSearch(context, query);
      if (result != null) {
        setState(() {
          _threadSections.last.searchResults = result['searchResults'];
          _threadSections.last.summary = result['summary'];
          _isLoading = false;
        });
        await _fetchRelatedQuestions(query, result['summary']);
        await _fetchImages(query);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error performing search: $e');
      setState(() => _isLoading = false);
    }
  }

  void _loadSavedSections() {
    _threadSections = widget.savedSections!.map((section) {
      return ThreadSection(
        query: section['query'] as String,
        summary: section['summary'] as String?,
        searchResults: (section['searchResults'] as List<dynamic>?)
            ?.map((item) => item as Map<String, dynamic>)
            .toList(),
        relatedQuestions: (section['relatedQuestions'] as List<dynamic>?)
            ?.map((item) => item as String)
            .toList(),
        images: (section['images'] as List<dynamic>?)
            ?.map((item) => Map<String, String?>.from(item))
            .toList(),
      );
    }).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _followUpController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              0, MediaQuery.of(context).size.height * (1 - _animation.value)),
          child: Scaffold(
            backgroundColor:
                themeProvider.isDarkMode ? Colors.black : Colors.white,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Iconsax.close_square),
                onPressed: () {
                  _animationController.reverse().then((_) {
                    Navigator.of(context).pop();
                  });
                },
              ),
              title: Text('Thread',
                  style: TextStyle(
                      fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
              backgroundColor:
                  themeProvider.isDarkMode ? Colors.black : Colors.white,
              foregroundColor:
                  themeProvider.isDarkMode ? Colors.white : Colors.black,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Iconsax.document_download),
                  onPressed: _downloadThread,
                ),
              ],
            ),
            body: Stack(
              children: [
                ScrollConfiguration(
                  behavior: BouncyScrollBehavior(),
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: _threadSections.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ThreadSectionWidget(
                            section: _threadSections[index],
                            onFollowUpSelected: _addFollowUpSection,
                            onSpeakPressed: _toggleSpeech,
                            isSpeaking: _isSpeaking,
                          ),
                          if (index < _threadSections.length - 1)
                            Divider(
                              color: themeProvider.isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              thickness: 1,
                              height: 32,
                            ),
                          // Add bottom padding to the last item
                          if (index == _threadSections.length - 1)
                            SizedBox(height: 80), // Adjust this value as needed
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: FollowUpInput(
                    controller: _followUpController,
                    onSubmitted: (String question) {
                      if (question.isNotEmpty) {
                        _addFollowUpSection(question);
                        _followUpController.clear();
                      }
                    },
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ThreadSection {
  final String query;
  String? summary;
  List<Map<String, dynamic>>? searchResults;
  List<String>? relatedQuestions;
  List<Map<String, String?>>? images;

  ThreadSection({
    required this.query,
    this.summary,
    this.searchResults,
    this.relatedQuestions,
    this.images,
  });
}

class ThreadSectionWidget extends StatelessWidget {
  final ThreadSection section;
  final Function(String) onFollowUpSelected;
  final Function(String) onSpeakPressed;
  final bool isSpeaking;

  const ThreadSectionWidget({
    Key? key,
    required this.section,
    required this.onFollowUpSelected,
    required this.onSpeakPressed,
    required this.isSpeaking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            section.query,
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (section.searchResults != null)
          SourcesSection(searchResults: section.searchResults!),
        if (section.images != null) ImageSection(images: section.images!),
        if (section.summary != null)
          SummaryCard(
            summary: section.summary!,
            onSpeakPressed: onSpeakPressed,
            isSpeaking: isSpeaking,
          ),
        if (section.relatedQuestions != null)
          RelatedQuestions(
            questions: section.relatedQuestions!,
            onQuestionSelected: onFollowUpSelected,
          ),
      ],
    );
  }
}

class BouncyScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return BouncingScrollPhysics();
  }
}
