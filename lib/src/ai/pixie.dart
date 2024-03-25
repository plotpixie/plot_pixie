import 'dart:convert';
import 'dart:developer';

import 'package:plot_pixie/src/ai/ai_manager.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:retry/retry.dart';

import 'model/trait.dart';

class Pixie {
  static final Pixie _instance = Pixie._internal();

  factory Pixie() {
    return _instance;
  }

  Pixie._internal();

  Future<List<Node>> getIdeas(String prompt, {int numberOfIdeas = 5}) async {
    List<Node> ideas = await promptAiEngine(
        "generate $numberOfIdeas original screenplay ideas for $prompt. description is the logline. ", 'idea');
    return ideas;
  }

/*
  Future<List<Node>> getActs(Node idea, List<Node> characters) async {
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "Generate a 3 act hollywood screenplays for the following title: ${idea.title} and logline; ${idea.description}. Here are all the characters you must incorporate: ${jsonEncode(characters)}. Act descriptions are a high level idea of what is happening.",
        ReturnType.node,
        options: "act",
        isArray: true);
    log(decoratedPrompt);
    List<Node> acts = await promptAiEngine(decoratedPrompt);
    acts = await generateBeats(idea, characters, acts);
    return acts;
  }

  Future<List<Node>> generateBeats(
      Node idea, List<Node> characters, List<Node> acts) async {
    List<List<String>> beats = [
      ["Opening image", "theme started", "setup", "catalyst", "debate"],
      [
        "break into two",
        "B-story",
        "fun and games",
        "midpoint",
        "bad guys close in",
        "all is lost",
        "Dark Night of the Soul",
      ],
      ["break into 3", 'finale', 'final image'] // Act 3
    ];

    for (int act = 0; act < acts.length; act++) {
      acts[act].nodes =
          await Pixie().getBeats(idea, characters, acts, act + 1, beats[act]);
    }
    return acts;
  }

  Future<List<Node>> getBeats(Node idea, List<Node> characters, List<Node> acts,
      int actCount, List<String> beatTypes) async {
    String decoratedPrompt = PromptManipulator.decoratePrompt("""
             My screen play has the following title: ${idea.title} and logline; ${idea.description}. 
             The outline I has far is ${jsonEncode(acts)} 
             The characters are ${jsonEncode(characters)}
             Generate the following beats for element ${actCount} of this array, it should be act ${actCount}: ${jsonEncode(acts)}. 
             The beat title should be a master scene heading.
             The beat descriptions summarize the main actions and plot points in the beat. 
             There is no need for detailed character descriptions within the outline.
             For act ${actCount}, generate all of the following beats: ${beatTypes.join(",")}.
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

  Future<List<Node>> generateScenesForBeats(
      Node idea, List<Node> characters, List<Node> acts) async {
    List<List<int>> sceneCounts = [
      [1, 1, 3, 1, 8], // Act 1
      [1, 3, 9, 1, 7, 1, 6], // Act 2
      [1, 10, 3] // Act 3
    ];

    for (int act = 0; act < sceneCounts.length; act++) {
      for (int beat = 0; beat < sceneCounts[act].length; beat++) {
        int scenes = sceneCounts[act][beat];
        acts[act].nodes[beat]?.nodes = await Pixie()
            .generateScenes(idea, characters, acts, act, beat, scenes);
      }
    }
    return acts;
  }

  Future<List<Node>> generateSceneContent(
      Node idea, List<Node> characters, List<Node> acts) async {
    for (int act = 0; act < acts.length; act++) {
      for (int beat = 0; beat < acts[act].nodes.length; beat++) {
        for (int scene = 0;
            scene < acts[act].nodes[beat]!.nodes.length;
            beat++) {
          acts[act].nodes[beat]?.nodes[scene] = await Pixie()
              .generateScene(idea, characters, acts, act, beat, scene);
        }
      }
    }
    return acts;
  }

  Future<List<Node>> generateScenes(Node idea, List<Node> characters,
      List<Node> acts, int act, int beat, int numberOfScenes) async {
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "For this idea: ${jsonEncode(idea)}, these characters ${jsonEncode(characters)} and this outline ${jsonEncode(acts)}, generate $numberOfScenes scenes for act ${act} and beat ${beat}. The scene title should be a quick summary of what is happening and the description should show a high level detailed actions and important events in the scene. Don't generate any dialogue yet.",
        ReturnType.node,
        options: 'scene',
        isArray: true);
    log(decoratedPrompt);
    List<Node> scenes = await promptAiEngine(decoratedPrompt);
    return scenes;
  }

  Future<Node> generateScene(Node idea, List<Node> characters, List<Node> acts,
      int act, int beat, int numberOfScenes) async {
    String decoratedPrompt = PromptManipulator.decoratePrompt(
        "For this idea: ${jsonEncode(idea)}, these characters ${jsonEncode(characters)} and this outline ${jsonEncode(acts)}, generate a new node to replace the scene node, keep the title and description the same. Generate a well written screenplay scene that represents the details of the beat and the scene, taking into account all the previous dialogue and actions. Each line of dialogue should be an item in the trait array. Valid trait types are General, Scene Heading, Action, Character, Parenthetical, Dialogue, Transition and Shot.  ",
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
*/
  Future<List<Node>> getCharacterSuggestions(Node idea,
      {int numberOfCharacters = 5,
      List<Node> existingCharacters = const []}) async {
    String options =
        'guilty pleasure,catchphrase,quirks,pet peeves,favorite quote,strangest dream,embarrassing memory,weird habit,ideal weekend,bucket list item,guilty pleasure,lucky charm,hidden talent,dream vacation,deepest secret,strange hobby, proudest achievement, best childhood memory';
    String existing = (existingCharacters.length > 0)
        ? "I already have these characters: ${summarizeRoles(existingCharacters)}, Don't repeat any names or professions from this list.  "
        : '';

    String prompt =
        "Generate $numberOfCharacters characters / lines. Story title is: '${idea.title}' with logline: '${idea.description}'. $existing. Characters can be protagonists, antagonists, minor characters and supporting characters. Imagine $numberOfCharacters other characters for the story. For each of these characters, generate a list of traits. mandatory traits are name, age, occupation, appearance, profile. profile is detailed 3 paragraph backstory in the character's own voice without mentioning any other characters. Add additional fun facts traits and pick 6 different answers for each character from this list: ' $options '. ";
    List<List<Trait>> traits =
        await promptAiEngine(prompt, 'person', returnType: ReturnType.trait);

    List<Node> characterSuggestions = traits.map((traitList) {
      String title = traitList
          .where((trait) =>
      trait.type == 'name' || trait.type == 'age' || trait.type == 'occupation')
          .map((trait) => trait.description)
          .join(', ');

      String description = traitList
          .firstWhere((trait) => trait.type == 'profile', orElse: () => Trait('', ''))
          .description;

      return Node('character', title, description, [], traitList);
    }).toList();

    return characterSuggestions;
  }

