import 'dart:convert';
import 'dart:developer';

import 'package:plot_pixie/src/ai/ai_manager.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:plot_pixie/src/ai/model/work.dart';
import 'package:plot_pixie/src/ai/prompt/promp_manipulator.dart';
import 'package:retry/retry.dart';

class Pixie {
  static final Pixie _instance = Pixie._internal();

  final Work work = Work();

  factory Pixie() {
    return _instance;
  }

  Pixie._internal();

  void setIdea(Node idea){
    this.work.idea = idea;
  }

  void setCharacters(List<Node> characters){
    this.work.characters = characters;
  }

  Future<List<Node>> getIdeas(String prompt, {int numberOfIdeas = 5}) async {
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "generate $numberOfIdeas original screenplay ideas for $prompt. The description is the logline, make the title titillating. ",
        ReturnType.node,
        options: 'idea',
        isArray: true);
    log(decoratedPrompt);
    List<Node> ideas = await promptAiEngine(decoratedPrompt);
    return ideas;
  }

  Future<void>  generateActs() async {
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "Generate a 3 act hollywood screenplays for the following title: ${work.idea?.title ?? 'Untitled'} and logline; ${work.idea?.description ?? 'No logline available'}. Here are all the characters you must incorporate: ${jsonEncode(work.characters)}. Act descriptions are a high level idea of what is happening.",
        ReturnType.node,
        options: "act",
        isArray: true);
    log(decoratedPrompt);
    work.acts = await promptAiEngine(decoratedPrompt);
    await generateBeats();
  }

  Future<void>  generateBeats() async {
    List<List<String>> beats = [
      ["opening image", "theme started", "setup", "catalyst", "debate", "break into two"],
      [
        "b-story",
        "fun and games",
        "midpoint"
        "bad guys close in",
        "all is lost",
        "dark Night of the Soul",
        "break into 3"
      ],
      ['finale', 'final image'] // Act 3
    ];

    for (int act = 0; act < work.acts.length; act++) {
     work.acts[act].nodes =
          await Pixie().getBeats(act + 1, beats[act]);
    }
  }

  Future<List<Node>> getBeats(int actCount, List<String> beatTypes) async {
    String decoratedPrompt = PromptManipulator.decoratePrompt("""
             My screen play has the following title: ${work.idea?.title} and logline; ${work.idea?.description}. 
             The outline I has far is ${jsonEncode(work.acts)} 
             The characters are ${jsonEncode(work.characters)} 
             The beat title should be a master scene heading.
             The beat descriptions summarize the main actions and plot points in the beat. 
             There is no need for detailed character descriptions within the outline.
             
             In the beat, make explicit choices and outline specific details. For example, if there is choice to be made state the choice and make it. 
             
             For act ${actCount}, generate the following beats: ${beatTypes.join(",")}. They should correspond to the save the cat format and follow closely to what that type entails.
             
             Altogether, the plot within the beats should closely follow the act description and cover all points of this:
             
             ${work.acts[actCount-1].description}
              
             The plot point trait should be the type of the beat: for example {'type':'plot_point':, 'description': 'catalyst'}. 
             The outside_plot trait for each beat describes the beat in terms of the action/outside plot development for the central character. 
             The inside_plot trait describes in detail the beat in terms of the emotional/inside plot development for the central character. 
             The relational trait describes how relationships evolve between characters. 
             The philosophical trait describes details about the philosophical plot - try to come up with philosophical ideas and questions even if this is not evident.",
          """, ReturnType.node,
        options: "beat",
        isArray: true,
        traitType:
            'plot_point,outside_plot,inside_plot,relational,philosophical');
    log(decoratedPrompt);
    List<Node> beats = await promptAiEngine(decoratedPrompt);
    return beats;
  }

 Future< void> generateScenesForBeats() async {
    List<String> multiScene = [
      'setup', 'debate', 'fun and games', 'bad guys close in', 'dark night of the soul', 'finale'
    ];

    for (int act = 0; act < work.acts.length; act++) {
      for (int beat = 0; beat < work.acts[act].nodes.length; beat++) {
        work.acts[act].nodes[beat]?.nodes = await Pixie()
            .generateScenes(act, beat, multiScene);
      }
    }
  }

  Future<List<Node>> generateScenes(int act, int beat, List<String> multiScenes) async {
    bool isMultiScene = multiScenes.contains(work.acts[act].nodes[beat]?.getTrait("plot_point").toString());
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "For this idea: ${jsonEncode(work.idea)}, these characters ${jsonEncode(work.characters)} and this outline ${jsonEncode(work.acts)}, suggest ${ isMultiScene ? 'at least 4 scenes' : 'a scene' } for act ${act} and beat ${beat} that continues the details of the previous scenes and takes into account the act and beat details. The scene title should be a quick summary of what is happening and the description should show a high level detailed actions and important events in the scene. Don't generate any dialogue yet.",
        ReturnType.node,
        options: 'scene',
        isArray: true);
    log(decoratedPrompt);
    List<Node> scenes = await promptAiEngine(decoratedPrompt);
    return scenes;
  }

  void generateSceneContent() async {
    for (int act = 0; act < work.acts.length; act++) {
      for (int beat = 0; beat < work.acts[act].nodes.length; beat++) {
        for (int scene = 0;
        scene < work.acts[act].nodes[beat]!.nodes.length;
        beat++) {
          work.acts[act].nodes[beat]?.nodes[scene] = await Pixie()
              .generateScene(act, beat, scene);
        }
      }
    }
  }

  Future<Node> generateScene(
      int act, int beat, int numberOfScenes) async {
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "For this idea: ${jsonEncode(work.idea)}, these characters ${jsonEncode(work.characters)} and this outline ${jsonEncode(work.acts)}, generate a new node to replace the scene node, keep the title and description the same. Generate a well written screenplay scene that represents the details of the beat and the scene, taking into account all the previous dialogue and actions. Each line of dialogue should be an item in the trait array. Valid trait types are General, Scene Heading, Action, Character, Parenthetical, Dialogue, Transition and Shot.  ",
        ReturnType.node,
        options: 'scene',
        isArray: true);
    log(decoratedPrompt);
    List<Node> scenes = await promptAiEngine(decoratedPrompt);

    print(jsonEncode(scenes.first.traits));

    return scenes.first;
  }

  Future<String> generateText(
      Node idea, List<Node> characters, List<Node> outline) async {
    String prompt =
        "If this was a book, generate the prose in a vivid, active, show not tell dialogue and action heavy text for act 1 beat 2 of this outline: ${jsonEncode(outline)} . The title of the s is ${idea.title} and the characters are ${jsonEncode(characters)}";
    String text = await retry(() async {
      String? result = await AiManager().prompt("gemini", prompt);
      return result ?? "";
    }, retryIf: (e) => true, maxAttempts: 5);
    return text;
  }

  Future<String> transformText(String requestedText, String prompt) async {
    String request = '$prompt this text: $requestedText ';
    String text = await retry(() async {
      String? result = await AiManager().prompt("mistral", request);
      return result ?? "";
    }, retryIf: (e) => true, maxAttempts: 5);
    return text;
  }

  Future<List<Node>> getCharacterSuggestions(
      {int numberOfCharacters = 5,
      List<Node> existingCharacters = const []}) async {
    String options =
        'guilty pleasure,catchphrase,quirks,pet peeves,favorite quote,strangest dream,embarrassing memory,weird habit,ideal weekend,bucket list item,guilty pleasure,lucky charm,hidden talent,dream vacation,deepest secret,strange hobby, proudest achievement, best childhood memory';
    String existing = (existingCharacters.length > 0)
        ? "I already have these characters: ${summarizeRoles(existingCharacters)}, Don't repeat any names or professions from this list.  "
        : '';
    String prompt =
        "My story has this title: '${work.idea?.title}' and this logline: '${work.idea?.description}'. $existing. Who are the other protagonists, antagonists, minor characters and supporting characters? Imagine $numberOfCharacters other characters for the story.  title should be 'first name, age, occupation'. The description is a detailed 3 paragraph backstory in the character's own voice without mentioning any other characters. Generate 4 to 6 traits. A mandatory trait is appearance. Other traits are unique and obscure information about the character. trait types must be in this list: ' $options '. ";
    log(prompt);
    List<Node> characters =
        await promptAiEngine(prompt, returnType: ReturnType.character);
    return characters;
  }

  Future<List<Node>> promptAiEngine(String prompt,
      {ReturnType returnType = ReturnType.node}) async {
    String decoratedPrompt =
        PromptManipulator.decoratePrompt(prompt, returnType, isArray: true);

    List<Node> nodes = await retry(() async {
      String? result = await AiManager().prompt("gemini", decoratedPrompt);
      List<Node> nodes = List<Node>.from(
          PromptManipulator.convertResult(result, returnType, true));
      return nodes;
    }, retryIf: (e) => true, maxAttempts: 5);
    return nodes;
  }

  String summarizeRoles(List<Node> nodes) {
    return '[${nodes.map((node) => '${node.title}').join('; ')}]';
  }
}
