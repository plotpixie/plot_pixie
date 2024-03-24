import 'dart:convert';
import 'dart:io';

import 'package:plot_pixie/src/ai/pixie.dart';
import 'package:plot_pixie/src/ai/model/node.dart';

void main() async {
  print("\x1B[32mEnter your prompt idea:\x1B[0m");
  String? userInput = stdin.readLineSync();

  final List<Node> ideas = await Pixie().getIdeas(userInput!);

  for (int i = 0; i < ideas.length; i++) {
    print("${i + 1}. ${ideas[i].title} \n   ${ideas[i].description}");
  }

  print("\x1B[32mPlease enter the number of the idea you want to pick:\x1B[0m");
  String? userChoice = stdin.readLineSync();
  int choice = int.parse(userChoice!) - 1;

  Node idea = ideas[choice];

  List<Node> characters =
      await Pixie().getCharacterSuggestions(idea, numberOfCharacters: 5);
  characters.forEach((character) {
    print(jsonEncode(character));
  });

  List<Node> acts = await Pixie().getActs(idea, characters);

  print(jsonEncode(acts));

  List<Node> actsWithBeats =
      await Pixie().generateScenesForBeats(idea, characters, acts);

  print(jsonEncode(actsWithBeats));

  List<Node> fleshedOutScenes =
      await Pixie().generateSceneContent(idea, characters, actsWithBeats);

  print(jsonEncode(fleshedOutScenes));
}
