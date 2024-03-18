import 'dart:convert';
import 'dart:developer';

import 'package:plot_pixie/src/ai/ai_manager.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:plot_pixie/src/ai/prompt/promp_manipulator.dart';
import 'package:retry/retry.dart';

class Pixie {
  static final Pixie _instance = Pixie._internal();

  factory Pixie() {
    return _instance;
  }

  Pixie._internal();

  Future<List<Node>> getIdeas(String prompt, {int numberOfIdeas = 5 }) async{
    if(prompt.isEmpty){
      prompt = "stories in different genres ";
    }
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "generate $numberOfIdeas story ideas for $prompt . Title should be a creative name for the idea and the description should be the logline"
        , ReturnType.node, options:'idea', isArray: true);
    log(decoratedPrompt);
    List<Node> ideas = await promptAiEngine(decoratedPrompt);
    return ideas;
  }

  Future<List<Node>> getCharacterSuggestions(Node idea,
      {int numberOfCharacters = 5,
      List<Node> existingCharacters = const []}) async {
    String options =
        'guilty pleasure,catchphrase,quirks,pet peeves,favorite quote,strangest dream,embarrassing memory,weird habit,ideal weekend,bucket list item,guilty pleasure,lucky charm,hidden talent,dream vacation,deepest secret,strange hobby, proudest achievement, best childhood memory';
    String existing = (existingCharacters.length > 0)
        ? "Besides these characters: ${summarizeRoles(existingCharacters)}, "
        : '';
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "My story has this title: '${idea.title}' and this logline: '${idea.description}'. $existing. Who are the other protagonists, antagonists, minor characters and supporting characters? Imagine $numberOfCharacters other characters for the story.  title should be 'first name, age, occupation'. The description is a detailed 3 paragraph backstory in the character's own voice. Don't talk about others. Generate 4 to 6 traits. Traits are unique and obscure information about the character. trait types must be in this list: ' $options '. ",
        ReturnType.character,
        isArray: true);

    log(decoratedPrompt);
    List<Node> characters = await promptAiEngine(decoratedPrompt);
    return characters;
  }

  Future<List<Node>> promptAiEngine(String decoratedPrompt) async {
       // Wrap the call in a retry function with conversion logic
    List<Node> characters = await retry(() async {
      String? result = await AiManager().prompt("gemini", decoratedPrompt);
      List<Node> characters = List<Node>.from(
          PromptManipulator.convertResult(result, ReturnType.character, true));
      return characters;
    }, retryIf: (e) => true, maxAttempts: 5);
    return characters;
  }

  String summarizeRoles(List<Node> nodes) {
    return nodes.map((node) => '${node.title}').join('; ');
  }
}

void main() async {
  final List<Node> ideas = await Pixie().getIdeas("");

  ideas.forEach((idea) {
    print(idea.toJson());
  });

  final List<Node> darkSatires = await Pixie().getIdeas("a dark satire of a well known story");
  darkSatires.forEach((book) {
    print(book.toJson());
  });

  List<Node> characters =
      await Pixie().getCharacterSuggestions(darkSatires[0], numberOfCharacters: 5);
  characters.forEach((character) {
    print(character.toJson());
  });

}
