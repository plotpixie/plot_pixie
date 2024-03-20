import 'dart:convert';
import 'dart:developer';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_pixie/src/ai/model/node.dart';
import 'package:plot_pixie/src/ai/pixie.dart';
import 'package:plot_pixie/src/presentation/state/idea_notifier.dart';

import 'character_card.dart';

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

  Future<void> _fetchCharacters({int charCount = 2}) async {
    log("Fetching");

    List<Node> charactersInQueue = characters
        .where((character) =>
            !selected.contains(character) && !discarded.contains(character))
        .toList();
    List<Node> newCards = await Pixie()
        .getCharacterSuggestions(widget.idea, // Use idea from widget
            numberOfCharacters: charCount,
            existingCharacters: selected + charactersInQueue);
    cardsLeft += newCards.length;
    characters += newCards;
    log("Fetching done: cards left is : $cardsLeft");
    setState(() {});
    if (cardsLeft <= 3) {
      _fetchCharacters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 1,
        child: characters.isEmpty ||
                (controller.cardIndex == characters.length - 1)
            ? Center(
                child: Text(
                'Loading characters...',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ))
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
                  return CharacterCard(
                      characters: characters,
                      index: index,
                      addFunction: _swipeRight,
                      discardFunction: _swipeLeft);
                },
              ),
      ),
    );
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      case Swipe():
        cardsLeft--;
        log("cards left: $cardsLeft");
        if (cardsLeft <= 3) {
          _fetchCharacters();
        }
        if (activity.direction == AxisDirection.right) {
          _selectCharacter(previousIndex);
        } else if (activity.direction == AxisDirection.left) {
          _discardCharacter(previousIndex);
        }
        break;
      case Unswipe():
      case CancelSwipe():
      case DrivenActivity():
    }
  }

  void _discardCharacter(int previousIndex) {
    discarded.add(characters[previousIndex]);
  }

  void _swipeLeft() {
    controller.swipeLeft();
  }

  void _swipeRight() {
    controller.swipeRight();
  }

  void _selectCharacter(int previousIndex) {
    selected.add(characters[previousIndex]);
    log('Approved list is ' + jsonEncode(selected));
  }

  void _onEnd() {
    log('fetching characters. Because the list has finished');
    _fetchCharacters();
  }
}
