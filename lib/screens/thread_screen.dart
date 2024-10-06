import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:iconsax/iconsax.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/search_service.dart';
import 'thread_loading_screen.dart';

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
  _ThreadScreenState createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _followUpController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  List<String> _relatedQuestions = [];
  List<String> _images = [];
  bool _isIncognitoMode = false;
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
    _loadIncognitoMode();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _followUpController.dispose();
    _flutterTts.stop();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              0, MediaQuery.of(context).size.height * (1 - _animation.value)),
          child: Scaffold(
            backgroundColor: Colors.black,
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
              backgroundColor: Colors.black,
              elevation: 0,
            ),
            body: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            widget.query,
                            style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildSourcesSection()),
                      SliverToBoxAdapter(child: _buildAnswerSection()),
                      SliverToBoxAdapter(child: _buildImageSection()),
                      SliverToBoxAdapter(child: _buildSummaryCard()),
                      SliverToBoxAdapter(child: _buildRelatedSection()),
                    ],
                  ),
                ),
                _buildFollowUpInput(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourcesSection() {
    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.searchResults.length,
        itemBuilder: (context, index) {
          final result = widget.searchResults[index];
          return GestureDetector(
            onTap: () => _showSourceDetails(result),
            child: Container(
              width: 200,
              margin: EdgeInsets.only(right: 8, left: index == 0 ? 16 : 0),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          result['title'] ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          Uri.parse(result['url'] ?? '').host,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Answer',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (_images.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _images.isNotEmpty
                    ? _buildImage(_images[0])
                    : Container(
                        width: double.infinity,
                        color: Colors.grey[800],
                        child: Center(
                          child: Icon(Iconsax.image,
                              color: Colors.white70, size: 40),
                        ),
                      ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: EdgeInsets.only(left: 8, right: 16),
              children: _images.length > 1
                  ? _images.sublist(1).map((url) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImage(url),
                      );
                    }).toList()
                  : List.generate(4, (index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(Iconsax.image, color: Colors.white70),
                        ),
                      );
                    }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error');
        return Container(
          color: Colors.grey[800],
          child: Center(
            child: Icon(Iconsax.image, color: Colors.white70, size: 40),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[800],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Answer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isSpeaking ? Iconsax.volume_slash : Iconsax.volume_high,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _toggleSpeech(widget.summary),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              widget.summary,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildFollowUpInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _followUpController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask follow-up...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _performFollowUp(),
            ),
          ),
          IconButton(
            icon: Icon(_isListening ? Iconsax.microphone_2 : Iconsax.microphone,
                color: Colors.white),
            onPressed: _listen,
          ),
        ],
      ),
    );
  }

  void _showSourceDetails(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result['title'] ?? '',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                result['scrapedContent'] ?? 'No content available',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _launchURL(result['url']),
                child: Text('Visit Website'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() {
            _followUpController.text = result.recognizedWords;
            if (result.finalResult) {
              _isListening = false;
              _performFollowUp();
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _performFollowUp() {
    // TODO: Implement follow-up logic
    print('Performing follow-up: ${_followUpController.text}');
    _followUpController.clear();
  }

  Widget _buildRelatedSection() {
    if (_relatedQuestions.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey[800], thickness: 1, height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Related',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _relatedQuestions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                _relatedQuestions[index],
                style: TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing:
                  Icon(Iconsax.arrow_right_3, color: Colors.white70, size: 18),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              dense: true,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ThreadLoadingScreen(query: _relatedQuestions[index]),
                  ),
                );
                SearchService()
                    .performSearch(context, _relatedQuestions[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _fetchRelatedQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final groqApiKey = prefs.getString('groqApiKey') ?? '';

    if (groqApiKey.isEmpty) {
      print('Groq API key is not set');
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
                  'Query: ${widget.query}\n\nSummary: ${widget.summary}\n\nGenerate 4 short, related questions:'
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
          _relatedQuestions = questions
              .map((q) => q.replaceAll(RegExp(r'^\d+\.\s*'), ''))
              .toList();
        });
      } else {
        print('Failed to fetch related questions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching related questions: $e');
    }
  }

  Future<void> _fetchImages() async {
    final prefs = await SharedPreferences.getInstance();
    final braveApiKey = prefs.getString('braveApiKey') ?? '';

    if (braveApiKey.isEmpty) {
      print('Brave API key is not set');
      return;
    }

    final url = Uri.parse(
        'https://api.search.brave.com/res/v1/images/search?q=${Uri.encodeComponent(widget.query)}&count=5');

    try {
      final response = await http.get(
        url,
        headers: {'X-Subscription-Token': braveApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = List<Map<String, dynamic>>.from(data['results']);
        setState(() {
          _images = results
              .map((result) => result['thumbnail']['src'] as String)
              .where((url) => url != null && url.isNotEmpty)
              .toList();
        });
      } else {
        print('Failed to fetch images: ${response.statusCode}');
        // Optionally, you can set _images to an empty list or a list of placeholder image URLs
        setState(() {
          _images = [];
        });
      }
    } catch (e) {
      print('Error fetching images: $e');
      setState(() {
        _images = [];
      });
    }
  }

  // Create a method to load all data
  Future<void> _loadData() async {
    await _fetchRelatedQuestions();
    await _fetchImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data here instead of in initState
    _loadData();
  }
}