  Future<dynamic> promptAiEngine(String prompt, String type,
      {ReturnType returnType = ReturnType.node}) async {
    dynamic nodes = await retry(() async {

      String modifiedPrompt = "output one $type per line. response only. plain text. don't add ** around titles. ";

      if (returnType == ReturnType.node) {
        modifiedPrompt += "line format must be ' title || description '. ";
      } else if (returnType == ReturnType.trait) {
        modifiedPrompt +=
            " render traits as key:value . traits are separated by || . Always include the key, use name:maya instead of just maya. Escape paragraphs with in trait values with ###NEWLINE####. Line format example: 'name:xyz||age:xxxx||...'.  ";
      }

      modifiedPrompt += prompt;

      String? result = await AiManager().prompt("gemini", modifiedPrompt);

      if (returnType == ReturnType.node) {
        return nodeListFromString(result!, type);
      } else {
        return traitsListFromString(result!, type);
      }
    }, retryIf: (e) => true, maxAttempts: 5);
    return nodes;
  }

  String summarizeRoles(List<Node> nodes) {
    return '[${nodes.map((node) => '${node.title}').join('; ')}]';
  }

  List<Node> nodeListFromString(String text, String type) {
    return text
        .split('\n')
        .map((line) {
          var parts = line.split('||').map((part) => part.trim()).toList();
          if (parts.length < 2) return null;
          return Node(type, parts[0], parts[1], [], []);
        })
        .where((node) => node != null)
        .toList()
        .cast<Node>();
  }

  Future<List<List<Trait>>> traitsListFromString(String text, String type) async {
    return text
        .split('\n')
        .map((line) {
          var parts = line.split('||').map((part) => part.trim()).toList();

          List<Trait> traits = parts
              .map((traitString) {
                var traitData = traitString.split(':');
                return traitData.length < 2
                    ? null
                    : Trait(traitData[0], traitData.sublist(1).join(':'));
              })
              .where((trait) => trait != null)
              .toList()
              .cast<Trait>();

          return traits;
        })
        .where((traits) => traits != null && traits.isNotEmpty)
        .toList();
  }
}

enum ReturnType { node, trait, character }
