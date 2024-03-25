import 'dart:convert';

import '../model/node.dart';
import '../model/trait.dart';

enum ReturnType { node, trait, character }

class PromptManipulator {
  static Node _generateNodeStructure(List<String> types, String traitType) {
    if (types.isEmpty) {
      throw ArgumentError('Types cannot be empty');
    }
    List<Trait> traits = [];
    if (types.length == 1) {
      traitType.split(',').forEach((element) {
        if (!element.isEmpty) {
          traits.add(Trait(element, ''));
        }
      });
    }
    return Node(
        types.first,
        '',
        '',
        types.length > 1
            ? [_generateNodeStructure(types.sublist(1), traitType)]
            : [],
        types.length > 1 ? [] : traits);
  }

  static String _getNodeRepresentation(List<String> types, String traitType) {
    return _removeEmptyArrays(
        jsonEncode(_generateNodeStructure(types, traitType).toJson()));
  }

  static String _getCharacterRepresentation() {
    return _removeEmptyArrays(jsonEncode(
        Node('character', 'name', 'description', [], [Trait('age', '')])
            .toJson()));
  }

  static String _getSceneRepresentation() {
    return _removeEmptyArrays(jsonEncode(Node('scene', 'scene title',
        'plot description', [], [Trait('sceneHeading', '')]).toJson()));
  }

  static String _isArray(String s, bool isArray) {
    return isArray ? '[$s]' : s;
  }

  static String decoratePrompt(String text, ReturnType returnType,
      {String options = '', bool isArray = false, String traitType = ''}) {
    String decorated =
        '$text. Return well-formed JSON and escape any characters that need escaping. Results are one single JSON array. OUTPUT FORMAT: ';

    switch (returnType) {
      case ReturnType.node:
        if (options.isEmpty) {
          options = 'idea';
        }
        decorated += _isArray(
            (_getNodeRepresentation(options.split(','), traitType)), isArray);
      case ReturnType.character:
        decorated += _isArray(_getCharacterRepresentation(), isArray) +
            '. Be specific. Instead of <character> has a habit of humming to herself when she\'s happy in the trait details prefer shorter sentences like hums to herself when happy. Do not return integer values in fields. Trait descriptions must always be a string.';
        break;
      case ReturnType.trait:
        // Handle Trait case if necessary
        break;
    }
    return decorated;
  }

  static String _removeEmptyArrays(String jsonString) {
    var jsonObject = jsonDecode(jsonString);
    jsonObject.removeWhere((key, value) => value is List && value.isEmpty);
    return jsonEncode(jsonObject);
  }

  static String _convertPropertiesToString(String jsonString) {
    return jsonEncode(_stringifyValues(jsonDecode(jsonString)));
  }

  static Object _stringifyValues(dynamic item) {
    if (item is Map) {
      item.forEach((key, value) {
        item[key] = _stringifyValues(value);
      });
      return item;
    } else if (item is List) {
      return item.map((value) => _stringifyValues(value)).toList();
    } else {
      return item.toString();
    }
  }

  static dynamic convertResult(
      String? text, ReturnType returnType, bool isArray) {
    if (text != null && text.startsWith('```json') && text.endsWith('```')) {
      text = text.substring(7, text.length - 3).trim();
    }
    text = _convertPropertiesToString(text!);
    return decodeJson(returnType, text, isArray);
  }
}

dynamic decodeJson(ReturnType returnType, String text, bool isArray) {
  Object Function(Map<String, dynamic> json) fromJson;
  switch (returnType) {
    case ReturnType.trait:
      fromJson = Trait.fromJson;
      break;
    default:
      fromJson = Node.fromJson;
      break;
  }

  if (isArray) {
    return (jsonDecode(text) as List).map((item) => fromJson(item)).toList();
  } else {
    return fromJson(jsonDecode(text));
  }
}
