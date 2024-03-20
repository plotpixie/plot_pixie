import 'dart:developer';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:plot_pixie/src/ai/pixie.dart';
import 'package:plot_pixie/src/presentation/state/idea_notifier.dart';
import 'package:plot_pixie/src/presentation/colors.dart';

class ChoiceSwiper extends ConsumerWidget {
  final String title;

  ChoiceSwiper({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idea = ref.watch(selectedIdeaProvider);
    return ChoiceSwiperState(idea: idea ?? Node("idea", "nothing", "yet"));
  }
}

class ChoiceSwiperState extends StatefulWidget {
  final Node idea;

  const ChoiceSwiperState({required this.idea});

  @override
  _ChoiceSwiperState createState() => _ChoiceSwiperState();
}

class _ChoiceSwiperState extends State<ChoiceSwiperState> {
  final AppinioSwiperController controller = AppinioSwiperController();
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

    List<Node> charactersInQueue = characters
        .where((character) =>
            !selected.contains(character) && !discarded.contains(character))
        .toList();
    List<Node> newCards = await Pixie()
        .getCharacterSuggestions(widget.idea, // Use idea from widget
            numberOfCharacters: 4,
            existingCharacters: selected + charactersInQueue);
    if (cardsLeft < 2) {
      cardsLeft += newCards.length;
      characters += newCards;
      log("cards left: $cardsLeft");
      log("Fetching done: Character count is: ${characters.length}");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    log("cards left: $cardsLeft");
    return CupertinoPageScaffold(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 1,
        child: characters.isEmpty || cardsLeft == 0
            ? Center(
                child: Text('Loading characters...',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    )))
            : AppinioSwiper(
                invertAngleOnBottomDrag: true,
                backgroundCardCount: 3,
                swipeOptions: const SwipeOptions.symmetric(
                    horizontal: true, vertical: false),
                controller: controller,
                onSwipeEnd: _swipeEnd,
                onEnd: _onEnd,
                cardCount: characters.length,
                cardBuilder: (BuildContext context, int index) {
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
                                        SizedBox(
                                            height:
                                                5.0), // Add spacing between traits
                                      ],
                                    ),
                                  SizedBox(height: 10.0),
                                ],
                              ),
                            )
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
