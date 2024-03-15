import 'dart:io' show Platform;

import 'package:google_generative_ai/google_generative_ai.dart';

class Gemini {
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

  Future<String?> prompt(String prompt, {int maxRetries = 5}) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        if (chat != null) {
          var response = await chat?.sendMessage(Content.text(prompt));
          return response?.text;
        } else {
          break;
        }
      } catch (e) {
        attempt++;
        if (e.toString() == "Candidate was blocked due to safety") {
          chat = model?.startChat(history: []);
        }
        print('Attempt $attempt failed with error: $e');
        if (attempt == maxRetries) {
          print('Max retries reached. Throwing error.');
          rethrow;
        }
      }
    }
    return null;
  }
}
