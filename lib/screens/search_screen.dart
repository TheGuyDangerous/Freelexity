import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/web_scraper_service.dart';
import '../services/groq_api_service.dart';
import 'thread_screen.dart';
import 'thread_loading_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../custom_page_route.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart'; // Add this import
import '../services/search_service.dart'; // Add this import
import '../services/whisper_service.dart'; // Add this import
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart'; // Add this import
import 'package:fluttertoast/fluttertoast.dart'; // Add this import

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WebScraperService _webScraperService = WebScraperService();
  final GroqApiService _groqApiService = GroqApiService();
  final SearchService _searchService = SearchService();
  final WhisperService _whisperService = WhisperService();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _useWhisperModel = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  final _audioRecorder =
      AudioRecorder(); // Changed from Record() to AudioRecorder()
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeSpeech();
    _initializeTts();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useWhisperModel = prefs.getBool('useWhisperModel') ?? false;
    });
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (errorNotification) => print('onError: $errorNotification'),
    );
    if (!available) {
      print("The user has denied the use of speech recognition.");
    }
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildInitialView()),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: _buildSearchBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 100,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 48), // To balance the layout
          Text(
            "Freelexity",
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16), // Added right padding
            child: IconButton(
              icon: Icon(Iconsax.export, color: Colors.white),
              onPressed: _shareApp,
            ),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    Clipboard.setData(ClipboardData(
      text:
          "Try Freelexity:\nhttps://www.github.com/TheGuyDangerous/Freelexity",
    )).then((_) {
      Fluttertoast.showToast(
        msg: "Share link copied to clipboard",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250, // Increased from 200
            height: 250, // Increased from 200
            child: Lottie.asset(
              'assets/loading_animation.json',
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ),
          SizedBox(height: 24), // Increased from 16
          Text(
            'An Open Source Answer Engine',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 18, // Increased from 16
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          IconButton(
            icon: Icon(
              _isListening
                  ? Iconsax.stop_circle
                  : (_useWhisperModel
                      ? Iconsax.microphone_2
                      : Iconsax.microphone),
              color: Colors.white,
            ),
            onPressed: _toggleListening,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() => _isListening = true);

    if (_useWhisperModel) {
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordingPath = '$tempPath/$fileName';

      await _audioRecorder.start(RecordConfig(), path: _recordingPath!);
    } else {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );
      if (available) {
        _speech.listen(
          onResult: (result) => setState(() {
            _searchController.text = result.recognizedWords;
          }),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    setState(() => _isListening = false);

    if (_useWhisperModel) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        final bytes = await file.readAsBytes();

        try {
          final transcription = await _whisperService.transcribeAudio(bytes);
          setState(() {
            _searchController.text = transcription;
          });
          _performSearch();
        } catch (e) {
          print('Error transcribing audio: $e');
        }

        await file.delete();
      }
    } else {
      _speech.stop();
      _performSearch();
    }
  }

  Future<String> _getGroqApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('groqApiKey') ?? '';
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      // Don't perform search if the query is empty
      return;
    }

    // Open ThreadLoadingScreen immediately
    Navigator.of(context).push(
      CustomPageRoute(
        child: ThreadLoadingScreen(query: _searchController.text),
      ),
    );

    // Perform the search using SearchService
    await _searchService.performSearch(context, _searchController.text);
  }

  String _preprocessContent(String content) {
    // Remove extra whitespace and limit to first 1000 characters
    return content
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .substring(0, min(1000, content.length));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _speech.cancel();
    _flutterTts.stop();
    _audioRecorder.dispose();
    super.dispose();
  }
}
