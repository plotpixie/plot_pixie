import 'package:plot_pixie/src/ai/providers/gemini/gemini.dart';
import 'package:plot_pixie/src/ai/providers/openrouter/open_router.dart';

import 'ai_engine.dart';

class AiManager {
  static final AiManager _instance = AiManager._privateConstructor();

  final Map<String, AiEngine> _engines = {};

  AiManager._privateConstructor() {
     _engines['gemini'] = Gemini();
     _engines['mistral'] = OpenRouter('mistralai/mistral-7b-instruct:free'); // tendency to return individual JSON arrays. Results not well formed.
    /*
      _engines['mythomist'] = OpenRouter('gryphe/mythomist-7b:free'); // doesn't seem to handle number of characters very well, otherwise pretty solid
      _engines['cinematika'] = OpenRouter('openrouter/cinematika-7b:free');
      _engines['capybara'] = OpenRouter('nousresearch/nous-capybara-7b:free'); // seeing issues with rendering traits in characters.
      _engines['gemma'] = OpenRouter('google/gemma-7b-it:free');
*/
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
