import 'package:flutter/material.dart';

import 'colors.dart';
import 'package:plot_pixie/src/ai/model/node.dart';

class CharacterCard extends StatelessWidget {
  CharacterCard({
    super.key,
    required this.characters,
    required this.index,
    required this.addFunction,
    required this.discardFunction,
  });

  final ScrollController _scrollController = ScrollController();
  final List<Node> characters;
  final int index;
  final Function addFunction;
  final Function discardFunction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        alignment: Alignment.center,
        color: colors[index % colors.length],
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: _scrollController,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          generateTextSpan('${characters[index].title}\n', 32.0,
                              FontWeight.bold),
                          generateTextSpan('\n', 8.0, FontWeight.normal),
                          generateTextSpan('${characters[index].description}\n',
                              18.0, FontWeight.normal),
                          generateTextSpan('\n', 8.0, FontWeight.normal),
                          for (var trait in characters[index].traits)
                            TextSpan(
                              children: [
                                generateTextSpan('${capitalize(trait!.type)}: ',
                                    18.0, FontWeight.bold),
                                generateTextSpan('${trait.description}\n', 18.0,
                                    FontWeight.normal),
                                generateTextSpan('\n', 8.0, FontWeight.normal),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Floating buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _swipeButton(Icons.close_rounded, Colors.red, () {
                    _scrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 10),
                      curve: Curves.easeOut,
                    );
                    discardFunction();
                  }),
                  _swipeButton(Icons.favorite_rounded, Colors.green, () {
                    _scrollController.animateTo(
                      0.0,
                      duration: const Duration(milliseconds: 10),
                      curve: Curves.easeOut,
                    );
                    addFunction();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan generateTextSpan(String text, double fontSize, FontWeight weight) {
    return TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: weight,
        color: Colors.black,
      ),
    );
  }

  String capitalize(String s) {
    return "${s[0].toUpperCase()}${s.substring(1)}";
  }

  Widget _swipeButton(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(20.0),
        padding: const EdgeInsets.all(10.0),
        decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
          color: color,
          shadows: const [BoxShadow(color: Colors.black, blurRadius: 5)],
        ),
        child: Icon(icon, color: Colors.white, size: 45.0),
      ),
    );
  }
}
