import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

Future<void> initializeSpeech(stt.SpeechToText speech) async {
  bool available = await speech.initialize();
  if (!available) {
    debugPrint("The user has denied the use of speech recognition.");
  }
}

Future<void> initializeTts(FlutterTts flutterTts) async {
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1.0);
  await flutterTts.setSpeechRate(0.5);
}
