import 'package:plot_pixie/src/ai/providers/gemini/gemini.dart';

import 'ai_engine.dart';

class AiManager {
  static final AiManager _instance = AiManager._privateConstructor();

  final Map<String, AiEngine> _engines = {};

  AiManager._privateConstructor() {
    _engines['gemini'] = Gemini();
  }

  factory AiManager() {
    return _instance;
  }

  Future<String?> prompt(String engineName, String prompt) async {
    AiEngine? engine = _engines[engineName];
    if (engine != null) {
      return await engine.prompt(prompt);
    } else {
      throw Exception('AI engine $engineName not found');
    }
  }
}
