import 'dart:developer';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plot_pixie/src/ai/pixie.dart';

import '../ai/model/node.dart';

class ChoiceSwiper extends StatefulWidget {
  final String title;
  final List<Color> colors = [
    const Color.fromRGBO(247, 135, 154, 1.0), // #f7879a
    const Color.fromRGBO(237, 197, 87, 1.0), // #edc557
    const Color.fromRGBO(243, 246, 244, 1.0), // #f3f6f4
    const Color.fromRGBO(61, 173, 183, 1.0), // #3dadb7
    const Color.fromRGBO(116, 116, 189, 1.0), // #7474bd
    const Color.fromRGBO(168, 208, 230, 1.0), // #a8d0e6
    const Color.fromRGBO(240, 138, 93, 1.0), // #f08a5d
    const Color.fromRGBO(255, 221, 147, 1.0), // #ffdd93
  ];

  ChoiceSwiper({super.key, required this.title});

  @override
  _ChoiceSwiperState createState() => _ChoiceSwiperState();
}

class _ChoiceSwiperState extends State<ChoiceSwiper> {
  final AppinioSwiperController controller = AppinioSwiperController();
  final Node idea = Node("idea", "The Illusion of Love",
      "A struggling wedding magician, down on his luck and drowning in debt, becomes consumed by a dark obsession with a beautiful bride.  He discovers he has the power to manipulate emotions, and a twisted plan takes root in his mind.  Through subtle illusions and suggestive whispers, he warps the groom's perception, turning joyful anticipation into cold suspicion.  The wedding ceremony becomes a grotesque parody of love, with the vows laced with hidden barbs and the celebratory dance a performance of simmering resentment.  The magician takes a perverse satisfaction in orchestrating the disaster,  a cruel puppet master pulling the strings of the hapless groom's emotions.  But as the night progresses and the bride's true colors begin to show, the magician realizes he may have gotten more than he bargained for, entangled in a web of deceit with a woman as dangerous as his own dark magic.");

  List<Node> characters = [];

  int cardsLeft = 0;
  List<Node> selected = [];
  List<Node> discarded = [];

  @override
  void initState() {
    super.initState();
    _fetchCharacters();
  }

  Future<void> _fetchCharacters() async {
    log("Fetching");

    List<Node> charactersInQueue = characters.where((character) => !selected.contains(character) && !discarded.contains(character)).toList();
    List<Node> newCards = await Pixie().getCharacterSuggestions(idea,
        numberOfCharacters: 4,
        existingCharacters: selected + charactersInQueue);
    if (cardsLeft < 2) {
      cardsLeft += newCards.length;
      characters += newCards;
      log("cards left: $cardsLeft");
      log("Fetching done: Character count is: ${characters.length}");
      setState(() {}); // Notify the widget that state has changed
    }
  }

  @override
  Widget build(BuildContext context) {
    log("cards left: $cardsLeft");
    return CupertinoPageScaffold(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 1,
        child: characters.isEmpty
            ? Center(child: Text('Loading characters...'))
            : AppinioSwiper(
                invertAngleOnBottomDrag: true,
                backgroundCardCount: 3,
                swipeOptions: const SwipeOptions.symmetric(
                    horizontal: true, vertical: false),
                // Now only horizontal swipes are allowed
                controller: controller,
                onSwipeEnd: _swipeEnd,
                onEnd: _onEnd,
                cardCount: characters.length,
                cardBuilder: (BuildContext context, int index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      alignment: Alignment.center,
                      color: widget.colors[index % widget.colors.length],
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
                            SizedBox(height: 20.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 10.0),
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(2),
                                      // Adjust widths as needed
                                      1: FlexColumnWidth(3),
                                    },
                                    children: [
                                      for (var trait
                                          in characters[index].traits)
                                        TableRow(
                                          children: [
                                            Text(
                                              trait!.type,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                                color: Colors.black,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            Text(
                                              trait!.description,
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16.0,
                                                color: Colors.black,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      case Swipe():
        cardsLeft--;
        if (cardsLeft < 2) {
          _fetchCharacters();
        }
        log("cards left: $cardsLeft");
        if (activity.direction == AxisDirection.right) {
          selected.add(characters[previousIndex]);
          log('Added character to approved list: ${selected.last.title}');
        } else if (activity.direction == AxisDirection.left) {
          discarded.add(characters[previousIndex]);
          log('Added character to discarded list: ${discarded.last.title}');
        }
        log('The card was swiped to the : ${activity.direction}');
        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      case Unswipe():
      case CancelSwipe():
      case DrivenActivity():
    }
  }

  void _onEnd() {
    log('fetching characters. Because the list has finished');
    _fetchCharacters();
  }
}
