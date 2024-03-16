import 'dart:convert';
import 'dart:developer';

import 'package:retry/retry.dart';

import 'package:plot_pixie/src/ai/ai_manager.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:plot_pixie/src/ai/prompt/promp_manipulator.dart';

class Pixie {
  static final Pixie _instance = Pixie._internal();

  factory Pixie() {
    return _instance;
  }

  Pixie._internal();
  Future<List<Node>> getCharacterSuggestions(Node idea,
      {int numberOfCharacters = 5, List<Node> approvedCharacters = const[], List<Node> rejectedCharacters = const[]}) async {

    String options = 'guilty pleasure,catchphrase,quirks,pet peeves,favorite quote,strangest dream,embarrassing memory,weird habit,ideal weekend,bucket list item,guilty pleasure,lucky charm,hidden talent,dream vacation,deepest secret,strange hobby, proudest achievement, best childhood memory';
    String approved = ( approvedCharacters.length > 0 ) ? "Besides these characters: ${ summarizeRoles(approvedCharacters) }, " : '';
    String rejected = '';
    String decoratedPrompt = PromptManipulator.decoratePrompt("My story has this title: '${idea.title}' and this logline: '${idea.description}'. $approved. Who are the other protagonists, antagonists, minor characters and supporting characters? Imagine $numberOfCharacters other characters for the story.  title should be 'first name, age, occupation'. The description is a detailed 3 paragraph backstory in the character's own voice. Don't talk about others. Generate 4 to 6 traits. Traits are unique and obscure information about the character. trait types must be in this list: ' $options '. " , ReturnType.character, isArray: true);

    log(decoratedPrompt);

    // Wrap the call in a retry function with conversion logic
    List<Node> characters = await retry(
            () async {
          String? result = await AiManager().prompt("gemini", decoratedPrompt);
          List<Node> characters = List<Node>.from(PromptManipulator.
          convertResult(result, ReturnType.character, true));
          return characters;
        },
        retryIf: (e) => true,
        maxAttempts: 5
    );

    return characters;
  }

  String summarizeRoles(List<Node> nodes) {
    return nodes.map((node) => '${node.title}').join('; ');
  }

}

void main() async {
  final Node idea = Node("idea", "The Light Keepers", "A remote lighthouse manned by a reclusive lighthouse keeper becomes the beacon of a strange phenomenon: a lighthouse that seems to attract mythical creatures drawn to its light.");
  List<Node> characterList = await Pixie().getCharacterSuggestions(idea, numberOfCharacters: 2);

  print(jsonEncode(characterList));

  List<Node> characterList2 = await Pixie().getCharacterSuggestions(idea, approvedCharacters: characterList);

  print(jsonEncode(characterList2));

  List<Node> characterList3 = await Pixie().getCharacterSuggestions(idea, approvedCharacters: characterList, rejectedCharacters: characterList2);

  print(jsonEncode(characterList3));

  List<Node> characterList4 = await Pixie().getCharacterSuggestions(idea, approvedCharacters: characterList + characterList3, rejectedCharacters: characterList2);

  print(jsonEncode(characterList4));

}