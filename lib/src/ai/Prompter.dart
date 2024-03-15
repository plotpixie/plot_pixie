import 'dart:convert';

import 'package:plot_pixie/src/model/Character.dart';
import 'package:plot_pixie/src/model/Node.dart';
import 'package:plot_pixie/src/model/Trait.dart';

import 'gemini/Gemini.dart';

class Prompter {
  static Node _generateNodeStructure(List<String> types) {
    return Node(types[0], "", "",
        types.length > 1 ? [_generateNodeStructure(types.sublist(1))] : []);
  }

  static dynamic _getNodeRepresentation(List<String> types) {
    return jsonEncode(_generateNodeStructure(types).toJson());
  }

  static dynamic _getCharacterRepresentation() {
    return jsonEncode(Character("", "", "", "", [Trait("age", "")]).toJson());
  }

  static String _isArray(String s, bool isArray) {
    return (isArray ? "[" : "") + s + (isArray ? "]" : "");
  }

  static String decoratePrompt(String text, String returnType,
      {String options = "", bool isArray = false}) {
    String decorated =
        "$text . Return well formed JSON and escape any characters that need escaping. OUTPUT FORMAT: ";

    if (returnType == 'Node') {
      if (options.isEmpty) {
        options = "outline,act,beat";
      }
      decorated +=
          _isArray(_removeEmptyArrays(_getNodeRepresentation(options.split(","))), isArray);
    } else if (returnType == 'Character') {
      if (options.isEmpty) {
        options =
            "guilty pleasure, catchphrase, quirks, pet peeves, favorite quote, strangest dream, embarrassing memory, weird habit,  ideal weekend, bucket list item, guilty pleasure, lucky charm, hidden talent, dream vacation, deepest secret, strange hobby";
      }
      decorated +=
          "${_isArray(_getCharacterRepresentation(), isArray)}. Give them a name and short blurb and 8 random unique traits specific to the character. Trait options are a random item from $options . Be specific. Instead of <character> has a habit of humming to herself when she's happy in the trait details prefer shorter sentences like hums to herself when happy ";
    }
    return decorated;
  }

static  String _removeEmptyArrays(String jsonString) {
  var jsonObject = jsonDecode(jsonString);
  jsonObject.forEach((key, value) {
    if (value is List && value.isEmpty) {
      jsonObject.remove(key);
    }
  });
  return jsonEncode(jsonObject);
}

  static dynamic convertResult(String? text, String returnType, bool isArray) {
    if (text != null && text.startsWith('```json') && text.endsWith('```')) {
      text = text.substring(7, text.length - 3);
    }
    return decodeJson(returnType, text ?? "", isArray);
  }
}

dynamic decodeJson(String returnType, String text, bool isArray) {
  var fromJson;
  switch (returnType) {
    case 'Node':
      fromJson = Node.fromJson;
      break;
    case 'Trait':
      fromJson = Trait.fromJson;
      break;
    case 'Character':
      fromJson = Character.fromJson;
      break;
    default:
      throw Exception('Invalid returnType: $returnType');
  }

  if (isArray) {
    return (jsonDecode(text) as List).map((item) => fromJson(item)).toList();
  } else {
    return fromJson(jsonDecode(text));
  }
}

void main() async {
  /*
  var prompt = Prompter.decoratePrompt("Generate an idea about a play regarding what it means to be in love", "Node", options:"idea", isArray:false);
  print(prompt);
  var result = await Gemini().prompt(prompt);
  var parsedResult = Prompter.convertResult(result, "Node", false);
  print(jsonEncode((parsedResult as Node).toJson()));
 */

  var prompt = Prompter.decoratePrompt(
      "We're in a far away galaxy where people are human dinosaur hybrids, tell me about 4 different characters in the story.",
      "Character",
      isArray: true);
  print(prompt);
  var parsedResult =
      Prompter.convertResult(await Gemini().prompt(prompt), "Character", true);
  for (var character in parsedResult) {
    print(jsonEncode((character as Character).toJson()));
  }
}
