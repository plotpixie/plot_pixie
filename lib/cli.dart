import 'dart:convert';
import 'dart:io';

import 'package:plot_pixie/src/ai/pixie.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:plot_pixie/src/fileformats/fountain.dart';

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

  Pixie().setIdea(idea);

  List<Node> characters =
      await Pixie().getCharacterSuggestions(numberOfCharacters: 5);
  characters.forEach((character) {
    print(jsonEncode(character));
  });

  Pixie().setCharacters(characters);

  await Pixie().generateActs();

  Fountain.write(new File("${Pixie().work.idea?.title}.fountain"), Pixie().work);

  /*

  print(jsonEncode(Pixie().work.acts));

  await Pixie().generateScenesForBeats();

  print(jsonEncode(Pixie().work.acts));

  List<Node> fleshedOutScenes =
      await Pixie().generateSceneContent(idea, characters, actsWithBeats);

  print(jsonEncode(fleshedOutScenes));
   */
}
