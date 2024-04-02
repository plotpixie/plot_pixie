import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:plot_pixie/src/ai/ai_engine.dart';

import '../../../env/env.dart';

class Gemini extends AiEngine {
  GenerativeModel? model;
  ChatSession? session;

  Gemini._privateConstructor() {
    const apiKey = Env.GEMINI_KEY;
    model =
        GenerativeModel(model: 'gemini-pro', apiKey: apiKey, safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
    ]);
    session = model?.startChat(history: []);
  }

  static final Gemini _instance = Gemini._privateConstructor();

  factory Gemini() {
    return _instance;
  }

  @override
  Future<String?> prompt(String prompt) async {
    try {
      var response = await model?.generateContent([Content.text(prompt)]);
      return response?.text;
    } catch (e) {
      log('Failed with error: $e');
      rethrow;
    }
  }

  @override
  Future<String?> chat(String prompt, [bool reset = false]) async {
    try {
      session ??= model?.startChat(history: []);
      var response = await session?.sendMessage(Content.text(prompt));
      return response?.text;
    } catch (e) {
      if (e.toString() == "Candidate was blocked due to safety") {
        session = model?.startChat(history: []);
      }
      log('Failed with error: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetChat() async {
    session = model?.startChat(history: []);
  }
}
