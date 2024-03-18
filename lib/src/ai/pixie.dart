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

  Future<List<Node>> getOutline(Node idea, List<Node> characters) async{
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "Generate a 3 act hollywood outline for the following title: ${idea.title} and logline; ${idea.description}. Here are all the characters you must incorporate: ${jsonEncode(characters)}."
        , ReturnType.node, options: "act,beat", isArray: true);
    log(decoratedPrompt);
    List<Node> acts = await promptAiEngine(decoratedPrompt);
    return acts;
  }

  Future<String> generateText(Node idea, List<Node> characters, List<Node> outline) async{
    String prompt = "If this was a book, generate the prose in a vivid, active, show not tell dialogue and action heavy text for act 1 beat 2 of this outline: ${jsonEncode(outline)} . The title of the s is ${idea.title} and the characters are ${jsonEncode(characters)}";
    String text = await retry(() async {
      String? result = await AiManager().prompt("gemini", prompt);
      return result??"";
    }, retryIf: (e) => true, maxAttempts: 5);
    return text;
  }

  Future<String> transformText(String requestedText, String prompt) async{
    String request = '$prompt this text: $requestedText ';
    String text = await retry(() async {
      String? result = await AiManager().prompt("mistral", request);
      return result??"";
    }, retryIf: (e) => true, maxAttempts: 5);
    return text;
  }

  Future<List<Node>> getCharacterSuggestions(Node idea,
      {int numberOfCharacters = 5,
      List<Node> existingCharacters = const []}) async {
    String options =
        'guilty pleasure,catchphrase,quirks,pet peeves,favorite quote,strangest dream,embarrassing memory,weird habit,ideal weekend,bucket list item,guilty pleasure,lucky charm,hidden talent,dream vacation,deepest secret,strange hobby, proudest achievement, best childhood memory';
    String existing = (existingCharacters.length > 0)
        ? "Besides these characters: ${summarizeRoles(existingCharacters)}, "
        : '';
    String prompt =
        "My story has this title: '${idea.title}' and this logline: '${idea.description}'. $existing. Who are the other protagonists, antagonists, minor characters and supporting characters? Imagine $numberOfCharacters other characters for the story.  title should be 'first name, age, occupation'. The description is a detailed 3 paragraph backstory in the character's own voice. Don't talk about others. Generate 4 to 6 traits. Traits are unique and obscure information about the character. trait types must be in this list: ' $options '. ";
    List<Node> characters = await promptAiEngine(prompt, returnType: ReturnType.character);
    return characters;
  }

  Future<List<Node>> promptAiEngine(String prompt, {ReturnType returnType = ReturnType.node}) async {
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        prompt,
        returnType,
        isArray: true);

    List<Node> nodes = await retry(() async {
      String? result = await AiManager().prompt("gemini", decoratedPrompt);
      List<Node> nodes = List<Node>.from(
          PromptManipulator.convertResult(result, returnType, true));
      return nodes;
      }, retryIf: (e) => true, maxAttempts: 5);
    return nodes;
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

  final List<Node> darkSatires = await Pixie().getIdeas("a dark satire combining a beloved children franchise with a more adult-oriented concept it is not normally associated with");
  darkSatires.forEach((book) {
    print(book.toJson());
  });

  List<Node> characters =
      await Pixie().getCharacterSuggestions(darkSatires[0], numberOfCharacters: 5);
  characters.forEach((character) {
    print(character.toJson());
  });

  List<Node> acts =
  await Pixie().getOutline(darkSatires[0], characters);
  acts.forEach((act) {
    print(act.toJson());
  });

  String scene = await Pixie().generateText(darkSatires[0], characters, acts);

  print(scene);

  String newScene = await Pixie().transformText(scene, 'make it longer, funnier and add some references to a unknown cosmic horror');

  print(newScene);


}
