import 'dart:convert';

import '../model/Node.dart';
import '../model/Character.dart';
import '../model/Trait.dart';

class PromptManipulator {
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

  static String _removeEmptyArrays(String jsonString) {
    var jsonObject = jsonDecode(jsonString);
    List<String> keys = List<String>.from(jsonObject.keys);
    for (String key in keys) {
      var value = jsonObject[key];
      if (value is List && value.isEmpty) {
        jsonObject.remove(key);
      }
    }
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
  Object Function(Map<String, dynamic> json) fromJson;
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