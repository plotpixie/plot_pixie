import 'dart:developer';
import 'dart:io' show Platform;

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:plot_pixie/src/ai/AiEngine.dart';

class Gemini extends AiEngine {
  GenerativeModel? model;
  ChatSession? chat;

  Gemini._privateConstructor() {
    final apiKey = Platform.environment['GEMINI_KEY'] ?? 'default_key';
    model =
        GenerativeModel(model: 'gemini-pro', apiKey: apiKey, safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
    ]);
    chat = model?.startChat(history: []);
  }

  static final Gemini _instance = Gemini._privateConstructor();

  factory Gemini() {
    return _instance;
  }

  @override
  Future<String?> prompt(String prompt) async {
    try {
      if (chat != null) {
        var response = await chat?.sendMessage(Content.text(prompt));
        return response?.text;
      }
    } catch (e) {
      if (e.toString() == "Candidate was blocked due to safety") {
        chat = model?.startChat(history: []);
      }
      log('Failed with error: $e');
      rethrow;
    }
    return null;
  }
}