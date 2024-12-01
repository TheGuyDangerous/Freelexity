import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../services/whisper_service.dart';
import '../../utils/audio_helpers.dart';
import '../../utils/clipboard_helper.dart';
import '../../widgets/search/search_app_bar.dart';
import '../../widgets/search/search_initial_view.dart';
import '../../widgets/search/search_bar.dart';
import 'search_screen.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../screens/thread/thread_loading_screen.dart';
import '../../utils/constants.dart';

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WhisperService _whisperService = WhisperService();
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _useWhisperModel = false;
  final _audioRecorder = AudioRecorder();
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    await initializeSpeech(_speech);
    await initializeTts(_flutterTts);
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useWhisperModel = prefs.getBool('useWhisperModel') ?? false;
    });
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
      bool available = await _speech.initialize();
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
          debugPrint('Error transcribing audio: $e');
        }

        await file.delete();
      }
    } else {
      _speech.stop();
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ThreadLoadingScreen(query: _searchController.text),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  void _shareApp() {
    copyToClipboard(
      "Try ${AppConstants.appName}:\n${AppConstants.githubUrl}",
      message: "Share link copied to clipboard",
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: SearchAppBar(onSharePressed: _shareApp),
      body: Column(
        children: [
          Expanded(child: SearchInitialView()),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: CustomSearchBar(
              controller: _searchController,
              isListening: _isListening,
              useWhisperModel: _useWhisperModel,
              onSubmitted: (_) => _performSearch(),
              onListenPressed: _toggleListening,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.cancel();
    _flutterTts.stop();
    _audioRecorder.dispose();
    super.dispose();
  }
}
