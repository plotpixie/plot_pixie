import 'package:flutter/material.dart';

import 'colors.dart';
import 'package:plot_pixie/src/ai/model/node.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.characters,
    required this.index,
    required this.addFunction,
    required this.discardFunction,
  });

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
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20.0),
              Text(
                '${characters[index].title}',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                characters[index].description,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.0),
                    for (var trait in characters[index].traits)
                      Column(
                        // Wrap RichText and SizedBox in a Column
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: trait!.type + ' : ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: trait!.description,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5.0), // Add spacing between traits
                        ],
                      ),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
              // Add buttons here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.check_box, color: Colors.green),
                    onPressed: () {
                      addFunction(index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      discardFunction(index);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
