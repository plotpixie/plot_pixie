import 'dart:developer';

import '../../../env/env.dart';
import '../../ai_engine.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouter extends AiEngine {
  String _modelName = "";
  String _apiKey = "";

  OpenRouter(String modelName) {
    _modelName = modelName;
    _apiKey = Env.OPENROUTER_API_KEY;
  }

  @override
  Future<String?> prompt(String prompt) async {
    var url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    var headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    var body = jsonEncode({
      'model': _modelName,
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
    });

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['choices'][0]['message']['content'];
    } else {
      log('Request failed with status: ${response.statusCode}.');
    }
  }
}
